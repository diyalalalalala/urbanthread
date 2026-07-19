import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasource/categories_local_datasource.dart';
import '../../data/datasource/categories_remote_datasource.dart';
import '../../data/repositories/categories_repository_impl.dart';
import '../../domain/entities/brand.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/categories_repository.dart';
import '../../domain/usecases/get_brand_usecase.dart';
import '../../domain/usecases/get_brands_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_category_tree_usecase.dart';
import '../../domain/usecases/get_category_usecase.dart';
import '../../domain/usecases/get_featured_brands_usecase.dart';
import '../../domain/usecases/get_featured_categories_usecase.dart';

part 'categories_providers.g.dart';

/// Wiring for the taxonomy feature.
///
/// The datasources and repository are kept alive: the tree and the brand list
/// are read by both the categories screen and the home feed, and letting them
/// dispose between tab switches would rebuild the Retrofit client and re-open
/// the cache handle for no gain.

@Riverpod(keepAlive: true)
CategoriesRemoteDataSource categoriesRemoteDataSource(Ref ref) =>
    CategoriesRemoteDataSource(ref.watch(dioProvider));

@Riverpod(keepAlive: true)
CategoriesLocalDataSource categoriesLocalDataSource(Ref ref) =>
    CategoriesLocalDataSource(ref.watch(catalogueCacheProvider));

@Riverpod(keepAlive: true)
CategoriesRepository categoriesRepository(Ref ref) => CategoriesRepositoryImpl(
      remote: ref.watch(categoriesRemoteDataSourceProvider),
      local: ref.watch(categoriesLocalDataSourceProvider),
      networkInfo: ref.watch(networkInfoProvider),
    );

@riverpod
GetCategoriesUseCase getCategoriesUseCase(Ref ref) =>
    GetCategoriesUseCase(ref.watch(categoriesRepositoryProvider));

@riverpod
GetCategoryTreeUseCase getCategoryTreeUseCase(Ref ref) =>
    GetCategoryTreeUseCase(ref.watch(categoriesRepositoryProvider));

@riverpod
GetCategoryUseCase getCategoryUseCase(Ref ref) =>
    GetCategoryUseCase(ref.watch(categoriesRepositoryProvider));

@riverpod
GetFeaturedCategoriesUseCase getFeaturedCategoriesUseCase(Ref ref) =>
    GetFeaturedCategoriesUseCase(ref.watch(categoriesRepositoryProvider));

@riverpod
GetBrandsUseCase getBrandsUseCase(Ref ref) =>
    GetBrandsUseCase(ref.watch(categoriesRepositoryProvider));

@riverpod
GetFeaturedBrandsUseCase getFeaturedBrandsUseCase(Ref ref) =>
    GetFeaturedBrandsUseCase(ref.watch(categoriesRepositoryProvider));

@riverpod
GetBrandUseCase getBrandUseCase(Ref ref) =>
    GetBrandUseCase(ref.watch(categoriesRepositoryProvider));

/// One category with its immediate children, for a category landing screen.
///
/// Keyed on the slug-or-id the caller holds; the backend resolves either, so
/// there is no need for two providers.
///
/// One-shot detail reads surface as [AsyncValue], so the [Failure] is thrown
/// rather than returned. It stays a `Failure` on the way out — the UI matches
/// on `error is Failure` and hands it straight to `FailureView`, so nothing is
/// lost by the trip through the error channel.
@riverpod
Future<CategoryNode> categoryDetail(Ref ref, String slugOrId) async {
  final result = await ref.watch(getCategoryUseCaseProvider)(slugOrId);
  return switch (result) {
    Success(:final value) => value,
    FailureResult(:final failure) => throw failure,
  };
}

@riverpod
Future<Brand> brandDetail(Ref ref, String slugOrId) async {
  final result = await ref.watch(getBrandUseCaseProvider)(slugOrId);
  return switch (result) {
    Success(:final value) => value,
    FailureResult(:final failure) => throw failure,
  };
}

/// The direct children of a category, paged.
///
/// Used by the two-pane browser when a branch is deep enough that the tree
/// response alone would be an awkward amount to render at once.
@riverpod
Future<List<Category>> categoryChildren(Ref ref, String parentId) async {
  final result = await ref.watch(getCategoriesUseCaseProvider)(
    GetCategoriesParams.childrenOf(parentId),
  );
  return switch (result) {
    Success(:final value) => value.items,
    FailureResult(:final failure) => throw failure,
  };
}
