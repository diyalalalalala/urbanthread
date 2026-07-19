import '../../../../core/domain/result.dart';
import '../entities/wishlist.dart';
import '../entities/wishlist_move_result.dart';

/// The wishlist contract the domain depends on.
///
/// Note that every mutation route keys off the **product** id, not the
/// wishlist line id — the line id exists in the payload but addresses nothing.
abstract interface class WishlistRepository {
  Future<Result<Wishlist>> getWishlist();

  /// The last wishlist written to disk, read synchronously — for the badge and
  /// the first frame.
  Wishlist? get cachedWishlist;

  /// Saves a product. Idempotent: re-adding one already saved is a no-op that
  /// returns the unchanged wishlist rather than a 409, because a heart button
  /// is easy to double-tap. Answers **200**, not 201.
  Future<Result<Wishlist>> addItem({
    required String productId,
    String? variantId,
  });

  /// Removes by product id.
  Future<Result<Wishlist>> removeItem(String productId);

  Future<Result<Wishlist>> clear();

  /// Adds one unit to the cart and drops the item from the wishlist. The cart
  /// side is attempted first, so a product that cannot be bought stays saved.
  Future<Result<WishlistMoveResult>> moveToCart({
    required String productId,
    String? variantId,
  });

  /// Whether a product is saved. Drives the filled/empty heart elsewhere in
  /// the app; answers from the cached wishlist when offline.
  Future<Result<bool>> isSaved(String productId);

  /// Replays writes queued while offline, then re-reads the wishlist.
  Future<Result<Wishlist>> syncPendingWrites();

  int get pendingWriteCount;
}
