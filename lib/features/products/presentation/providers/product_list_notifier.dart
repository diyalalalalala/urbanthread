import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_query.dart';
import 'product_providers.dart';

part 'product_list_notifier.g.dart';

/// An accumulating, filterable page of the catalogue.
///
/// [failure] and [loadMoreFailure] are separate because they need different
/// treatment: a first-page failure replaces the grid with [FailureView],
/// while a failure two pages down must leave the fifty products already on
/// screen alone and show a retry footer instead.
class ProductListState extends Equatable {
  const ProductListState({
    required this.query,
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.hasNextPage = false,
    this.total = 0,
    this.failure,
    this.loadMoreFailure,
  });

  /// The query these items answer, including the page most recently loaded.
  final ProductQuery query;

  final List<Product> items;

  /// A first page is in flight and there is nothing to show yet.
  final bool isLoading;

  final bool isLoadingMore;

  /// A pull-to-refresh is in flight. Distinct from [isLoading] so the grid
  /// stays visible under the refresh indicator.
  final bool isRefreshing;

  final bool hasNextPage;
  final int total;

  final Failure? failure;
  final Failure? loadMoreFailure;

  bool get isEmpty => items.isEmpty && !isLoading && failure == null;

  ProductListState copyWith({
    ProductQuery? query,
    List<Product>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? hasNextPage,
    int? total,
    Failure? failure,
    bool clearFailure = false,
    Failure? loadMoreFailure,
    bool clearLoadMoreFailure = false,
  }) =>
      ProductListState(
        query: query ?? this.query,
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        isRefreshing: isRefreshing ?? this.isRefreshing,
        hasNextPage: hasNextPage ?? this.hasNextPage,
        total: total ?? this.total,
        failure: clearFailure ? null : (failure ?? this.failure),
        loadMoreFailure: clearLoadMoreFailure
            ? null
            : (loadMoreFailure ?? this.loadMoreFailure),
      );

  @override
  List<Object?> get props => [
        query,
        items,
        isLoading,
        isLoadingMore,
        isRefreshing,
        hasNextPage,
        total,
        failure,
        loadMoreFailure,
      ];
}

/// Drives [ProductListPage] and any other infinite catalogue grid.
///
/// Keyed by the query it starts from, so a category page, a brand page and
/// the all-products page are three independent instances that do not fight
/// over one another's scroll position. Changing sort or filters mutates the
/// query *inside* one instance rather than creating another — otherwise every
/// filter tweak would leak a provider that is never read again.
@riverpod
class ProductListNotifier extends _$ProductListNotifier {
  /// Guards against two `loadMore` calls from one scroll gesture. A scroll
  /// listener fires far more often than the network answers, and without this
  /// the same page would be appended several times.
  bool _isFetching = false;

  @override
  ProductListState build(ProductQuery initialQuery) {
    final query = initialQuery.reset();
    // Safe to start before `build` returns: `_fetch` reaches its first await
    // without touching `state`.
    unawaited(_loadFirstPage(query));
    return ProductListState(query: query, isLoading: true);
  }

  /// Replaces the list with page one of [query].
  Future<void> _loadFirstPage(ProductQuery query) async {
    _isFetching = true;
    final result = await _fetch(query.reset());
    _isFetching = false;

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          query: query.reset(),
          items: value.items,
          total: value.total,
          hasNextPage: value.hasNextPage,
          isLoading: false,
          isRefreshing: false,
          clearFailure: true,
          clearLoadMoreFailure: true,
        );
      case FailureResult(:final failure):
        state = state.copyWith(
          query: query.reset(),
          isLoading: false,
          isRefreshing: false,
          failure: failure,
          // An offline first page has no items to preserve, so the grid is
          // cleared rather than left showing results from the old query.
          items: const [],
        );
    }
  }

  Future<Result<Paginated<Product>>> _fetch(ProductQuery query) =>
      ref.read(getProductsUseCaseProvider)(query);

  /// Appends the next page. A no-op at the end of the list, while a fetch is
  /// already running, or while the first page is still loading.
  Future<void> loadMore() async {
    if (_isFetching || !state.hasNextPage || state.isLoading) return;

    _isFetching = true;
    state = state.copyWith(isLoadingMore: true, clearLoadMoreFailure: true);

    final next = state.query.nextPage();
    final result = await _fetch(next);
    _isFetching = false;

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          query: next,
          items: [...state.items, ...value.items],
          total: value.total,
          hasNextPage: value.hasNextPage,
          isLoadingMore: false,
        );
      case FailureResult(:final failure):
        // The page number is deliberately not advanced, so a retry asks for
        // the same page rather than skipping over it.
        state = state.copyWith(
          isLoadingMore: false,
          loadMoreFailure: failure,
        );
    }
  }

  /// Pull-to-refresh: drops the cached pages first so this genuinely re-reads
  /// from the network rather than replaying what is on disk.
  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, clearFailure: true);
    await ref.read(refreshCatalogueUseCaseProvider)(const NoParams());
    await _loadFirstPage(state.query);
  }

  /// Re-runs the current query after a first-page failure.
  Future<void> retry() async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    await _loadFirstPage(state.query);
  }

  /// Retries just the page that failed, leaving the loaded items in place.
  Future<void> retryLoadMore() async {
    state = state.copyWith(clearLoadMoreFailure: true, hasNextPage: true);
    await loadMore();
  }

  /// Applies a new sort order and restarts from page one — page four of a
  /// differently ordered list is meaningless.
  Future<void> setSort(ProductSort sort) =>
      applyQuery(state.query.copyWith(sort: sort));

  /// Swaps in a query built by the filter sheet, preserving nothing but what
  /// the sheet returned.
  Future<void> applyQuery(ProductQuery query) async {
    final next = query.reset();
    if (next == state.query.reset()) return;

    state = state.copyWith(
      query: next,
      isLoading: true,
      clearFailure: true,
      clearLoadMoreFailure: true,
    );
    await _loadFirstPage(next);
  }

  Future<void> clearFilters() => applyQuery(state.query.clearFilters());
}
