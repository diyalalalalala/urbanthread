import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductDetailUseCase extends UseCase<Product, String> {
  const GetProductDetailUseCase(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<Product>> call(String params) =>
      _repository.getProductBySlug(params);
}
