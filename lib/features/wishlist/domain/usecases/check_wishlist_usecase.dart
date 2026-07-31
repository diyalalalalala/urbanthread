import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../repositories/wishlist_repository.dart';

class CheckWishlistUseCase extends UseCase<bool, String> {
  const CheckWishlistUseCase(this._repository);

  final WishlistRepository _repository;

  @override
  Future<Result<bool>> call(String productId) => _repository.isSaved(productId);
}
