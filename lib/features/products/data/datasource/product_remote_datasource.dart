import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_envelope.dart';
import '../models/product_filters_model.dart';
import '../models/product_model.dart';

part 'product_remote_datasource.g.dart';

@RestApi()
abstract class ProductRemoteDataSource {
  factory ProductRemoteDataSource(Dio dio, {String baseUrl}) =
      _ProductRemoteDataSource;

  @GET(ApiEndpoints.products)
  Future<ApiEnvelope<List<ProductModel>>> getProducts(
    @Queries() Map<String, dynamic> query,
  );

  @GET(ApiEndpoints.productSearch)
  Future<ApiEnvelope<List<ProductModel>>> searchProducts(
    @Queries() Map<String, dynamic> query,
  );

  @GET(ApiEndpoints.productFilters)
  Future<ApiEnvelope<ProductFiltersModel>> getFilters();

  @GET(ApiEndpoints.featuredProducts)
  Future<ApiEnvelope<List<ProductModel>>> getFeatured(
    @Query('limit') int limit,
  );

  @GET(ApiEndpoints.trendingProducts)
  Future<ApiEnvelope<List<ProductModel>>> getTrending(
    @Query('limit') int limit,
  );

  @GET(ApiEndpoints.bestSellerProducts)
  Future<ApiEnvelope<List<ProductModel>>> getBestSellers(
    @Query('limit') int limit,
  );

  @GET(ApiEndpoints.newArrivalProducts)
  Future<ApiEnvelope<List<ProductModel>>> getNewArrivals(
    @Query('limit') int limit,
  );

  @GET('/products/{slug}')
  Future<ApiEnvelope<ProductModel>> getProductBySlug(
    @Path('slug') String slug,
  );

  @GET('/products/{id}/related')
  Future<ApiEnvelope<List<ProductModel>>> getRelated(
    @Path('id') String id,
    @Query('limit') int limit,
  );

  @GET('/products/{id}/frequently-bought-together')
  Future<ApiEnvelope<List<FrequentlyBoughtTogetherModel>>>
      getFrequentlyBoughtTogether(
    @Path('id') String id,
    @Query('limit') int limit,
  );
}
