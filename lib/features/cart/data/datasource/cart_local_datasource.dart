import '../../../../core/storage/cache_store.dart';
import '../models/cart_models.dart';

class CartLocalDataSource {
  const CartLocalDataSource(this._cache);

  static const _key = 'cart:snapshot';

  final CacheStore _cache;

  CartSnapshotModel? read() => _cache.read<CartSnapshotModel>(
        _key,
        (json) => CartSnapshotModel.fromJson(json! as Map<String, dynamic>),
      );

  Future<void> write(CartSnapshotModel snapshot) =>
      _cache.write(_key, snapshot.toJson());

  Future<void> clear() => _cache.delete(_key);

  DateTime? get savedAt => _cache.savedAt(_key);
}
