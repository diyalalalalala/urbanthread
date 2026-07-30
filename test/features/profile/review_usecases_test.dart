import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:urbanthread/core/domain/paginated.dart';
import 'package:urbanthread/core/domain/result.dart';
import 'package:urbanthread/core/domain/usecase.dart';
import 'package:urbanthread/core/errors/failures.dart';
import 'package:urbanthread/features/profile/domain/entities/review.dart';
import 'package:urbanthread/features/profile/domain/repositories/review_repository.dart';
import 'package:urbanthread/features/profile/domain/usecases/review_usecases.dart';

class MockReviewRepository extends Mock implements ReviewRepository {}

/// The CRUD use cases for a review.
///
/// A use case that quietly drops or reorders one of its arguments is invisible
/// in the UI — the request simply does something slightly different from what
/// the form said. So each one is pinned to the repository call it must make,
/// and the params objects to the guards the presentation layer reads off them.
void main() {
  const review = Review(
    id: 'r1',
    productId: 'p1',
    rating: 4,
    comment: 'Kept its shape after five washes.',
    title: 'Holds up',
  );

  late MockReviewRepository repository;

  setUp(() => repository = MockReviewRepository());

  group('GetMyReviewsUseCase', () {
    test('forwards the page window', () async {
      when(
        () => repository.getMyReviews(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => Result.success(Paginated<Review>.single(const [review])),
      );

      final result = await GetMyReviewsUseCase(repository)(
        const MyReviewsParams(page: 3, limit: 20),
      );

      expect(result.valueOrNull?.items, [review]);
      verify(() => repository.getMyReviews(page: 3, limit: 20)).called(1);
    });

    test('defaults to the first page of ten', () async {
      when(
        () => repository.getMyReviews(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const Result.success(Paginated<Review>.empty()),
      );

      await GetMyReviewsUseCase(repository)(const MyReviewsParams());

      verify(() => repository.getMyReviews(page: 1, limit: 10)).called(1);
    });
  });

  group('CreateReviewUseCase', () {
    test('passes every field the validator accepts', () async {
      when(
        () => repository.createReview(
          productId: any(named: 'productId'),
          rating: any(named: 'rating'),
          comment: any(named: 'comment'),
          title: any(named: 'title'),
        ),
      ).thenAnswer((_) async => const Result.success(review));

      final result = await CreateReviewUseCase(repository)(
        const CreateReviewParams(
          productId: 'p1',
          rating: 4,
          comment: 'Kept its shape after five washes.',
          title: 'Holds up',
        ),
      );

      expect(result.valueOrNull, review);
      verify(
        () => repository.createReview(
          productId: 'p1',
          rating: 4,
          comment: 'Kept its shape after five washes.',
          title: 'Holds up',
        ),
      ).called(1);
    });

    test('leaves a failure untouched for the notifier to present', () async {
      when(
        () => repository.createReview(
          productId: any(named: 'productId'),
          rating: any(named: 'rating'),
          comment: any(named: 'comment'),
          title: any(named: 'title'),
        ),
      ).thenAnswer(
        (_) async => const Result.failure(
          ConflictFailure('You have already reviewed this product.'),
        ),
      );

      final result = await CreateReviewUseCase(repository)(
        const CreateReviewParams(
          productId: 'p1',
          rating: 4,
          comment: 'Kept its shape after five washes.',
        ),
      );

      expect(result.failureOrNull, isA<ConflictFailure>());
    });
  });

  group('UpdateReviewUseCase', () {
    test('forwards the id and the changed fields', () async {
      when(
        () => repository.updateReview(
          reviewId: any(named: 'reviewId'),
          rating: any(named: 'rating'),
          title: any(named: 'title'),
          comment: any(named: 'comment'),
        ),
      ).thenAnswer((_) async => const Result.success(review));

      await UpdateReviewUseCase(repository)(
        const UpdateReviewParams(reviewId: 'r1', rating: 5),
      );

      verify(
        () => repository.updateReview(
          reviewId: 'r1',
          rating: 5,
          title: null,
          comment: null,
        ),
      ).called(1);
    });

    test('isEmpty tells the form there is nothing to save', () {
      // The API answers an empty patch with a 400, so the button is disabled
      // off this rather than the request being sent to find out.
      expect(const UpdateReviewParams(reviewId: 'r1').isEmpty, isTrue);
      expect(
        const UpdateReviewParams(reviewId: 'r1', rating: 5).isEmpty,
        isFalse,
      );
      expect(
        const UpdateReviewParams(reviewId: 'r1', comment: 'Edited.').isEmpty,
        isFalse,
      );
      expect(
        const UpdateReviewParams(reviewId: 'r1', title: 'Edited').isEmpty,
        isFalse,
      );
    });
  });

  group('DeleteReviewUseCase', () {
    test('takes the review id as its whole parameter', () async {
      when(() => repository.deleteReview(any()))
          .thenAnswer((_) async => const Result.success(null));

      final result = await DeleteReviewUseCase(repository)('r1');

      expect(result.isSuccess, isTrue);
      verify(() => repository.deleteReview('r1')).called(1);
    });
  });

  group('GetReviewableProductsUseCase', () {
    test('takes no parameters', () async {
      when(() => repository.getReviewableProducts())
          .thenAnswer((_) async => const Result.success([]));

      final result =
          await GetReviewableProductsUseCase(repository)(const NoParams());

      expect(result.valueOrNull, isEmpty);
    });
  });
}
