import '../../../../core/storage/cache_store.dart';
import '../models/wishlist_models.dart';

/// The wishlist's mirror on disk, in the `account` box.
///
/// Cached for the same reason as the cart: the saved-items list must open
/// without a connection. It also backs the offline answer to "is this
/// saved?", so a heart button stays correct on a product page with no signal.
class WishlistLocalDataSource {
  const WishlistLocalDataSource(this._cache);

  static const _key = 'wishlist:snapshot';

  final CacheStore _cache;

  /// Synchronous, so the badge and the first frame need no await.
  WishlistModel? read() => _cache.read<WishlistModel>(
        _key,
        (json) => WishlistModel.fromJson(json! as Map<String, dynamic>),
      );

  Future<void> write(WishlistModel wishlist) =>
      _cache.write(_key, wishlist.toJson());

  Future<void> clear() => _cache.delete(_key);

  DateTime? get savedAt => _cache.savedAt(_key);
}
