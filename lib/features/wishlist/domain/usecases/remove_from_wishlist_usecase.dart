import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/wishlist.dart';
import '../repositories/wishlist_repository.dart';

/// Removes a saved product. Takes the **product** id — the wishlist line id
/// addresses nothing on this API.
class RemoveFromWishlistUseCase extends UseCase<Wishlist, String> {
  const RemoveFromWishlistUseCase(this._repository);

  final WishlistRepository _repository;

  @override
  Future<Result<Wishlist>> call(String productId) =>
      _repository.removeItem(productId);
}
