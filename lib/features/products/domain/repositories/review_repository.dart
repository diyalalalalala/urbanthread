import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../entities/review.dart';

abstract interface class ReviewRepository {
  Future<Result<Paginated<Review>>> getProductReviews(
    String productId,
    ReviewQuery query,
  );

  Future<Result<ReviewStats>> getProductReviewStats(String productId);
}
