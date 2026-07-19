import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/product.dart';
import '../entities/product_query.dart';
import '../repositories/product_repository.dart';

/// Fetches one page of the catalogue for the given query.
class GetProductsUseCase extends UseCase<Paginated<Product>, ProductQuery> {
  const GetProductsUseCase(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<Paginated<Product>>> call(ProductQuery params) =>
      _repository.getProducts(params);
}
