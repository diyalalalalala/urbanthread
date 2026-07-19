import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/reviewable_product.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasource/review_remote_datasource.dart';
import '../models/review_model.dart';

/// The customer's reviews as [Result]s.
///
/// Nothing here is cached: reviews are written far less often than they are
/// read, and a stale local copy of "what have I already reviewed" would
/// invite the 409 that `POST /reviews` throws for a duplicate.
class ReviewRepositoryImpl implements ReviewRepository {
  const ReviewRepositoryImpl(this._remote);

  final ReviewRemoteDataSource _remote;

  @override
  Future<Result<Paginated<Review>>> getMyReviews({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final envelope = await _remote.getMyReviews(page: page, limit: limit);
      final items = envelope.data
          .map((review) => review.toEntity())
          .toList(growable: false);
      final meta = envelope.meta;

      return Result.success(
        meta == null
            ? Paginated<Review>.single(items)
            : Paginated<Review>(
                items: items,
                page: meta.page,
                totalPages: meta.totalPages,
                total: meta.total,
                hasNextPage: meta.hasNextPage,
              ),
      );
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  @override
  Future<Result<List<ReviewableProduct>>> getReviewableProducts() async {
    try {
      final envelope = await _remote.getReviewableProducts();
      return Result.success(
        envelope.data.map((item) => item.toEntity()).toList(growable: false),
      );
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  @override
  Future<Result<Review>> createReview({
    required String productId,
    required int rating,
    required String comment,
    String? title,
  }) async {
    try {
      final trimmedTitle = title?.trim();
      final envelope = await _remote.createReview(
        CreateReviewRequest(
          product: productId,
          rating: rating,
          comment: comment.trim(),
          title: (trimmedTitle == null || trimmedTitle.isEmpty)
              ? null
              : trimmedTitle,
        ),
      );
      return Result.success(envelope.data.toEntity());
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  @override
  Future<Result<Review>> updateReview({
    required String reviewId,
    int? rating,
    String? title,
    String? comment,
  }) async {
    final request = UpdateReviewRequest(
      rating: rating,
      title: title?.trim(),
      comment: comment?.trim(),
    );

    if (rating == null && title == null && comment == null) {
      // An empty PATCH body is a 400. Say so precisely instead of relaying
      // the generic validator message.
      return const Result.failure(
        ValidationFailure('Change something before saving.'),
      );
    }

    try {
      final envelope = await _remote.updateReview(reviewId, request);
      return Result.success(envelope.data.toEntity());
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  @override
  Future<Result<void>> deleteReview(String reviewId) async {
    try {
      // 204, no body.
      await _remote.deleteReview(reviewId);
      return const Result.success(null);
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }
}
