import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_envelope.dart';
import '../models/brand_model.dart';
import '../models/category_model.dart';

part 'categories_remote_datasource.g.dart';

/// Typed HTTP surface for `/categories` and `/brands`.
///
/// Two response shapes live here and they are not interchangeable:
/// `/categories` and `/brands` are paginated (`data` is an array, `meta` is
/// present), while `/categories/tree` and `/brands/featured` return a **bare
/// array with no `meta` at all**. Both decode into `ApiEnvelope<List<…>>`;
/// only the repository's handling of `meta` differs.
///
/// Every query parameter name below is exact on purpose. The backend's
/// validator drops unknown keys silently, so a misspelled filter does not
/// error — it returns the unfiltered catalogue, which is far harder to notice.
@RestApi()
abstract class CategoriesRemoteDataSource {
  factory CategoriesRemoteDataSource(Dio dio, {String baseUrl}) =
      _CategoriesRemoteDataSource;

  /// Paginated. Ordered by `displayOrder` then `name` — there is no `sort`
  /// parameter to pass.
  ///
  /// [parent] is either an ObjectId or the literal string `"root"`, which the
  /// validator special-cases to mean "top-level only".
  @GET(ApiEndpoints.categories)
  Future<ApiEnvelope<List<CategoryModel>>> getCategories({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('search') String? search,
    @Query('parent') String? parent,
    @Query('isFeatured') bool? isFeatured,
  });

  /// Recursively nested roots. Takes no parameters and carries no `meta`.
  @GET(ApiEndpoints.categoryTree)
  Future<ApiEnvelope<List<CategoryNodeModel>>> getCategoryTree();

  /// Accepts a slug or an ObjectId; the backend tries slug first. The
  /// response carries `children` populated one level deep and flat.
  @GET('/categories/{slugOrId}')
  Future<ApiEnvelope<CategoryNodeModel>> getCategory(
    @Path('slugOrId') String slugOrId,
  );

  /// Paginated. No `sort` parameter here either.
  @GET(ApiEndpoints.brands)
  Future<ApiEnvelope<List<BrandModel>>> getBrands({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('search') String? search,
    @Query('isFeatured') bool? isFeatured,
  });

  /// Bare array. `limit` is the only parameter and defaults to **12** —
  /// not 10, which is what the product collection routes default to.
  @GET(ApiEndpoints.featuredBrands)
  Future<ApiEnvelope<List<BrandModel>>> getFeaturedBrands({
    @Query('limit') int? limit,
  });

  @GET('/brands/{slugOrId}')
  Future<ApiEnvelope<BrandModel>> getBrand(@Path('slugOrId') String slugOrId);
}
