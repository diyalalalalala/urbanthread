import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../../domain/entities/brand.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/get_brands_usecase.dart';
import 'categories_providers.dart';
import 'categories_state.dart';

part 'categories_notifier.g.dart';

@riverpod
class CategoriesNotifier extends _$CategoriesNotifier {
  static const brandPageSize = 50;

  bool _disposed = false;

  @override
  CategoriesState build() {
    ref.onDispose(() => _disposed = true);

    final repository = ref.watch(categoriesRepositoryProvider);

    final cachedTree = repository.cachedCategoryTree();
    final cachedBrands = repository.cachedBrands();

    unawaited(_fetch());

    if (cachedTree.isEmpty && cachedBrands.isEmpty) {
      return const CategoriesState.loading();
    }
    return CategoriesState.fromCache(tree: cachedTree, brands: cachedBrands);
  }

  Future<void> refresh() async {
    state = state.copyWith(
      isRefreshing: true,
      clearTreeFailure: true,
      clearBrandsFailure: true,
    );
    await _fetch();
  }

  Future<void> _fetch() async {
    final (treeResult, brandsResult) = await (
      ref.read(getCategoryTreeUseCaseProvider)(const NoParams()),
      ref.read(getBrandsUseCaseProvider)(
        const GetBrandsParams(limit: brandPageSize),
      ),
    ).wait;

    if (_disposed) return;

    var next = state.copyWith(
      isLoading: false,
      isRefreshing: false,
      isFromCache: false,
    );

    switch (treeResult) {
      case Success(:final value):
        next = next.copyWith(tree: value, clearTreeFailure: true);
      case FailureResult(:final failure):
        next = next.copyWith(treeFailure: failure);
    }

    switch (brandsResult) {
      case Success(:final value):
        next = next.copyWith(brands: value.items, clearBrandsFailure: true);
      case FailureResult(:final failure):
        next = next.copyWith(brandsFailure: failure);
    }

    state = next;
  }
}

@riverpod
List<Category> featuredCategoryNodes(Ref ref) => [
      for (final node in ref.watch(categoriesProvider).tree)
        if (node.category.isFeatured) node.category,
    ];

@riverpod
List<Brand> featuredBrandsFromDirectory(Ref ref) => [
      for (final brand in ref.watch(categoriesProvider).brands)
        if (brand.isFeatured) brand,
    ];
