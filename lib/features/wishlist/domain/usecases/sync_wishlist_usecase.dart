import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/wishlist.dart';
import '../repositories/wishlist_repository.dart';

class SyncWishlistUseCase extends UseCase<Wishlist, NoParams> {
  const SyncWishlistUseCase(this._repository);

  final WishlistRepository _repository;

  @override
  Future<Result<Wishlist>> call(NoParams params) =>
      _repository.syncPendingWrites();
}
