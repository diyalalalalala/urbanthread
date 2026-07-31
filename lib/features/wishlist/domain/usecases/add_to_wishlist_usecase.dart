import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/wishlist.dart';
import '../repositories/wishlist_repository.dart';

class AddToWishlistParams {
  const AddToWishlistParams({required this.productId, this.variantId});

  final String productId;

  final String? variantId;
}

class AddToWishlistUseCase extends UseCase<Wishlist, AddToWishlistParams> {
  const AddToWishlistUseCase(this._repository);

  final WishlistRepository _repository;

  @override
  Future<Result<Wishlist>> call(AddToWishlistParams params) =>
      _repository.addItem(
        productId: params.productId,
        variantId: params.variantId,
      );
}
