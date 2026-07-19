import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/home_product.dart';
import '../repositories/home_repository.dart';

class ProductCollectionParams {
  const ProductCollectionParams(this.collection, {this.limit = defaultLimit});

  /// The server's own default for these routes. Ten fills a horizontal rail
  /// on every supported width without paying for cards nobody scrolls to.
  /// Note the featured *brands* route defaults to 12 instead.
  static const defaultLimit = 10;

  final HomeCollection collection;

  /// Rejected outright above 50 — the validator does not clamp.
  final int limit;
}

/// Loads one merchandising rail.
class GetProductCollectionUseCase
    extends UseCase<List<HomeProduct>, ProductCollectionParams> {
  const GetProductCollectionUseCase(this._repository);

  final HomeRepository _repository;

  @override
  Future<Result<List<HomeProduct>>> call(ProductCollectionParams params) =>
      _repository.getCollection(params.collection, limit: params.limit);
}
