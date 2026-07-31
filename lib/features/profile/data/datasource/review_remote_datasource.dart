import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_envelope.dart';
import '../models/review_model.dart';

part 'review_remote_datasource.g.dart';

@RestApi()
abstract class ReviewRemoteDataSource {
  factory ReviewRemoteDataSource(Dio dio, {String baseUrl}) =
      _ReviewRemoteDataSource;

  @GET(ApiEndpoints.myReviews)
  Future<ApiEnvelope<List<ReviewModel>>> getMyReviews({
    @Query('page') int? page,
    @Query('limit') int? limit,
  });

  @GET(ApiEndpoints.reviewableProducts)
  Future<ApiEnvelope<List<ReviewableProductModel>>> getReviewableProducts();

  @POST(ApiEndpoints.reviews)
  Future<ApiEnvelope<ReviewModel>> createReview(
    @Body() CreateReviewRequest request,
  );

  @PATCH('/reviews/{id}')
  Future<ApiEnvelope<ReviewModel>> updateReview(
    @Path('id') String id,
    @Body() UpdateReviewRequest request,
  );

  @DELETE('/reviews/{id}')
  Future<void> deleteReview(@Path('id') String id);
}
