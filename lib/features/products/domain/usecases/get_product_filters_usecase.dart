import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/product_filters.dart';
import '../repositories/product_repository.dart';

/// Loads the facet lists that populate the filter sheet.
class GetProductFiltersUseCase extends UseCase<ProductFilters, NoParams> {
  const GetProductFiltersUseCase(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<ProductFilters>> call(NoParams params) =>
      _repository.getFilters();
}
