# UrbanThread mobile — architecture & conventions

Binding contract for every feature in this app. Read before writing code.

## Layering

```
presentation (pages, widgets, Riverpod notifiers)
      ↓ depends on
domain (entities, repository interfaces, use cases)   ← knows nothing else
      ↑ implemented by
data (models, datasources, repository impls)
```

Rules that are not negotiable:

- **Domain imports nothing from `data/` or `presentation/`**, and no package
  except `equatable` and core's `result.dart` / `usecase.dart` / `failures.dart`.
  No Dio, no Hive, no Flutter.
- **Presentation never touches a datasource or a model.** It talks to use
  cases and receives entities.
- **`core/` never imports from `features/`.** When core needs to signal a
  feature (a 401 → sign-out), it exposes a stream the feature subscribes to.
  See `core/session/session_events.dart`.
- Repositories return `Result<T>`; they do not throw. Datasources throw;
  they do not return `Result`.

## Feature layout

```
features/<feature>/
  data/
    datasource/    <feature>_remote_datasource.dart   (Retrofit)
                   <feature>_local_datasource.dart    (Hive, if cached)
    models/        *_model.dart   (json_serializable, with toEntity())
    repositories/  <feature>_repository_impl.dart
  domain/
    entities/      plain Equatable classes
    repositories/  <feature>_repository.dart   (abstract interface)
    usecases/      one class per action
  presentation/
    pages/         *_page.dart
    providers/     *_providers.dart (DI), *_notifier.dart (state)
    widgets/       feature-local widgets
```

## API contract — things that will bite you

The backend is `/mnt/d/la/backend` (Node/Express/Mongoose). **Do not modify
it.** Consume it only.

**Envelope.** Every response is `{ success, message, data, meta? }`. Decode
with `ApiEnvelope<T>` (`core/network/api_envelope.dart`). Retrofit handles the
generic — declare `Future<ApiEnvelope<FooModel>>` and it generates correctly.
`meta` appears only on paginated routes.

**`_id`, not `id`.** There is no `toJSON` transform on any model. Hydrated
documents emit both `_id` and `id`; `.lean()` reads — which are the repository
*default* — emit only `_id`. Always `@JsonKey(name: '_id') final String id;`
and ignore any `id` key.

**Pagination meta** is `page, limit, total, totalPages, hasNextPage,
hasPrevPage, nextPage?, prevPage?`. Note `hasNextPage`, not `hasNext`.
`nextPage`/`prevPage` are nullable ints.

**Errors** are `{ success: false, message, errors: [{field, message}] }`.
422 carries the field errors that drive inline form messages. `ErrorMapper`
already converts all of this — never parse an error body yourself.

**Empty string is the null sentinel.** `phone`, `avatar.url`, `image.url`,
`logo.url`, `trackingNumber`, `landmark`, `state`, `postalCode` all default to
`""`. Normalise to a Dart `null` in `toEntity()`.

**Virtuals are conditional.** `inStock`, `primaryImage`, `availableSizes`,
`availableColors`, `isLowStock`, `itemCount`, `isCancellable` exist only on
*hydrated* responses (product detail, cart, POST/PATCH results). List and
aggregate endpoints drop them. Model every virtual as nullable and compute a
client-side fallback from the stored fields.

**Product detail is slug-only.** There is no `GET /products/:id`. Carry
`slug` through from list responses. But `/products/:id/related` and
`/frequently-bought-together` take a real ObjectId — the asymmetry is real.

**`category` and `brand` are polymorphic** — a populated object on most
endpoints, a bare ObjectId string on `/frequently-bought-together`. Write a
converter that tolerates both.

**Money.** Field names are `price`, `discountPercentage`, `effectivePrice`
(post-discount). There is no `comparePrice`. Cart/order totals use
**`grandTotal`**, never `total`. Currency is NPR.

**Naming traps.** Order status history is **`timeline`**, not `statusHistory`.
Coupon type is **`type`** (`percentage`|`fixed`), not `discountType`. Product
rating is nested `rating.average` / `rating.count`. Filter param is
`minRating`, and `isFeatured` — not `rating`/`featured`.

**Query params not on the validator's list are silently dropped** — a typo'd
filter fails open and returns the unfiltered catalogue. Use the exact names.
Multi-value filters (`brand`, `size`, `color`, `tags`) accept comma-separated
values; prefer that form.

**Auth.** A single 7-day JWT, **no refresh endpoint**. A 401 is terminal:
clear the session and route to login. `AuthInterceptor` already does this.
Checkout and reviews additionally require `isEmailVerified`.

**Checkout is synchronous.** No payment gateway exists — `paymentMethod` is
`cod` or `mock_gateway` only, settled in-process during `POST /orders`. No
WebView, no redirect, no polling. `POST /orders` takes
`shippingAddressId` (an id from the user's address book, **not** a full
address), optional `billingAddressId`, `paymentMethod`, optional `couponCode`
and `customerNote`. Sending any pricing field is a 422. Items come from the
server-side cart — you do not post them.

Mock-gateway declines when the integer part of `grandTotal` ends in 7, and the
whole order rolls back. Handle the 422 rather than assuming an order exists.

## State management — Riverpod only

No Provider, no Bloc, no GetX. Use `riverpod_annotation` codegen throughout.

- DI providers live in `presentation/providers/<feature>_providers.dart`.
- Screen state uses `@riverpod class FooNotifier extends _$FooNotifier`.
- **The generator strips the `Notifier` suffix**: `class CartNotifier` yields
  `cartProvider`, not `cartNotifierProvider`. Check the generated `.g.dart`
  if a provider name will not resolve.
- `.select()` is **not** available on a generated notifier provider in
  Riverpod 3. Derive a separate `@riverpod` function instead; entity states are
  Equatable, so unchanged values already do not rebuild.
- Long-lived state (session, cart badge) uses `@Riverpod(keepAlive: true)`.
- The `Ref` parameter is plain `Ref`, not `FooRef`.

## Offline behaviour

`CacheStore` (`core/storage/cache_store.dart`) wraps a Hive box and stores
JSON with a write timestamp. Repositories follow this shape:

```dart
final online = await _networkInfo.isConnected;
if (!online) {
  final cached = _local.readProducts(key);
  return cached.isEmpty
      ? const Result.failure(EmptyCacheFailure())
      : Result.success(cached);
}
try {
  final fresh = await _remote.getProducts(...);
  await _local.writeProducts(key, fresh);
  return Result.success(fresh.map(...));
} on Object catch (error) {
  final failure = ErrorMapper.toFailure(error);
  // A transport failure falls back to cache; a 4xx does not.
  if (failure is NetworkFailure || failure is TimeoutFailure) { ...cache... }
  return Result.failure(failure);
}
```

Cache products, categories, cart, wishlist, profile, recently-viewed, search
history and home sections. Stale data beats an empty screen — serve it and
refresh in the background.

## Styling

Never hardcode a colour, radius or text style.

- `context.palette` → brand tokens (`ink`, `canvas`, `line`, `accent`, …)
- `context.text` → the type scale
- `AppDimens` → spacing (4px scale), radii (**4px default — the brand is
  square**), durations
- `AppNetworkImage` for every remote image; it re-bases URLs so `localhost`
  links from the backend resolve on a device.
- `LoadingView` / `EmptyView` / `FailureView` for async states.
- Buttons are uppercase with letter-spacing — that is in the theme already.

## Verifying

From the project root, with `export PATH="$HOME/flutter/bin:$PATH"`:

```
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

Both must be clean. `flutter analyze` reporting "No issues found!" is the bar.
