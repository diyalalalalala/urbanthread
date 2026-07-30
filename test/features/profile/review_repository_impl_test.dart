import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:urbanthread/core/errors/failures.dart';
import 'package:urbanthread/features/profile/data/datasource/review_remote_datasource.dart';
import 'package:urbanthread/features/profile/data/models/review_model.dart';
import 'package:urbanthread/features/profile/data/repositories/review_repository_impl.dart';
import 'package:urbanthread/features/profile/domain/entities/review.dart';

import '../../helpers/api_fixtures.dart';

class MockReviewRemoteDataSource extends Mock
    implements ReviewRemoteDataSource {}

/// Full CRUD over the customer's own reviews — `POST /reviews`,
/// `GET /reviews/my-reviews`, `PATCH /reviews/{id}`, `DELETE /reviews/{id}`.
///
/// The three things this layer has to get right are the `product` field being
/// polymorphic between routes, the request bodies the validator will accept,
/// and the status codes that carry business meaning: 409 is "you already
/// reviewed this", not a generic error.
void main() {
  late MockReviewRemoteDataSource remote;
  late ReviewRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      const CreateReviewRequest(product: '', rating: 5, comment: ''),
    );
    registerFallbackValue(const UpdateReviewRequest());
  });

  setUp(() {
    // The populated product projection carries image paths, which
    // `ProductRefModel` re-bases through `MediaUrl`.
    dotenv.loadFromString(
      envString: 'API_BASE_URL=http://10.0.2.2:5000/api/v1\n',
    );

    remote = MockReviewRemoteDataSource();
    repository = ReviewRepositoryImpl(remote);
  });

  tearDown(dotenv.clean);

  /// A row of `GET /reviews/my-reviews`, where `product` is populated.
  Map<String, dynamic> reviewJson({
    String id = 'r1',
    Object? product,
    int rating = 4,
    String title = 'Holds up',
    String comment = 'Kept its shape after five washes.',
    String status = 'approved',
    bool isEdited = false,
  }) =>
      <String, dynamic>{
        '_id': id,
        'product': product ??
            <String, dynamic>{
              '_id': 'p1',
              'name': 'Cotton Tee',
              'slug': 'cotton-tee',
              'images': <Map<String, dynamic>>[
                {'url': '/uploads/products/tee.jpg', 'isPrimary': true},
              ],
              'price': 1990,
            },
        'userName': 'Aarav Sharma',
        'userAvatar': '',
        'rating': rating,
        'title': title,
        'comment': comment,
        'isVerifiedPurchase': true,
        'status': status,
        'moderationNote': '',
        'helpfulCount': 3,
        'isEdited': isEdited,
        'createdAt': '2026-02-01T10:00:00.000Z',
      };

  T captureRequest<T>(void Function() call) =>
      verify(call).captured.single as T;

  group('read — GET /reviews/my-reviews', () {
    test('passes the page through and maps the meta onto the domain page',
        () async {
      when(
        () => remote.getMyReviews(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => envelope(
          [ReviewModel.fromJson(reviewJson())],
          meta: paginationMeta(page: 2, limit: 20, total: 45, totalPages: 3),
        ),
      );

      final result = await repository.getMyReviews(page: 2, limit: 20);
      final page = result.valueOrNull!;

      verify(() => remote.getMyReviews(page: 2, limit: 20)).called(1);
      expect(page.page, 2);
      expect(page.totalPages, 3);
      expect(page.total, 45);
      // `hasNextPage`, not `hasNext` — reading the wrong key would end an
      // infinite scroll one page in.
      expect(page.hasNextPage, isTrue);
      expect(page.nextPage, 3);
    });

    test('a response with no meta is a complete single page', () async {
      when(
        () => remote.getMyReviews(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => envelope([ReviewModel.fromJson(reviewJson())]),
      );

      final page = (await repository.getMyReviews()).valueOrNull!;

      expect(page.page, 1);
      expect(page.total, 1);
      expect(page.hasNextPage, isFalse);
    });

    test('lifts the product id out of the populated projection', () async {
      when(
        () => remote.getMyReviews(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => envelope([ReviewModel.fromJson(reviewJson())]),
      );

      final review = (await repository.getMyReviews()).valueOrNull!.items.single;

      // `product` is an object here and a bare id on the write routes, so the
      // id is read out separately and the projection kept beside it.
      expect(review.productId, 'p1');
      expect(review.product?.name, 'Cotton Tee');
      expect(review.product?.slug, 'cotton-tee');
      expect(
        review.product?.imageUrl,
        'http://10.0.2.2:5000/uploads/products/tee.jpg',
      );
      expect(review.status, ReviewStatus.approved);
      expect(review.isVerifiedPurchase, isTrue);
    });

    test('reports a lapsed session rather than an empty list', () async {
      when(
        () => remote.getMyReviews(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(httpError(401));

      final result = await repository.getMyReviews();

      expect(result.failureOrNull, isA<UnauthorizedFailure>());
    });

    test('the reviewable list is keyed by product id, having no _id of its own',
        () async {
      when(() => remote.getReviewableProducts()).thenAnswer(
        (_) async => envelope([
          ReviewableProductModel.fromJson(<String, dynamic>{
            'product': 'p9',
            'productName': 'Linen Shirt',
            'slug': 'linen-shirt',
            'image': '',
            'brandName': 'UrbanThread',
            'order': 'o1',
            'orderNumber': 'UT-2026-0001',
            'deliveredAt': '2026-01-20T08:00:00.000Z',
          }),
        ]),
      );

      final items = (await repository.getReviewableProducts()).valueOrNull!;

      expect(items.single.productId, 'p9');
      expect(items.single.orderNumber, 'UT-2026-0001');
    });
  });

  group('create — POST /reviews', () {
    test('sends the product id under `product` and trims the comment',
        () async {
      when(() => remote.createReview(any())).thenAnswer(
        (_) async => envelope(ReviewModel.fromJson(reviewJson())),
      );

      final result = await repository.createReview(
        productId: 'p1',
        rating: 5,
        comment: '  Excellent quality for the price.  ',
        title: ' Great buy ',
      );

      expect(result.valueOrNull?.id, 'r1');
      final request = captureRequest<CreateReviewRequest>(
        () => remote.createReview(captureAny()),
      );
      // The key is `product`, not `productId` — a param the validator does not
      // recognise is dropped, and the request fails as "comment required".
      expect(request.product, 'p1');
      expect(request.rating, 5);
      expect(request.comment, 'Excellent quality for the price.');
      expect(request.title, 'Great buy');
    });

    test('omits a blank title instead of sending null', () async {
      when(() => remote.createReview(any())).thenAnswer(
        (_) async => envelope(ReviewModel.fromJson(reviewJson(title: ''))),
      );

      await repository.createReview(
        productId: 'p1',
        rating: 4,
        comment: 'Comfortable and true to size.',
        title: '   ',
      );

      final request = captureRequest<CreateReviewRequest>(
        () => remote.createReview(captureAny()),
      );
      expect(request.title, isNull);
      // An absent key is what "no title" means to the validator; an explicit
      // null is a type error to it.
      expect(request.toJson().containsKey('title'), isFalse);
    });

    test('a second review of the same product is a conflict', () async {
      when(() => remote.createReview(any())).thenThrow(
        httpError(409, message: 'You have already reviewed this product.'),
      );

      final result = await repository.createReview(
        productId: 'p1',
        rating: 5,
        comment: 'Buying a second one.',
      );

      // One review per product per user is a backend constraint, so the UI
      // has to offer "edit yours" rather than retry.
      expect(result.failureOrNull, isA<ConflictFailure>());
      expect(
        result.failureOrNull?.message,
        'You have already reviewed this product.',
      );
    });

    test('an unverified email is refused, not rejected as invalid', () async {
      when(() => remote.createReview(any())).thenThrow(
        httpError(403, message: 'Verify your email address to post a review.'),
      );

      final result = await repository.createReview(
        productId: 'p1',
        rating: 5,
        comment: 'Would recommend to anyone.',
      );

      expect(result.failureOrNull, isA<ForbiddenFailure>());
    });

    test('a rating outside 1..5 comes back as a field error', () async {
      when(() => remote.createReview(any())).thenThrow(
        httpError(
          422,
          message: 'Validation failed.',
          errors: [
            {'field': 'rating', 'message': 'Rating must be between 1 and 5.'},
          ],
        ),
      );

      final result = await repository.createReview(
        productId: 'p1',
        rating: 9,
        comment: 'Off the scale entirely.',
      );

      expect(
        (result.failureOrNull! as ValidationFailure).forField('rating'),
        'Rating must be between 1 and 5.',
      );
    });
  });

  group('update — PATCH /reviews/{id}', () {
    test('sends only the fields that changed', () async {
      when(() => remote.updateReview(any(), any())).thenAnswer(
        (_) async => envelope(
          ReviewModel.fromJson(reviewJson(rating: 5, isEdited: true)),
        ),
      );

      final result = await repository.updateReview(reviewId: 'r1', rating: 5);

      expect(result.valueOrNull?.rating, 5);
      expect(result.valueOrNull?.isEdited, isTrue);
      final request = verify(
        () => remote.updateReview('r1', captureAny()),
      ).captured.single as UpdateReviewRequest;
      expect(request.toJson(), {'rating': 5});
    });

    test('trims an edited comment', () async {
      when(() => remote.updateReview(any(), any())).thenAnswer(
        (_) async => envelope(ReviewModel.fromJson(reviewJson())),
      );

      await repository.updateReview(
        reviewId: 'r1',
        comment: '  Still going strong six months later.  ',
      );

      final request = verify(
        () => remote.updateReview('r1', captureAny()),
      ).captured.single as UpdateReviewRequest;
      expect(request.comment, 'Still going strong six months later.');
    });

    test('refuses an empty patch without calling the API', () async {
      final result = await repository.updateReview(reviewId: 'r1');

      // An empty body is a 400. Saying so precisely beats relaying the
      // validator's generic message after a pointless round trip.
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(result.failureOrNull?.message, 'Change something before saving.');
      verifyNever(() => remote.updateReview(any(), any()));
    });

    test('the patch response carries product as a bare id', () async {
      when(() => remote.updateReview(any(), any())).thenAnswer(
        (_) async => envelope(
          ReviewModel.fromJson(reviewJson(product: 'p1')),
        ),
      );

      final review = (await repository.updateReview(
        reviewId: 'r1',
        rating: 3,
      )).valueOrNull!;

      // Which is why `Review.copyWith` never merges `product` — doing so would
      // replace the list's populated projection with nothing.
      expect(review.productId, 'p1');
      expect(review.product, isNull);
    });

    test('a review deleted meanwhile is not found', () async {
      when(() => remote.updateReview(any(), any())).thenThrow(
        httpError(404, message: 'Review not found.'),
      );

      final result = await repository.updateReview(reviewId: 'gone', rating: 4);

      expect(result.failureOrNull, isA<NotFoundFailure>());
    });

    test('someone else\'s review is forbidden', () async {
      when(() => remote.updateReview(any(), any())).thenThrow(httpError(403));

      final result = await repository.updateReview(
        reviewId: 'r-other',
        rating: 1,
      );

      expect(result.failureOrNull, isA<ForbiddenFailure>());
    });
  });

  group('delete — DELETE /reviews/{id}', () {
    test('reports success on a 204 with no body', () async {
      when(() => remote.deleteReview('r1')).thenAnswer((_) async {});

      final result = await repository.deleteReview('r1');

      // There is no envelope to decode here, so "success" is the absence of a
      // throw rather than anything parsed.
      expect(result.isSuccess, isTrue);
      expect(result.failureOrNull, isNull);
      verify(() => remote.deleteReview('r1')).called(1);
    });

    test('a stale id is not found', () async {
      when(() => remote.deleteReview(any())).thenThrow(
        httpError(404, message: 'Review not found.'),
      );

      final result = await repository.deleteReview('gone');

      expect(result.failureOrNull, isA<NotFoundFailure>());
      expect(result.failureOrNull?.message, 'Review not found.');
    });

    test('a dropped connection is a network failure, so the UI can retry',
        () async {
      when(() => remote.deleteReview(any())).thenThrow(connectionError());

      final result = await repository.deleteReview('r1');

      expect(result.failureOrNull, isA<NetworkFailure>());
    });
  });
}
