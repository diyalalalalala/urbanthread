import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/reviewable_product.dart';
import '../../domain/usecases/review_usecases.dart';
import 'profile_providers.dart';

part 'my_reviews_notifier.g.dart';

/// An infinite-scroll page of the customer's reviews.
///
/// [isLoadingMore] is kept beside the data rather than folded into the
/// surrounding `AsyncValue`: a failed *next* page must not blank the pages
/// already on screen, so appending has its own progress and its own error.
class MyReviewsState extends Equatable {
  const MyReviewsState({
    required this.reviews,
    this.isLoadingMore = false,
    this.loadMoreFailure,
  });

  final Paginated<Review> reviews;
  final bool isLoadingMore;
  final Failure? loadMoreFailure;

  bool get canLoadMore => reviews.hasNextPage && !isLoadingMore;

  MyReviewsState copyWith({
    Paginated<Review>? reviews,
    bool? isLoadingMore,
    Failure? loadMoreFailure,
    bool clearLoadMoreFailure = false,
  }) =>
      MyReviewsState(
        reviews: reviews ?? this.reviews,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        loadMoreFailure:
            clearLoadMoreFailure ? null : (loadMoreFailure ?? this.loadMoreFailure),
      );

  @override
  List<Object?> get props => [reviews, isLoadingMore, loadMoreFailure];
}

@riverpod
class MyReviewsNotifier extends _$MyReviewsNotifier {
  static const _pageSize = 10;

  @override
  Future<MyReviewsState> build() async =>
      MyReviewsState(reviews: await _fetch(1));

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () async => MyReviewsState(reviews: await _fetch(1)),
    );
  }

  /// Appends the next page, if there is one.
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.canLoadMore) return;

    state = AsyncData(
      current.copyWith(isLoadingMore: true, clearLoadMoreFailure: true),
    );

    final result = await ref.read(getMyReviewsUseCaseProvider)(
      MyReviewsParams(page: current.reviews.page + 1, limit: _pageSize),
    );

    state = AsyncData(
      result.fold(
        onSuccess: (next) => current.copyWith(
          reviews: current.reviews.append(next),
          isLoadingMore: false,
        ),
        onFailure: (failure) =>
            current.copyWith(isLoadingMore: false, loadMoreFailure: failure),
      ),
    );
  }

  /// Removes a review and drops it from the list without a re-fetch — the
  /// endpoint answers 204, so there is nothing to adopt from the response.
  ///
  /// The product becomes reviewable again, so that list is invalidated too.
  Future<Failure?> deleteReview(String reviewId) async {
    final result = await ref.read(deleteReviewUseCaseProvider)(reviewId);

    return result.fold(
      onSuccess: (_) {
        final current = state.valueOrNull;
        if (current != null) {
          final remaining = current.reviews.items
              .where((review) => review.id != reviewId)
              .toList(growable: false);
          state = AsyncData(
            current.copyWith(
              reviews: Paginated<Review>(
                items: remaining,
                page: current.reviews.page,
                totalPages: current.reviews.totalPages,
                total: (current.reviews.total - 1).clamp(0, 1 << 31),
                hasNextPage: current.reviews.hasNextPage,
              ),
            ),
          );
        }
        ref.invalidate(reviewableProductsProvider);
        return null;
      },
      onFailure: (failure) => failure,
    );
  }

  /// Applies an edit in place. Returns the failure, or null on success.
  Future<Failure?> editReview({
    required String reviewId,
    int? rating,
    String? title,
    String? comment,
  }) async {
    final result = await ref.read(updateReviewUseCaseProvider)(
      UpdateReviewParams(
        reviewId: reviewId,
        rating: rating,
        title: title,
        comment: comment,
      ),
    );

    return result.fold(
      onSuccess: (updated) {
        final current = state.valueOrNull;
        if (current != null) {
          state = AsyncData(
            current.copyWith(
              // Only the edited fields are merged. The PATCH response returns
              // `product` as a bare id, so adopting the whole object would
              // lose the populated projection this list was built from.
              reviews: current.reviews.map(
                (review) => review.id == reviewId
                    ? review.copyWith(
                        rating: updated.rating,
                        title: updated.title,
                        comment: updated.comment,
                        status: updated.status,
                        isEdited: updated.isEdited,
                        editedAt: updated.editedAt,
                        updatedAt: updated.updatedAt,
                      )
                    : review,
              ),
            ),
          );
        }
        return null;
      },
      onFailure: (failure) => failure,
    );
  }

  Future<Paginated<Review>> _fetch(int page) async {
    final result = await ref.read(getMyReviewsUseCaseProvider)(
      MyReviewsParams(page: page, limit: _pageSize),
    );
    return switch (result) {
      Success(:final value) => value,
      FailureResult(:final failure) => throw failure,
    };
  }
}

/// Delivered items the customer has not reviewed yet — the entry point to
/// `WriteReviewPage`.
///
/// Never paginated: the endpoint caps at 50 and returns a bare array.
@riverpod
class ReviewableProductsNotifier extends _$ReviewableProductsNotifier {
  @override
  Future<List<ReviewableProduct>> build() => _load();

  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

  Future<List<ReviewableProduct>> _load() async {
    final result = await ref.read(getReviewableProductsUseCaseProvider)(
      const NoParams(),
    );
    return switch (result) {
      Success(:final value) => value,
      FailureResult(:final failure) => throw failure,
    };
  }
}
