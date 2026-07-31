import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../repositories/product_repository.dart';

class RefreshCatalogueUseCase extends UseCase<void, NoParams> {
  const RefreshCatalogueUseCase(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) async {
    await _repository.invalidateListCache();
    return const Result.success(null);
  }
}
