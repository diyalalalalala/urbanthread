import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class RelatedProductsParams {
  const RelatedProductsParams(this.productId, {this.limit = 8});

  final String productId;
  final int limit;
}

class GetRelatedProductsUseCase
    extends UseCase<List<Product>, RelatedProductsParams> {
  const GetRelatedProductsUseCase(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<List<Product>>> call(RelatedProductsParams params) =>
      _repository.getRelatedProducts(params.productId, limit: params.limit);
}
