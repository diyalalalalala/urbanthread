import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_envelope.dart';
import '../models/product_filters_model.dart';
import '../models/product_model.dart';

part 'product_remote_datasource.g.dart';

/// Typed HTTP surface for the catalogue.
///
/// Query parameters go through a `@Queries()` map rather than a long list of
/// named `@Query` arguments. The API silently drops any parameter its
/// validator does not know, so a filter fails *open* and returns the whole
/// catalogue — building the map in exactly one place ([ProductQuery]) makes
/// that class the single source of the parameter names, instead of scattering
/// them across a method signature that is easy to typo.
@RestApi()
abstract class ProductRemoteDataSource {
  factory ProductRemoteDataSource(Dio dio, {String baseUrl}) =
      _ProductRemoteDataSource;

  /// Paginated catalogue listing. `meta` is on the envelope.
  @GET(ApiEndpoints.products)
  Future<ApiEnvelope<List<ProductModel>>> getProducts(
    @Queries() Map<String, dynamic> query,
  );

  /// Same shape as [getProducts], but a missing or blank `search` is a 400.
  @GET(ApiEndpoints.productSearch)
  Future<ApiEnvelope<List<ProductModel>>> searchProducts(
    @Queries() Map<String, dynamic> query,
  );

  @GET(ApiEndpoints.productFilters)
  Future<ApiEnvelope<ProductFiltersModel>> getFilters();

  // The four collection routes below return a **bare array** with no `meta`,
  // and accept only `limit` (1–50, default 10). They are separate endpoints
  // rather than `/products?isFeatured=true` because trending and best-selling
  // are ranked server-side by signals that are not exposed as filters.

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

  /// Detail. Slug-only — an ObjectId here is a 404.
  @GET('/products/{slug}')
  Future<ApiEnvelope<ProductModel>> getProductBySlug(
    @Path('slug') String slug,
  );

  /// Takes a real ObjectId, unlike detail.
  @GET('/products/{id}/related')
  Future<ApiEnvelope<List<ProductModel>>> getRelated(
    @Path('id') String id,
    @Query('limit') int limit,
  );

  /// Returns wrappers, not products: `{coPurchaseCount, product}`.
  @GET('/products/{id}/frequently-bought-together')
  Future<ApiEnvelope<List<FrequentlyBoughtTogetherModel>>>
      getFrequentlyBoughtTogether(
    @Path('id') String id,
    @Query('limit') int limit,
  );
}
