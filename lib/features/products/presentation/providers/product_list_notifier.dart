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

  final ProductQuery query;

  final List<Product> items;

  final bool isLoading;

  final bool isLoadingMore;

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

@riverpod
class ProductListNotifier extends _$ProductListNotifier {
  bool _isFetching = false;

  @override
  ProductListState build(ProductQuery initialQuery) {
    final query = initialQuery.reset();
    unawaited(_loadFirstPage(query));
    return ProductListState(query: query, isLoading: true);
  }

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
          items: const [],
        );
    }
  }

  Future<Result<Paginated<Product>>> _fetch(ProductQuery query) =>
      ref.read(getProductsUseCaseProvider)(query);

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
        state = state.copyWith(
          isLoadingMore: false,
          loadMoreFailure: failure,
        );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, clearFailure: true);
    await ref.read(refreshCatalogueUseCaseProvider)(const NoParams());
    await _loadFirstPage(state.query);
  }

  Future<void> retry() async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    await _loadFirstPage(state.query);
  }

  Future<void> retryLoadMore() async {
    state = state.copyWith(clearLoadMoreFailure: true, hasNextPage: true);
    await loadMore();
  }

  Future<void> setSort(ProductSort sort) =>
      applyQuery(state.query.copyWith(sort: sort));

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
