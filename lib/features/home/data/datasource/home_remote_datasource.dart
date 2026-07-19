import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_envelope.dart';
import '../models/home_product_model.dart';

part 'home_remote_datasource.g.dart';

/// The four catalogue collection endpoints the storefront is built from.
///
/// All four are the same shape: `data` is a **bare array** with no `meta`,
/// and `limit` (1–50, default 10) is the only parameter they accept. They are
/// separate routes rather than sorts on `/products` because the ordering is
/// computed server-side from sales and recency.
///
/// Everything they return is a `.lean()` read, which is why the `primaryImage`
/// and `inStock` virtuals never appear in these payloads.
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
