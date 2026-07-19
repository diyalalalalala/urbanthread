import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

class ProductReviewsParams {
  const ProductReviewsParams(this.productId, this.query);

  final String productId;
  final ReviewQuery query;
}

/// Loads a page of reviews for the product page.
class GetProductReviewsUseCase
    extends UseCase<Paginated<Review>, ProductReviewsParams> {
  const GetProductReviewsUseCase(this._repository);

  final ReviewRepository _repository;

  @override
  Future<Result<Paginated<Review>>> call(ProductReviewsParams params) =>
      _repository.getProductReviews(params.productId, params.query);
}
