import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_envelope.dart';
import '../models/review_model.dart';

part 'review_remote_datasource.g.dart';

/// The read side of `/reviews`, as the product page consumes it.
///
/// Only the two public, unauthenticated routes are declared. Posting a review
/// is gated behind `requireVerifiedEmail` and belongs to the account feature;
/// leaving it out keeps this datasource usable from a signed-out product page.
@RestApi()
abstract class ReviewRemoteDataSource {
  factory ReviewRemoteDataSource(Dio dio, {String baseUrl}) =
      _ReviewRemoteDataSource;

  /// Approved reviews for a product, paginated. Accepts `page`, `limit`,
  /// `rating`, `verified` and `sort`.
  @GET('/reviews/product/{productId}')
  Future<ApiEnvelope<List<ReviewModel>>> getProductReviews(
    @Path('productId') String productId,
    @Queries() Map<String, dynamic> query,
  );

  /// `{average, count, distribution}`, recomputed per request.
  @GET('/reviews/product/{productId}/stats')
  Future<ApiEnvelope<ReviewStatsModel>> getProductReviewStats(
    @Path('productId') String productId,
  );
}
