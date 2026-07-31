import '../../../../core/domain/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/network/network_info.dart';
import '../../../cart/data/datasource/cart_local_datasource.dart';
import '../../../cart/data/datasource/outbox_queue.dart';
import '../../domain/entities/wishlist.dart';
import '../../domain/entities/wishlist_move_result.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasource/wishlist_local_datasource.dart';
import '../datasource/wishlist_remote_datasource.dart';
import '../models/wishlist_models.dart';

abstract final class WishlistOutboxKinds {
  const WishlistOutboxKinds._();

  static const namespace = 'wishlist';

  static const add = 'wishlist.add';
  static const remove = 'wishlist.remove';
  static const clear = 'wishlist.clear';
}

class WishlistRepositoryImpl implements WishlistRepository {
  WishlistRepositoryImpl({
    required WishlistRemoteDataSource remote,
    required WishlistLocalDataSource local,
    required CartLocalDataSource cartLocal,
    required OutboxQueue outbox,
    required NetworkInfo networkInfo,
  })  : _remote = remote,
        _local = local,
        _cartLocal = cartLocal,
        _outbox = outbox,
        _networkInfo = networkInfo;

  final WishlistRemoteDataSource _remote;
  final WishlistLocalDataSource _local;

  final CartLocalDataSource _cartLocal;
  final OutboxQueue _outbox;
  final NetworkInfo _networkInfo;

  @override
  int get pendingWriteCount => _outbox.length;

  @override
  Wishlist? get cachedWishlist => _local.read()?.toEntity();

  @override
  Future<Result<Wishlist>> getWishlist() async {
    if (!await _networkInfo.isConnected) {
      final cached = _local.read();
      return cached == null
          ? const Result.failure(EmptyCacheFailure())
          : Result.success(cached.toEntity());
    }

    if (!_outbox.isEmpty) return syncPendingWrites();

    return _fetchAndCache();
  }

  @override
  Future<Result<bool>> isSaved(String productId) async {
    final pending = _pendingVerdict(productId);

    if (!await _networkInfo.isConnected) {
      return Result.success(
        pending ?? (_local.read()?.toEntity().contains(productId) ?? false),
      );
    }

    try {
      final envelope = await _remote.check(productId);
      return Result.success(pending ?? envelope.data.inWishlist);
    } on Object catch (error) {
      final failure = ErrorMapper.toFailure(error);
      if (_isTransient(failure)) {
        return Result.success(
          pending ?? (_local.read()?.toEntity().contains(productId) ?? false),
        );
      }
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<Wishlist>> addItem({
    required String productId,
    String? variantId,
  }) async {
    if (!await _networkInfo.isConnected) {
      return _queue(
        kind: WishlistOutboxKinds.add,
        payload: {
          'productId': productId,
          'variantId': ?variantId,
        },
        replaceMatching: (entry) => entry.productId == productId,
      );
    }

    return _mutate(
      () => _remote.addItem(
        AddWishlistItemRequest(productId: productId, variantId: variantId),
      ),
    );
  }

  @override
  Future<Result<Wishlist>> removeItem(String productId) async {
    if (!await _networkInfo.isConnected) {
      return _queue(
        kind: WishlistOutboxKinds.remove,
        payload: {'productId': productId},
        replaceMatching: (entry) => entry.productId == productId,
        apply: (cached) => cached.copyWith(
          items: cached.items
              .where((item) => item.product?.id != productId)
              .toList(growable: false),
        ),
      );
    }

    return _mutate(() => _remote.removeItem(productId));
  }

  @override
  Future<Result<Wishlist>> clear() async {
    if (!await _networkInfo.isConnected) {
      return _queue(
        kind: WishlistOutboxKinds.clear,
        payload: const {},
        replaceMatching: (_) => true,
        apply: (cached) => cached.copyWith(items: const []),
      );
    }

    return _mutate(_remote.clear);
  }

  @override
  Future<Result<WishlistMoveResult>> moveToCart({
    required String productId,
    String? variantId,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Result.failure(
        NetworkFailure('Moving an item to your cart needs a connection.'),
      );
    }

    try {
      final envelope = await _remote.moveToCart(
        productId,
        WishlistMoveToCartRequest(variantId: variantId),
      );
      await _local.write(envelope.data.wishlist);
      await _cartLocal.write(envelope.data.cart);
      return Result.success(envelope.data.toEntity());
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  @override
  Future<Result<Wishlist>> syncPendingWrites() async {
    if (!await _networkInfo.isConnected) {
      return const Result.failure(NetworkFailure());
    }

    for (final entry in _outbox.pending()) {
      final failure = await _replay(entry);

      if (failure == null) {
        await _outbox.remove(entry.id);
        continue;
      }

      if (_isTransient(failure)) return Result.failure(failure);

      await _outbox.remove(entry.id);
    }

    return _fetchAndCache();
  }

  Future<Failure?> _replay(OutboxEntry entry) async {
    try {
      switch (entry.kind) {
        case WishlistOutboxKinds.add:
          await _remote.addItem(
            AddWishlistItemRequest(
              productId: entry.payload['productId'] as String,
              variantId: entry.payload['variantId'] as String?,
            ),
          );
        case WishlistOutboxKinds.remove:
          await _remote.removeItem(entry.payload['productId'] as String);
        case WishlistOutboxKinds.clear:
          await _remote.clear();
        default:
          return const UnexpectedFailure('Unknown queued wishlist operation.');
      }
      return null;
    } on Object catch (error) {
      return ErrorMapper.toFailure(error);
    }
  }

  bool? _pendingVerdict(String productId) {
    bool? verdict;
    for (final entry in _outbox.pending()) {
      switch (entry.kind) {
        case WishlistOutboxKinds.add:
          if (entry.productId == productId) verdict = true;
        case WishlistOutboxKinds.remove:
          if (entry.productId == productId) verdict = false;
        case WishlistOutboxKinds.clear:
          verdict = false;
      }
    }
    return verdict;
  }

  Future<Result<Wishlist>> _queue({
    required String kind,
    required Map<String, dynamic> payload,
    bool Function(OutboxEntry entry)? replaceMatching,
    WishlistModel Function(WishlistModel cached)? apply,
  }) async {
    final cached = _local.read();

    try {
      await _outbox.enqueue(kind, payload, replaceMatching: replaceMatching);
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }

    if (apply == null || cached == null) {
      return Result.success(cached?.toEntity() ?? const Wishlist.empty());
    }

    final updated = apply(cached);
    await _local.write(updated);
    return Result.success(updated.toEntity());
  }

  Future<Result<Wishlist>> _fetchAndCache() async {
    try {
      final envelope = await _remote.getWishlist();
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

  Future<Result<Wishlist>> _mutate(Future<dynamic> Function() request) async {
    try {
      final envelope = await request();
      final model = envelope.data as WishlistModel;
      await _local.write(model);
      return Result.success(model.toEntity());
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  static bool _isTransient(Failure failure) =>
      failure is NetworkFailure || failure is TimeoutFailure;
}
