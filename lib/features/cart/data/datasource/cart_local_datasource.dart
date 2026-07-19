import '../../../../core/storage/cache_store.dart';
import '../models/cart_models.dart';

/// The cart's mirror on disk, in the `account` box.
///
/// Offline readability of the cart is a product requirement, not an
/// optimisation: the customer must be able to open the app on a train and see
/// what they are about to buy. So the whole `{cart, notices, summary}` triple
/// is stored verbatim — including the notices, which explain why the cart
/// looks the way it does and would otherwise be lost the moment the app is
/// closed.
class CartLocalDataSource {
  const CartLocalDataSource(this._cache);

  /// One entry: there is exactly one cart per user, and `HiveBoxes` clears the
  /// whole account box on sign-out, so no user id has to be part of the key.
  static const _key = 'cart:snapshot';

  final CacheStore _cache;

  /// The cached cart, or null when nothing has been stored yet.
  ///
  /// Synchronous by design — the badge and the first frame of the cart page
  /// read it before any await, so a signed-in user never sees an empty cart
  /// flash before the network answers.
  CartSnapshotModel? read() => _cache.read<CartSnapshotModel>(
        _key,
        (json) => CartSnapshotModel.fromJson(json! as Map<String, dynamic>),
      );

  Future<void> write(CartSnapshotModel snapshot) =>
      _cache.write(_key, snapshot.toJson());

  Future<void> clear() => _cache.delete(_key);

  /// When the cart was last written. Lets the UI say "as of 20 minutes ago"
  /// instead of presenting stale prices as current.
  DateTime? get savedAt => _cache.savedAt(_key);
}
