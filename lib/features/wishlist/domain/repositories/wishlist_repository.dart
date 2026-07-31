import '../../../../core/domain/result.dart';
import '../entities/wishlist.dart';
import '../entities/wishlist_move_result.dart';

abstract interface class WishlistRepository {
  Future<Result<Wishlist>> getWishlist();

  Wishlist? get cachedWishlist;

  Future<Result<Wishlist>> addItem({
    required String productId,
    String? variantId,
  });

  Future<Result<Wishlist>> removeItem(String productId);

  Future<Result<Wishlist>> clear();

  Future<Result<WishlistMoveResult>> moveToCart({
    required String productId,
    String? variantId,
  });

  Future<Result<bool>> isSaved(String productId);

  Future<Result<Wishlist>> syncPendingWrites();

  int get pendingWriteCount;
}
