import '../../../../core/domain/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/cart_snapshot.dart';
import '../../domain/entities/cart_summary.dart';
import '../../domain/entities/cart_validation.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasource/cart_local_datasource.dart';
import '../datasource/cart_remote_datasource.dart';
import '../datasource/outbox_queue.dart';
import '../models/cart_models.dart';

/// Kinds used in the outbox. Public constants rather than string literals at
/// the call sites, because a typo would leave an entry that no replay branch
/// matches — it would sit in the queue forever, which is exactly the failure
/// the queue exists to prevent.
abstract final class CartOutboxKinds {
  const CartOutboxKinds._();

  static const namespace = 'cart';

  static const addItem = 'cart.addItem';
  static const updateQuantity = 'cart.updateQuantity';
  static const removeItem = 'cart.removeItem';
  static const saveForLater = 'cart.saveForLater';
  static const moveToCart = 'cart.moveToCart';
  static const removeCoupon = 'cart.removeCoupon';
  static const clear = 'cart.clear';
}

/// The cart repository.
///
/// Three responsibilities beyond the obvious HTTP wrapping:
///
/// 1. **Offline reads.** The cached triple is served whenever the device is
///    unreachable, and a transport failure on an online read falls back to it
///    too. A 4xx does not — a rejected request means the server disagrees with
///    us, and showing stale data would hide that.
/// 2. **Offline writes.** Mutations are queued in the outbox and applied to
///    the cached copy so the screen reflects what the customer just did. They
///    replay in order when connectivity returns.
/// 3. **State replacement, never refetch.** Every mutating endpoint returns
///    the whole `{cart, notices, summary}` triple, so a write result is the
///    new state. A follow-up read would cost a round trip *and* discard the
///    notices the write produced, since notices are regenerated per read.
class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl({
    required CartRemoteDataSource remote,
    required CartLocalDataSource local,
    required OutboxQueue outbox,
    required NetworkInfo networkInfo,
  })  : _remote = remote,
        _local = local,
        _outbox = outbox,
        _networkInfo = networkInfo;

  final CartRemoteDataSource _remote;
  final CartLocalDataSource _local;
  final OutboxQueue _outbox;
  final NetworkInfo _networkInfo;

  @override
  int get pendingWriteCount => _outbox.length;

  @override
  CartSnapshot? get cachedCart => _local.read()?.toEntity();

  // ── Reads ──────────────────────────────────────────────────────────────

  @override
  Future<Result<CartSnapshot>> getCart() async {
    if (!await _networkInfo.isConnected) return _cachedOrEmptyCache();

    // Anything queued has to reach the server before its own view of the cart
    // is treated as the truth, or a read would overwrite the local edits that
    // have not been sent yet.
    if (!_outbox.isEmpty) return syncPendingWrites();

    return _fetchAndCache();
  }

  @override
  Future<Result<CartSummary>> getSummary() async {
    try {
      final envelope = await _remote.getSummary();
      return Result.success(envelope.data.toEntity());
    } on Object catch (error) {
      final failure = ErrorMapper.toFailure(error);

      // Totals are the one thing the cached cart can answer for itself, so an
      // unreachable server does not have to leave the checkout bar blank.
      if (_isTransient(failure)) {
        final cached = _local.read();
        if (cached != null) return Result.success(cached.summary.toEntity());
      }
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<CartValidation>> validate() async {
    try {
      final envelope = await _remote.validate();
      return Result.success(
        CartValidation.valid(envelope.data.summary.toEntity()),
      );
    } on Object catch (error) {
      final failure = ErrorMapper.toFailure(error);

      // A 422 is the *answer*, not an error: it lists every blocker at once so
      // the cart can be fixed in one pass. Only transport problems and real
      // server faults propagate as failures.
      if (failure is ValidationFailure) {
        return Result.success(CartValidation.fromFailure(failure));
      }
      return Result.failure(failure);
    }
  }

  // ── Mutations ──────────────────────────────────────────────────────────

  @override
  Future<Result<CartSnapshot>> addItem({
    required String productId,
    required String variantId,
    int quantity = 1,
  }) async {
    if (!await _networkInfo.isConnected) {
      // Queued, but *not* applied to the cached cart: an add carries only
      // ids, and a line needs the name, image and price that only the server
      // can supply. Inventing a placeholder line would show the customer a
      // price we made up. The queue depth is surfaced instead, so the pending
      // add is visible rather than silent.
      return _queue(
        kind: CartOutboxKinds.addItem,
        payload: {
          'productId': productId,
          'variantId': variantId,
          'quantity': quantity,
        },
      );
    }

    return _mutate(
      () => _remote.addItem(
        AddCartItemRequest(
          productId: productId,
          variantId: variantId,
          quantity: quantity,
        ),
      ),
    );
  }

  @override
  Future<Result<CartSnapshot>> updateQuantity({
    required String itemId,
    required int quantity,
  }) async {
    if (!await _networkInfo.isConnected) {
      return _queue(
        kind: CartOutboxKinds.updateQuantity,
        payload: {'itemId': itemId, 'quantity': quantity},
        // Only the final quantity matters. Five taps of the stepper leave one
        // entry, not five.
        replaceMatching: (entry) =>
            entry.kind == CartOutboxKinds.updateQuantity &&
            entry.itemId == itemId,
        apply: (cached) => _applyToItem(
          cached,
          itemId,
          (item) => item.copyWith(quantity: quantity),
        ),
      );
    }

    return _mutate(
      () => _remote.updateItem(itemId, UpdateCartItemRequest(quantity: quantity)),
    );
  }

  @override
  Future<Result<CartSnapshot>> removeItem(String itemId) async {
    if (!await _networkInfo.isConnected) {
      return _queue(
        kind: CartOutboxKinds.removeItem,
        payload: {'itemId': itemId},
        // A removal supersedes every earlier edit to the same line. Replaying
        // "set quantity to 3" after a delete would 404 at best and resurrect a
        // deleted line at worst.
        replaceMatching: (entry) => entry.itemId == itemId,
        apply: (cached) => _repriced(
          cached,
          cached.cart.copyWith(
            items: cached.cart.items
                .where((item) => item.id != itemId)
                .toList(growable: false),
          ),
        ),
      );
    }

    return _mutate(() => _remote.removeItem(itemId));
  }

  @override
  Future<Result<CartSnapshot>> saveForLater(String itemId) async {
    if (!await _networkInfo.isConnected) {
      return _queue(
        kind: CartOutboxKinds.saveForLater,
        payload: {'itemId': itemId},
        // The two directions cancel out, so a save replaces a pending move
        // and vice versa — the last one the customer chose is the truth.
        replaceMatching: (entry) =>
            entry.itemId == itemId &&
            (entry.kind == CartOutboxKinds.saveForLater ||
                entry.kind == CartOutboxKinds.moveToCart),
        apply: (cached) => _applyToItem(
          cached,
          itemId,
          (item) => item.copyWith(savedForLater: true),
        ),
      );
    }

    return _mutate(() => _remote.saveForLater(itemId));
  }

  @override
  Future<Result<CartSnapshot>> moveToCart(String itemId) async {
    if (!await _networkInfo.isConnected) {
      return _queue(
        kind: CartOutboxKinds.moveToCart,
        payload: {'itemId': itemId},
        replaceMatching: (entry) =>
            entry.itemId == itemId &&
            (entry.kind == CartOutboxKinds.saveForLater ||
                entry.kind == CartOutboxKinds.moveToCart),
        apply: (cached) => _applyToItem(
          cached,
          itemId,
          (item) => item.copyWith(savedForLater: false),
        ),
      );
    }

    return _mutate(() => _remote.moveToCart(itemId));
  }

  @override
  Future<Result<CartSnapshot>> applyCoupon(String code) async {
    if (!await _networkInfo.isConnected) {
      // Deliberately not queued. A coupon's worth depends on minimum spend,
      // per-product eligibility and usage limits that only the server can
      // evaluate, so accepting one offline would either show a discount that
      // evaporates at checkout or one the customer was entitled to and we
      // guessed wrong about. Refusing is the honest answer.
      return const Result.failure(
        NetworkFailure('Coupons can only be applied while you are online.'),
      );
    }

    return _mutate(
      () => _remote.applyCoupon(ApplyCouponRequest(code: code.trim())),
    );
  }

  @override
  Future<Result<CartSnapshot>> removeCoupon() async {
    if (!await _networkInfo.isConnected) {
      // Safe in the other direction: removing a discount can only ever make
      // the displayed total higher than the eventual one.
      return _queue(
        kind: CartOutboxKinds.removeCoupon,
        payload: const {},
        replaceMatching: (entry) => entry.kind == CartOutboxKinds.removeCoupon,
        apply: (cached) => _repriced(
          cached,
          cached.cart.copyWith(clearCoupon: true),
          dropDiscount: true,
        ),
      );
    }

    return _mutate(_remote.removeCoupon);
  }

  @override
  Future<Result<CartSnapshot>> clearCart() async {
    if (!await _networkInfo.isConnected) {
      return _queue(
        kind: CartOutboxKinds.clear,
        payload: const {},
        // Nothing queued before an empty-the-cart can still matter.
        replaceMatching: (_) => true,
        apply: (cached) => _repriced(
          cached,
          cached.cart.copyWith(items: const [], clearCoupon: true),
          dropDiscount: true,
        ),
      );
    }

    return _mutate(_remote.clearCart);
  }

  // ── Offline queue ──────────────────────────────────────────────────────

  @override
  Future<Result<CartSnapshot>> syncPendingWrites() async {
    if (!await _networkInfo.isConnected) {
      return const Result.failure(NetworkFailure());
    }

    // Snapshot the queue up front: replaying is sequential, and re-reading it
    // between entries would pick up writes the customer makes mid-flush and
    // replay them out of order.
    for (final entry in _outbox.pending()) {
      final failure = await _replay(entry);

      if (failure == null) {
        await _outbox.remove(entry.id);
        continue;
      }

      if (_isTransient(failure)) {
        // The connection died again mid-flush. Everything from here stays
        // queued, in order, for the next attempt.
        return Result.failure(failure);
      }

      // The server will never accept this one — the variant is gone, the line
      // was already deleted, the quantity exceeds stock. Retrying forever
      // would block every later write behind it, so it is dropped and the
      // reconciling read below shows the customer what actually happened.
      await _outbox.remove(entry.id);
    }

    return _fetchAndCache();
  }

  /// Sends one queued write. Returns null on success, or why it failed.
  Future<Failure?> _replay(OutboxEntry entry) async {
    try {
      switch (entry.kind) {
        case CartOutboxKinds.addItem:
          await _remote.addItem(
            AddCartItemRequest(
              productId: entry.payload['productId'] as String,
              variantId: entry.payload['variantId'] as String,
              quantity: entry.payload['quantity'] as int?,
            ),
          );
        case CartOutboxKinds.updateQuantity:
          await _remote.updateItem(
            entry.payload['itemId'] as String,
            UpdateCartItemRequest(quantity: entry.payload['quantity'] as int),
          );
        case CartOutboxKinds.removeItem:
          await _remote.removeItem(entry.payload['itemId'] as String);
        case CartOutboxKinds.saveForLater:
          await _remote.saveForLater(entry.payload['itemId'] as String);
        case CartOutboxKinds.moveToCart:
          await _remote.moveToCart(entry.payload['itemId'] as String);
        case CartOutboxKinds.removeCoupon:
          await _remote.removeCoupon();
        case CartOutboxKinds.clear:
          await _remote.clearCart();
        default:
          // Written by a build that no longer exists. Treated as permanently
          // unacceptable so it is dropped rather than retried forever.
          return const UnexpectedFailure('Unknown queued cart operation.');
      }
      return null;
    } on Object catch (error) {
      return ErrorMapper.toFailure(error);
    }
  }

  /// Queues a write and, when it can be represented locally, applies it to the
  /// cached cart so the screen reflects the change immediately.
  Future<Result<CartSnapshot>> _queue({
    required String kind,
    required Map<String, dynamic> payload,
    bool Function(OutboxEntry entry)? replaceMatching,
    CartSnapshotModel? Function(CartSnapshotModel cached)? apply,
  }) async {
    final cached = _local.read();

    // An edit to a line we have never downloaded cannot be trusted to name a
    // real item id. Refusing beats queueing a write that is guaranteed to 404.
    if (apply != null && cached == null) {
      return const Result.failure(
        EmptyCacheFailure(
          'Your cart has not been downloaded yet. Reconnect to change it.',
        ),
      );
    }

    try {
      await _outbox.enqueue(kind, payload, replaceMatching: replaceMatching);
    } on Object catch (error) {
      // If the write cannot be recorded it must not appear to have happened —
      // a change that silently vanishes is the one outcome worth failing over.
      return Result.failure(ErrorMapper.toFailure(error));
    }

    if (apply == null || cached == null) {
      return Result.success(cached?.toEntity() ?? const CartSnapshot.empty());
    }

    final updated = apply(cached);
    if (updated == null) {
      return const Result.failure(
        NotFoundFailure('That item is no longer in your cart.'),
      );
    }

    await _local.write(updated);
    return Result.success(updated.toEntity());
  }

  // ── Plumbing ───────────────────────────────────────────────────────────

  Future<Result<CartSnapshot>> _fetchAndCache() async {
    try {
      final envelope = await _remote.getCart();
      await _local.write(envelope.data);
      return Result.success(envelope.data.toEntity());
    } on Object catch (error) {
      final failure = ErrorMapper.toFailure(error);
      if (_isTransient(failure)) {
        final cached = _local.read();
        if (cached != null) return Result.success(cached.toEntity());
      }
      return Result.failure(failure);
    }
  }

  /// Runs a mutating request and adopts its response as the new state.
  Future<Result<CartSnapshot>> _mutate(
    Future<dynamic> Function() request,
  ) async {
    try {
      final envelope = await request();
      final model = envelope.data as CartSnapshotModel;
      await _local.write(model);
      return Result.success(model.toEntity());
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  Result<CartSnapshot> _cachedOrEmptyCache() {
    final cached = _local.read();
    return cached == null
        ? const Result.failure(EmptyCacheFailure())
        : Result.success(cached.toEntity());
  }

  /// Replaces one line and re-prices, or null when the line is not there.
  CartSnapshotModel? _applyToItem(
    CartSnapshotModel cached,
    String itemId,
    CartItemModel Function(CartItemModel item) transform,
  ) {
    var found = false;
    final items = <CartItemModel>[];
    for (final item in cached.cart.items) {
      if (item.id == itemId) {
        found = true;
        items.add(transform(item));
      } else {
        items.add(item);
      }
    }

    if (!found) return null;
    return _repriced(cached, cached.cart.copyWith(items: items));
  }

  /// Re-derives the totals for a locally-edited cart.
  ///
  /// The notices are dropped: they describe the server's last read, and
  /// leaving them attached to lines the customer has just edited would
  /// attribute their own change to the server.
  CartSnapshotModel _repriced(
    CartSnapshotModel cached,
    CartModel cart, {
    bool dropDiscount = false,
  }) {
    final previous = cached.summary.toEntity();
    final basis = dropDiscount
        ? CartSummary(currency: previous.currency)
        : previous;

    return cached.copyWith(
      cart: cart,
      notices: const [],
      summary: CartSummaryModel.fromEntity(basis.estimate(cart.toEntity())),
    );
  }

  static bool _isTransient(Failure failure) =>
      failure is NetworkFailure || failure is TimeoutFailure;
}
