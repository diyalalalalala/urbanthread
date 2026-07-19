import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/review.dart';
import '../../domain/usecases/get_product_reviews_usecase.dart';
import 'product_providers.dart';

part 'product_reviews_notifier.g.dart';

/// The review list under a product, paged and filterable.
class ProductReviewsState extends Equatable {
  const ProductReviewsState({
    this.query = const ReviewQuery(),
    this.items = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasNextPage = false,
    this.total = 0,
    this.failure,
  });

  final ReviewQuery query;
  final List<Review> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasNextPage;
  final int total;
  final Failure? failure;

  bool get isEmpty => items.isEmpty && !isLoading && failure == null;

  ProductReviewsState copyWith({
    ReviewQuery? query,
    List<Review>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasNextPage,
    int? total,
    Failure? failure,
    bool clearFailure = false,
  }) =>
      ProductReviewsState(
        query: query ?? this.query,
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasNextPage: hasNextPage ?? this.hasNextPage,
        total: total ?? this.total,
        failure: clearFailure ? null : (failure ?? this.failure),
      );

  @override
  List<Object?> get props => [
        query,
        items,
        isLoading,
        isLoadingMore,
        hasNextPage,
        total,
        failure,
      ];
}

/// Loads reviews for one product.
///
/// Kept separate from [ProductDetailNotifier] so a filter change on the
/// review list — "4 stars only" — does not re-render the gallery, the variant
/// selector and the recommendations above it.
@riverpod
class ProductReviewsNotifier extends _$ProductReviewsNotifier {
  bool _isFetching = false;

  @override
  ProductReviewsState build(String productId) {
    unawaited(_loadFirstPage(const ReviewQuery()));
    return const ProductReviewsState();
  }

  Future<void> _loadFirstPage(ReviewQuery query) async {
    _isFetching = true;
    final result = await ref.read(getProductReviewsUseCaseProvider)(
      ProductReviewsParams(productId, query.copyWith(page: 1)),
    );
    _isFetching = false;

    switch (result) {
      case Success(:final value):
        state = ProductReviewsState(
          query: query.copyWith(page: 1),
          items: value.items,
          isLoading: false,
          hasNextPage: value.hasNextPage,
          total: value.total,
        );
      case FailureResult(:final failure):
        state = ProductReviewsState(
          query: query.copyWith(page: 1),
          isLoading: false,
          failure: failure,
        );
    }
  }

  Future<void> loadMore() async {
    if (_isFetching || !state.hasNextPage || state.isLoading) return;

    _isFetching = true;
    state = state.copyWith(isLoadingMore: true);

    final next = state.query.copyWith(page: state.query.page + 1);
    final result = await ref.read(getProductReviewsUseCaseProvider)(
      ProductReviewsParams(productId, next),
    );
    _isFetching = false;

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          query: next,
          items: [...state.items, ...value.items],
          hasNextPage: value.hasNextPage,
          total: value.total,
          isLoadingMore: false,
        );
      case FailureResult(:final failure):
        // Page not advanced, so retrying asks for the same page again.
        state = state.copyWith(isLoadingMore: false, failure: failure);
    }
  }

  Future<void> setSort(ReviewSort sort) =>
      _applyQuery(state.query.copyWith(sort: sort));

  /// Filters to a single star rating; pass null to show all.
  Future<void> filterByRating(int? rating) => _applyQuery(
        rating == null
            ? state.query.copyWith(clearRating: true)
            : state.query.copyWith(rating: rating),
      );

  Future<void> showVerifiedOnly({required bool verified}) => _applyQuery(
        verified
            ? state.query.copyWith(verified: true)
            : state.query.copyWith(clearVerified: true),
      );

  Future<void> clearFilters() => _applyQuery(
        ReviewQuery(limit: state.query.limit, sort: state.query.sort),
      );

  Future<void> _applyQuery(ReviewQuery query) async {
    if (query.copyWith(page: 1) == state.query.copyWith(page: 1)) return;
    state = state.copyWith(isLoading: true, clearFailure: true);
    await _loadFirstPage(query);
  }

  Future<void> retry() async {
    state = const ProductReviewsState();
    await _loadFirstPage(state.query);
  }
}
