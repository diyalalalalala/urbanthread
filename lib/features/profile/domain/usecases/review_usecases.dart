import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/review.dart';
import '../entities/reviewable_product.dart';
import '../repositories/review_repository.dart';

class MyReviewsParams {
  const MyReviewsParams({this.page = 1, this.limit = 10});

  final int page;
  final int limit;
}

class GetMyReviewsUseCase extends UseCase<Paginated<Review>, MyReviewsParams> {
  const GetMyReviewsUseCase(this._repository);

  final ReviewRepository _repository;

  @override
  Future<Result<Paginated<Review>>> call(MyReviewsParams params) =>
      _repository.getMyReviews(page: params.page, limit: params.limit);
}

class GetReviewableProductsUseCase
    extends UseCase<List<ReviewableProduct>, NoParams> {
  const GetReviewableProductsUseCase(this._repository);

  final ReviewRepository _repository;

  @override
  Future<Result<List<ReviewableProduct>>> call(NoParams params) =>
      _repository.getReviewableProducts();
}

class CreateReviewParams {
  const CreateReviewParams({
    required this.productId,
    required this.rating,
    required this.comment,
    this.title,
  });

  final String productId;
  final int rating;
  final String comment;
  final String? title;
}

/// Writes a review. Gated on a verified email server-side; the UI checks
/// `User.isEmailVerified` first so the customer gets an explanation instead of
/// a bare 403.
class CreateReviewUseCase extends UseCase<Review, CreateReviewParams> {
  const CreateReviewUseCase(this._repository);

  final ReviewRepository _repository;

  @override
  Future<Result<Review>> call(CreateReviewParams params) =>
      _repository.createReview(
        productId: params.productId,
        rating: params.rating,
        comment: params.comment,
        title: params.title,
      );
}

class UpdateReviewParams {
  const UpdateReviewParams({
    required this.reviewId,
    this.rating,
    this.title,
    this.comment,
  });

  final String reviewId;
  final int? rating;
  final String? title;
  final String? comment;

  bool get isEmpty => rating == null && title == null && comment == null;
}

class UpdateReviewUseCase extends UseCase<Review, UpdateReviewParams> {
  const UpdateReviewUseCase(this._repository);

  final ReviewRepository _repository;

  @override
  Future<Result<Review>> call(UpdateReviewParams params) =>
      _repository.updateReview(
        reviewId: params.reviewId,
        rating: params.rating,
        title: params.title,
        comment: params.comment,
      );
}

class DeleteReviewUseCase extends UseCase<void, String> {
  const DeleteReviewUseCase(this._repository);

  final ReviewRepository _repository;

  @override
  Future<Result<void>> call(String reviewId) =>
      _repository.deleteReview(reviewId);
}
