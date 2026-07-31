import '../../../../core/storage/cache_store.dart';
import '../models/wishlist_models.dart';

class WishlistLocalDataSource {
  const WishlistLocalDataSource(this._cache);

  static const _key = 'wishlist:snapshot';

  final CacheStore _cache;

  WishlistModel? read() => _cache.read<WishlistModel>(
        _key,
        (json) => WishlistModel.fromJson(json! as Map<String, dynamic>),
      );

  Future<void> write(WishlistModel wishlist) =>
      _cache.write(_key, wishlist.toJson());

  Future<void> clear() => _cache.delete(_key);

  DateTime? get savedAt => _cache.savedAt(_key);
}
