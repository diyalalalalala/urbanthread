import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../repositories/wishlist_repository.dart';

/// Whether a product is saved, for a heart button on a screen that has not
/// loaded the whole wishlist.
class CheckWishlistUseCase extends UseCase<bool, String> {
  const CheckWishlistUseCase(this._repository);

  final WishlistRepository _repository;

  @override
  Future<Result<bool>> call(String productId) => _repository.isSaved(productId);
}
