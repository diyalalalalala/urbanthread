import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Loads a product page by slug.
///
/// The parameter is a slug and not an id on purpose — the backend registers
/// no `/products/:id` route, and an ObjectId here comes back as a 404 that
/// reads like missing data rather than a wrong lookup key.
class GetProductDetailUseCase extends UseCase<Product, String> {
  const GetProductDetailUseCase(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<Product>> call(String params) =>
      _repository.getProductBySlug(params);
}
