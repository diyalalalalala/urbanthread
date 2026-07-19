import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class FrequentlyBoughtTogetherParams {
  const FrequentlyBoughtTogetherParams(this.productId, {this.limit = 6});

  /// A real ObjectId, like related products.
  final String productId;
  final int limit;
}

/// Loads products commonly bought in the same order as this one.
class GetFrequentlyBoughtTogetherUseCase extends UseCase<
    List<FrequentlyBoughtTogether>, FrequentlyBoughtTogetherParams> {
  const GetFrequentlyBoughtTogetherUseCase(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<List<FrequentlyBoughtTogether>>> call(
    FrequentlyBoughtTogetherParams params,
  ) =>
      _repository.getFrequentlyBoughtTogether(
        params.productId,
        limit: params.limit,
      );
}
