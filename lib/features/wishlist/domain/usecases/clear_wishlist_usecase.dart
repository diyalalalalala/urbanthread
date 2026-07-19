import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/wishlist.dart';
import '../repositories/wishlist_repository.dart';

class ClearWishlistUseCase extends UseCase<Wishlist, NoParams> {
  const ClearWishlistUseCase(this._repository);

  final WishlistRepository _repository;

  @override
  Future<Result<Wishlist>> call(NoParams params) => _repository.clear();
}
