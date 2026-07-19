import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../repositories/product_repository.dart';

/// Drops the cached catalogue pages so the next read goes to the network.
///
/// Exists as a use case rather than a direct repository call because
/// pull-to-refresh happens in the presentation layer, which is not allowed to
/// hold a repository — and because "refresh" is an application action in its
/// own right, not an implementation detail of listing products.
class RefreshCatalogueUseCase extends UseCase<void, NoParams> {
  const RefreshCatalogueUseCase(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) async {
    await _repository.invalidateListCache();
    return const Result.success(null);
  }
}
