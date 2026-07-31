import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_envelope.dart';
import '../models/review_model.dart';

part 'review_remote_datasource.g.dart';

@RestApi()
abstract class ReviewRemoteDataSource {
  factory ReviewRemoteDataSource(Dio dio, {String baseUrl}) =
      _ReviewRemoteDataSource;

  @GET('/reviews/product/{productId}')
  Future<ApiEnvelope<List<ReviewModel>>> getProductReviews(
    @Path('productId') String productId,
    @Queries() Map<String, dynamic> query,
  );

  @GET('/reviews/product/{productId}/stats')
  Future<ApiEnvelope<ReviewStatsModel>> getProductReviewStats(
    @Path('productId') String productId,
  );
}
