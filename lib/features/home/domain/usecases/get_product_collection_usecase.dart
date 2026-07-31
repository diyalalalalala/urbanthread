import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/home_product.dart';
import '../repositories/home_repository.dart';

class ProductCollectionParams {
  const ProductCollectionParams(this.collection, {this.limit = defaultLimit});

  static const defaultLimit = 10;

  final HomeCollection collection;

  final int limit;
}

class GetProductCollectionUseCase
    extends UseCase<List<HomeProduct>, ProductCollectionParams> {
  const GetProductCollectionUseCase(this._repository);

  final HomeRepository _repository;

  @override
  Future<Result<List<HomeProduct>>> call(ProductCollectionParams params) =>
      _repository.getCollection(params.collection, limit: params.limit);
}
