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

  @override
  Future<Result<CartSnapshot>> getCart() async {
    if (!await _networkInfo.isConnected) return _cachedOrEmptyCache();

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

      if (failure is ValidationFailure) {
        return Result.success(CartValidation.fromFailure(failure));
      }
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<CartSnapshot>> addItem({
    required String productId,
    required String variantId,
    int quantity = 1,
  }) async {
    if (!await _networkInfo.isConnected) {
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

  @override
  Future<Result<CartSnapshot>> syncPendingWrites() async {
    if (!await _networkInfo.isConnected) {
      return const Result.failure(NetworkFailure());
    }

    for (final entry in _outbox.pending()) {
      final failure = await _replay(entry);

      if (failure == null) {
        await _outbox.remove(entry.id);
        continue;
      }

      if (_isTransient(failure)) {
        return Result.failure(failure);
      }

      await _outbox.remove(entry.id);
    }

    return _fetchAndCache();
  }

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
          return const UnexpectedFailure('Unknown queued cart operation.');
      }
      return null;
    } on Object catch (error) {
      return ErrorMapper.toFailure(error);
    }
  }

  Future<Result<CartSnapshot>> _queue({
    required String kind,
    required Map<String, dynamic> payload,
    bool Function(OutboxEntry entry)? replaceMatching,
    CartSnapshotModel? Function(CartSnapshotModel cached)? apply,
  }) async {
    final cached = _local.read();

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
