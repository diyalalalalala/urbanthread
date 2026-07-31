import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/wishlist_move_result.dart';
import '../repositories/wishlist_repository.dart';

class MoveWishlistItemToCartParams {
  const MoveWishlistItemToCartParams({required this.productId, this.variantId});

  final String productId;

  final String? variantId;
}

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
