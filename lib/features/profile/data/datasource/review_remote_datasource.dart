import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_envelope.dart';
import '../models/review_model.dart';

part 'review_remote_datasource.g.dart';

/// Typed HTTP surface for the customer's own reviews.
@RestApi()
abstract class ReviewRemoteDataSource {
  factory ReviewRemoteDataSource(Dio dio, {String baseUrl}) =
      _ReviewRemoteDataSource;

  /// Paginated, newest first, with `product` populated as
  /// `{name, slug, images, price}`.
  @GET(ApiEndpoints.myReviews)
  Future<ApiEnvelope<List<ReviewModel>>> getMyReviews({
    @Query('page') int? page,
    @Query('limit') int? limit,
  });

  /// A bare array capped at 50 — no `meta`, and the rows carry no `_id`.
  @GET(ApiEndpoints.reviewableProducts)
  Future<ApiEnvelope<List<ReviewableProductModel>>> getReviewableProducts();

  /// 201 on success. **409** when this customer already reviewed the product,
  /// and 403 when their email is not verified.
  @POST(ApiEndpoints.reviews)
  Future<ApiEnvelope<ReviewModel>> createReview(
    @Body() CreateReviewRequest request,
  );

  @PATCH('/reviews/{id}')
  Future<ApiEnvelope<ReviewModel>> updateReview(
    @Path('id') String id,
    @Body() UpdateReviewRequest request,
  );

  /// 204, no body.
  @DELETE('/reviews/{id}')
  Future<void> deleteReview(@Path('id') String id);
}
