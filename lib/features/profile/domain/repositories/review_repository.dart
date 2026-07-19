import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../entities/review.dart';
import '../entities/reviewable_product.dart';

/// The customer's own reviews.
///
/// Only the "mine" half of `/reviews` lives here — a product's public review
/// list belongs to the catalogue feature, and splitting them keeps the account
/// screens from depending on the product detail model.
abstract interface class ReviewRepository {
  /// `GET /reviews/my-reviews`, paginated, newest first.
  Future<Result<Paginated<Review>>> getMyReviews({int page = 1, int limit = 10});

  /// `GET /reviews/reviewable` — delivered items not yet reviewed. A bare
  /// array capped at 50, with no pagination to follow.
  Future<Result<List<ReviewableProduct>>> getReviewableProducts();

  /// `POST /reviews`. Requires a verified email, and answers **409** when the
  /// customer has already reviewed this product — one review per product per
  /// user is a hard backend constraint, not a UI convention.
  Future<Result<Review>> createReview({
    required String productId,
    required int rating,
    required String comment,
    String? title,
  });

  /// `PATCH /reviews/{id}`. Every field is optional, but an empty body is a
  /// 400, so the caller must supply at least one change.
  Future<Result<Review>> updateReview({
    required String reviewId,
    int? rating,
    String? title,
    String? comment,
  });

  /// `DELETE /reviews/{id}` — 204, no body.
  Future<Result<void>> deleteReview(String reviewId);
}
