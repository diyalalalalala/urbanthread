import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

/// Loads the rating summary shown above the review list.
class GetProductReviewStatsUseCase extends UseCase<ReviewStats, String> {
  const GetProductReviewStatsUseCase(this._repository);

  final ReviewRepository _repository;

  @override
  Future<Result<ReviewStats>> call(String params) =>
      _repository.getProductReviewStats(params);
}
