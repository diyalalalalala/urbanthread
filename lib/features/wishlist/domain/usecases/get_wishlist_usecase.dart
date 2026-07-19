import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/wishlist.dart';
import '../repositories/wishlist_repository.dart';

/// Reads the wishlist, falling back to the cached copy when offline.
class GetWishlistUseCase extends UseCase<Wishlist, NoParams> {
  const GetWishlistUseCase(this._repository);

  final WishlistRepository _repository;

  @override
  Future<Result<Wishlist>> call(NoParams params) => _repository.getWishlist();
}
