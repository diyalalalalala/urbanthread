import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasource/review_remote_datasource.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  ReviewRepositoryImpl({
    required ReviewRemoteDataSource remote,
    required NetworkInfo networkInfo,
  })  : _remote = remote,
        _networkInfo = networkInfo;

  final ReviewRemoteDataSource _remote;
  final NetworkInfo _networkInfo;

  @override
  Future<Result<Paginated<Review>>> getProductReviews(
    String productId,
    ReviewQuery query,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Result.failure(
        NetworkFailure('Reviews are unavailable offline.'),
      );
    }

    try {
      final envelope = await _remote.getProductReviews(
        productId,
        query.toQueryParameters(),
      );
      final meta = envelope.meta;
      final reviews = envelope.data
          .map((model) => model.toEntity())
          .toList(growable: false);

      if (meta == null) return Result.success(Paginated<Review>.single(reviews));

      return Result.success(
        Paginated<Review>(
          items: reviews,
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
  Future<Result<ReviewStats>> getProductReviewStats(String productId) async {
    if (!await _networkInfo.isConnected) {
      return const Result.failure(
        NetworkFailure('Ratings are unavailable offline.'),
      );
    }

    try {
      final envelope = await _remote.getProductReviewStats(productId);
      return Result.success(envelope.data.toEntity());
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }
}
