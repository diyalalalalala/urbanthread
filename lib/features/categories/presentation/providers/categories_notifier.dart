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

/// Drives the categories screen: the taxonomy tree and the brand directory.
///
/// The generator strips the `Notifier` suffix, so this is read as
/// `categoriesProvider`.
///
/// Two loads, one await. They are independent endpoints and neither depends
/// on the other's result, so running them serially would double the time to
/// first paint for no benefit — and would let a slow `/brands` hold the
/// taxonomy hostage.
@riverpod
class CategoriesNotifier extends _$CategoriesNotifier {
  /// How many brands the directory shows before the user has to search.
  ///
  /// This has to match the page size the local datasource reads back as "the
  /// first page", because the cache key encodes the limit — ask for a
  /// different size and the warm-start read misses every time.
  static const brandPageSize = 50;

  /// Set from `ref.onDispose`. The two requests can still be in flight when
  /// the user leaves the tab, and assigning to `state` after disposal throws.
  bool _disposed = false;

  @override
  CategoriesState build() {
    ref.onDispose(() => _disposed = true);

    final repository = ref.watch(categoriesRepositoryProvider);

    // Hive reads are synchronous, so the cache can be consulted before the
    // first frame rather than after it. If anything is stored the screen
    // opens populated and refreshes underneath; only a genuinely cold cache
    // ever shows a spinner.
    final cachedTree = repository.cachedCategoryTree();
    final cachedBrands = repository.cachedBrands();

    // Deliberately not awaited, and deliberately free of any `state` write
    // before its first suspension — touching `state` while `build` is still
    // running is an error.
    unawaited(_fetch());

    if (cachedTree.isEmpty && cachedBrands.isEmpty) {
      return const CategoriesState.loading();
    }
    return CategoriesState.fromCache(tree: cachedTree, brands: cachedBrands);
  }

  /// Re-fetches both sections. Wired to pull-to-refresh.
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
        // Keep whatever is already rendered. A refresh that fails should
        // leave the screen as it was, not empty it.
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

/// The featured slice of the taxonomy, derived rather than re-fetched.
///
/// A separate `@riverpod` function instead of a `.select()` on the notifier:
/// Riverpod 3 does not offer `select` on a generated notifier provider, and a
/// derived provider only re-emits when its own output changes, which is the
/// same rebuild saving with less ceremony.
@riverpod
List<Category> featuredCategoryNodes(Ref ref) => [
      for (final node in ref.watch(categoriesProvider).tree)
        if (node.category.isFeatured) node.category,
    ];

/// Brands flagged as featured, off the already-loaded directory.
@riverpod
List<Brand> featuredBrandsFromDirectory(Ref ref) => [
      for (final brand in ref.watch(categoriesProvider).brands)
        if (brand.isFeatured) brand,
    ];
