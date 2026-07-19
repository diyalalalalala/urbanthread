import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../entities/review.dart';

/// The read side of reviews, as the product page needs it.
///
/// Writing a review is gated behind `isEmailVerified` and belongs to the
/// account feature; this interface is deliberately read-only so the product
/// page cannot acquire a dependency on that gate.
abstract interface class ReviewRepository {
  /// A page of approved reviews for a product.
  Future<Result<Paginated<Review>>> getProductReviews(
    String productId,
    ReviewQuery query,
  );

  /// The rating summary — average, count and the 1–5 histogram.
  ///
  /// Fetched separately from the product document because it is recomputed
  /// per request, whereas `product.rating` is a denormalised copy that can
  /// lag behind a just-posted review.
  Future<Result<ReviewStats>> getProductReviewStats(String productId);
}
