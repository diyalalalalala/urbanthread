import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/wishlist.dart';
import '../repositories/wishlist_repository.dart';

class AddToWishlistParams {
  const AddToWishlistParams({required this.productId, this.variantId});

  final String productId;

  /// Optional preferred variant, so a later move-to-cart can skip the size
  /// picker. Omitted rather than sent as null when absent.
  final String? variantId;
}

/// Saves a product. Idempotent, and answers 200 rather than the 201 a create
/// would normally use.
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
