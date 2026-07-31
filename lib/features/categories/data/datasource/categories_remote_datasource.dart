import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_envelope.dart';
import '../models/brand_model.dart';
import '../models/category_model.dart';

part 'categories_remote_datasource.g.dart';

@RestApi()
abstract class CategoriesRemoteDataSource {
  factory CategoriesRemoteDataSource(Dio dio, {String baseUrl}) =
      _CategoriesRemoteDataSource;

  @GET(ApiEndpoints.categories)
  Future<ApiEnvelope<List<CategoryModel>>> getCategories({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('search') String? search,
    @Query('parent') String? parent,
    @Query('isFeatured') bool? isFeatured,
  });

  @GET(ApiEndpoints.categoryTree)
  Future<ApiEnvelope<List<CategoryNodeModel>>> getCategoryTree();

  @GET('/categories/{slugOrId}')
  Future<ApiEnvelope<CategoryNodeModel>> getCategory(
    @Path('slugOrId') String slugOrId,
  );

  @GET(ApiEndpoints.brands)
  Future<ApiEnvelope<List<BrandModel>>> getBrands({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('search') String? search,
    @Query('isFeatured') bool? isFeatured,
  });

  @GET(ApiEndpoints.featuredBrands)
  Future<ApiEnvelope<List<BrandModel>>> getFeaturedBrands({
    @Query('limit') int? limit,
  });

  @GET('/brands/{slugOrId}')
  Future<ApiEnvelope<BrandModel>> getBrand(@Path('slugOrId') String slugOrId);
}
