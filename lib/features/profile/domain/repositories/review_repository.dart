import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../entities/review.dart';
import '../entities/reviewable_product.dart';

abstract interface class ReviewRepository {
  Future<Result<Paginated<Review>>> getMyReviews({int page = 1, int limit = 10});

  Future<Result<List<ReviewableProduct>>> getReviewableProducts();

  Future<Result<Review>> createReview({
    required String productId,
    required int rating,
    required String comment,
    String? title,
  });

  Future<Result<Review>> updateReview({
    required String reviewId,
    int? rating,
    String? title,
    String? comment,
  });

  Future<Result<void>> deleteReview(String reviewId);
}
