import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/usecase.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasource/product_local_datasource.dart';
import '../../data/datasource/product_remote_datasource.dart';
import '../../data/datasource/review_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_filters.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/review_repository.dart';
import '../../domain/usecases/get_frequently_bought_together_usecase.dart';
import '../../domain/usecases/get_product_collection_usecase.dart';
import '../../domain/usecases/get_product_detail_usecase.dart';
import '../../domain/usecases/get_product_filters_usecase.dart';
import '../../domain/usecases/get_product_review_stats_usecase.dart';
import '../../domain/usecases/get_product_reviews_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/get_related_products_usecase.dart';
import '../../domain/usecases/refresh_catalogue_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';

part 'product_providers.g.dart';

@Riverpod(keepAlive: true)
ProductRemoteDataSource productRemoteDataSource(Ref ref) =>
    ProductRemoteDataSource(ref.watch(dioProvider));

@Riverpod(keepAlive: true)
ReviewRemoteDataSource reviewRemoteDataSource(Ref ref) =>
    ReviewRemoteDataSource(ref.watch(dioProvider));

@Riverpod(keepAlive: true)
ProductLocalDataSource productLocalDataSource(Ref ref) =>
    ProductLocalDataSource(ref.watch(catalogueCacheProvider));

@Riverpod(keepAlive: true)
ProductRepository productRepository(Ref ref) => ProductRepositoryImpl(
      remote: ref.watch(productRemoteDataSourceProvider),
      local: ref.watch(productLocalDataSourceProvider),
      networkInfo: ref.watch(networkInfoProvider),
    );

@Riverpod(keepAlive: true)
ReviewRepository reviewRepository(Ref ref) => ReviewRepositoryImpl(
      remote: ref.watch(reviewRemoteDataSourceProvider),
      networkInfo: ref.watch(networkInfoProvider),
    );

@riverpod
GetProductsUseCase getProductsUseCase(Ref ref) =>
    GetProductsUseCase(ref.watch(productRepositoryProvider));

@riverpod
SearchProductsUseCase searchProductsUseCase(Ref ref) =>
    SearchProductsUseCase(ref.watch(productRepositoryProvider));

@riverpod
GetProductFiltersUseCase getProductFiltersUseCase(Ref ref) =>
    GetProductFiltersUseCase(ref.watch(productRepositoryProvider));

@riverpod
GetProductCollectionUseCase getProductCollectionUseCase(Ref ref) =>
    GetProductCollectionUseCase(ref.watch(productRepositoryProvider));

@riverpod
GetProductDetailUseCase getProductDetailUseCase(Ref ref) =>
    GetProductDetailUseCase(ref.watch(productRepositoryProvider));

@riverpod
GetRelatedProductsUseCase getRelatedProductsUseCase(Ref ref) =>
    GetRelatedProductsUseCase(ref.watch(productRepositoryProvider));

@riverpod
GetFrequentlyBoughtTogetherUseCase getFrequentlyBoughtTogetherUseCase(Ref ref) =>
    GetFrequentlyBoughtTogetherUseCase(ref.watch(productRepositoryProvider));

@riverpod
RefreshCatalogueUseCase refreshCatalogueUseCase(Ref ref) =>
    RefreshCatalogueUseCase(ref.watch(productRepositoryProvider));

@riverpod
GetProductReviewsUseCase getProductReviewsUseCase(Ref ref) =>
    GetProductReviewsUseCase(ref.watch(reviewRepositoryProvider));

@riverpod
GetProductReviewStatsUseCase getProductReviewStatsUseCase(Ref ref) =>
    GetProductReviewStatsUseCase(ref.watch(reviewRepositoryProvider));

@Riverpod(keepAlive: true)
Future<ProductFilters> productFilterFacets(Ref ref) async {
  final result = await ref.watch(getProductFiltersUseCaseProvider)(
    const NoParams(),
  );
  return result.fold(
    onSuccess: (filters) => filters,
    onFailure: (failure) => throw failure,
  );
}

@riverpod
Future<List<Product>> productCollection(
  Ref ref,
  ProductCollection collection, {
  int limit = 10,
}) async {
  final result = await ref.watch(getProductCollectionUseCaseProvider)(
    ProductCollectionParams(collection, limit: limit),
  );
  return result.fold(
    onSuccess: (products) => products,
    onFailure: (failure) => throw failure,
  );
}

@riverpod
Future<List<Product>> relatedProducts(Ref ref, String productId) async {
  final result = await ref.watch(getRelatedProductsUseCaseProvider)(
    RelatedProductsParams(productId),
  );
  return result.fold(
    onSuccess: (products) => products,
    onFailure: (failure) => throw failure,
  );
}

@riverpod
Future<List<FrequentlyBoughtTogether>> frequentlyBoughtTogether(
  Ref ref,
  String productId,
) async {
  final result = await ref.watch(getFrequentlyBoughtTogetherUseCaseProvider)(
    FrequentlyBoughtTogetherParams(productId),
  );
  return result.fold(
    onSuccess: (entries) => entries,
    onFailure: (failure) => throw failure,
  );
}

@riverpod
Future<ReviewStats> productReviewStats(Ref ref, String productId) async {
  final result = await ref.watch(getProductReviewStatsUseCaseProvider)(
    productId,
  );
  return result.fold(
    onSuccess: (stats) => stats,
    onFailure: (failure) => throw failure,
  );
}
