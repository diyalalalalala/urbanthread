import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class ProductCollectionParams {
  const ProductCollectionParams(this.collection, {this.limit = 10});

  final ProductCollection collection;

  /// The API clamps this to 1–50 and 422s outside that range.
  final int limit;
}

/// Loads one of the curated home-page collections.
class GetProductCollectionUseCase
    extends UseCase<List<Product>, ProductCollectionParams> {
  const GetProductCollectionUseCase(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<List<Product>>> call(ProductCollectionParams params) =>
      _repository.getCollection(params.collection, limit: params.limit);
}
