# UrbanThread — mobile

Flutter client for the UrbanThread clothing eCommerce platform. It consumes
the existing Node/Express/MongoDB API in `../backend` and adds no server code
of its own.

Architecture, conventions and the API's sharp edges are documented in
[ARCHITECTURE.md](ARCHITECTURE.md) — read that before changing anything.

## Stack

Clean Architecture (data / domain / presentation per feature), feature-first,
Repository pattern, MVVM through Riverpod.

| Concern | Package |
|---|---|
| State | `flutter_riverpod` + `riverpod_annotation` (codegen) |
| Routing | `go_router` |
| HTTP | `dio` + `retrofit` |
| Models | `freezed`, `json_serializable` |
| Offline | `hive_ce`, `shared_preferences`, `flutter_secure_storage` |
| Media | `cached_network_image`, `flutter_svg`, `image_picker` |
| Misc | `connectivity_plus`, `internet_connection_checker_plus`, `intl`, `logger`, `permission_handler`, `flutter_dotenv` |

Two substitutions from the original brief, both forced:

- **`hive_ce` instead of `hive`.** Hive 2.x is discontinued and does not
  support Dart 3.11. `hive_ce` is the maintained community fork with the same
  API.
- **No `riverpod_lint` / `custom_lint`.** They pin `analyzer ^7`, which
  conflicts with Freezed 3's `analyzer >=9`. Nothing else needs them.

### Dependency versions are load-bearing

Verified against **Flutter 3.41.1 / Dart 3.11.0**.

The Flutter SDK pins `meta` (1.17.0 on 3.41), and `analyzer >=10.0.2` requires
`meta ^1.18`. So every code generator in this project has to stay on
**analyzer 9.x**, and the pins in `pubspec.yaml` are the newest releases that
do. Loosening any of them — or blanking the constraints — makes pub wander
into the analyzer-10/12 releases and report a several-hundred-line unsolvable
graph instead of the one-line incompatibility it really is.

If you upgrade Flutter, move the whole generator set forward together with
`flutter pub upgrade --major-versions`, deliberately.

## Setup

```bash
cp .env.example .env      # then edit — see below
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Pointing the app at the backend

`API_BASE_URL` in `.env` must be reachable **from the device**, which is not
the same machine as your workstation:

| Target | `API_BASE_URL` |
|---|---|
| Android emulator | `http://10.0.2.2:5000/api/v1` |
| iOS simulator | `http://localhost:5000/api/v1` |
| Physical device | `http://<your-LAN-ip>:5000/api/v1` |

`localhost` on a phone means the phone. This is the most common reason the app
appears to hang on a blank catalogue.

**Images need the same treatment, and the server does not do it for you.** The
backend stores absolute image URLs built from its own `SERVER_URL`
(`backend/src/middleware/upload.js`), so with the default config every product
image is `http://localhost:5000/uploads/...` — unreachable from a device. The
app rewrites that origin onto the one implied by `API_BASE_URL`; set
`MEDIA_ORIGIN_OVERRIDE` to whatever the backend's `SERVER_URL` actually is.
See `lib/core/utils/media_url.dart`.

Plain HTTP is permitted in development for loopback and private ranges only
(`android/app/src/main/res/xml/network_security_config.xml`, and
`NSAllowsLocalNetworking` in `ios/Runner/Info.plist`). A release build against
a real domain still gets full TLS enforcement.

### Running the backend

```bash
cd ../backend && npm run dev     # http://localhost:5000, docs at /api-docs
```

## Codegen

Any change to a `@JsonSerializable`, `@freezed`, `@RestApi` or `@riverpod`
declaration needs a rebuild:

```bash
dart run build_runner build --delete-conflicting-outputs
# or, while iterating:
dart run build_runner watch --delete-conflicting-outputs
```

Two generator behaviours that cost time if you do not know them:

- **The Riverpod generator strips a `Notifier` suffix.** `class CartNotifier`
  produces `cartProvider`, not `cartNotifierProvider`.
- **`.select()` is not available on a generated notifier provider** in
  Riverpod 3. Derive a separate `@riverpod` function instead.

## Verifying

```bash
flutter analyze     # must print "No issues found!"
flutter test
```

## Layout

```
lib/
  core/            config, constants, domain, errors, extensions, network,
                   providers, router, session, storage, theme, utils, widgets
  features/
    authentication/  home/     categories/  products/
    search/          cart/     wishlist/    checkout/
    orders/          profile/  notifications/  settings/
  main.dart
```

Every feature is `data/` + `domain/` + `presentation/`. Domain depends on
nothing outward; `core/` never imports a feature.

## Offline behaviour

Catalogue, cart, wishlist, profile, orders, recently-viewed and search history
are cached in Hive. With no connection the app serves cached data rather than
an error, and shows an offline strip under the app bar.

Cart and wishlist mutations made offline are queued in an outbox and replayed
when connectivity returns, then reconciled against the server's response.
Two things are deliberately **not** queued, because the server is the only
authority and a fabricated local answer would be a lie the user discovers at
checkout: applying a coupon, and placing an order.

## API behaviour worth knowing

- **A 401 is terminal.** The API issues one 7-day JWT and has no refresh
  endpoint; revocation is a `tokenVersion` bump. The interceptor clears the
  session and routes to login rather than retrying.
- **Checkout is synchronous.** There is no payment gateway — `paymentMethod`
  is `cod` or `mock_gateway`, settled inside `POST /orders`. No WebView, no
  redirect, no polling.
- **The mock gateway declines when the integer part of the total ends in 7**
  and rolls the entire order back, creating nothing. Useful for exercising the
  failure path; also surprising if you do not know it, so the checkout screen
  warns before submit.
- **Product detail is slug-only.** There is no `GET /products/:id`, so slugs
  are carried through from list responses.
- **Checkout and reviews require a verified email.** Both screens explain that
  rather than surfacing a bare 403.
