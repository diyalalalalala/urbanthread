import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_envelope.dart';
import '../models/home_product_model.dart';

part 'home_remote_datasource.g.dart';

@RestApi()
abstract class HomeRemoteDataSource {
  factory HomeRemoteDataSource(Dio dio, {String baseUrl}) =
      _HomeRemoteDataSource;

  @GET(ApiEndpoints.featuredProducts)
  Future<ApiEnvelope<List<HomeProductModel>>> getFeatured({
    @Query('limit') int? limit,
  });

  @GET(ApiEndpoints.trendingProducts)
  Future<ApiEnvelope<List<HomeProductModel>>> getTrending({
    @Query('limit') int? limit,
  });

  @GET(ApiEndpoints.bestSellerProducts)
  Future<ApiEnvelope<List<HomeProductModel>>> getBestSellers({
    @Query('limit') int? limit,
  });

  @GET(ApiEndpoints.newArrivalProducts)
  Future<ApiEnvelope<List<HomeProductModel>>> getNewArrivals({
    @Query('limit') int? limit,
  });
}
