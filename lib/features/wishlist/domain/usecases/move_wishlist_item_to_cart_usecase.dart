import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/wishlist_move_result.dart';
import '../repositories/wishlist_repository.dart';

class MoveWishlistItemToCartParams {
  const MoveWishlistItemToCartParams({required this.productId, this.variantId});

  final String productId;

  /// Overrides the variant saved with the item. Required in practice whenever
  /// the item was saved without one, since the cart tracks stock per variant.
  final String? variantId;
}

/// Buys one of a saved product: adds it to the cart, then unsaves it.
///
/// The order matters and is the server's, not ours — the cart add happens
/// first, so an out-of-stock product stays in the wishlist instead of being
/// silently lost.
class MoveWishlistItemToCartUseCase
    extends UseCase<WishlistMoveResult, MoveWishlistItemToCartParams> {
  const MoveWishlistItemToCartUseCase(this._repository);

  final WishlistRepository _repository;

  @override
  Future<Result<WishlistMoveResult>> call(
    MoveWishlistItemToCartParams params,
  ) =>
      _repository.moveToCart(
        productId: params.productId,
        variantId: params.variantId,
      );
}
