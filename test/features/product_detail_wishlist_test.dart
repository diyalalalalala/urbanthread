import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:urbanthread/core/domain/result.dart';
import 'package:urbanthread/core/errors/failures.dart';
import 'package:urbanthread/core/providers/core_providers.dart';
import 'package:urbanthread/core/storage/token_storage.dart';
import 'package:urbanthread/core/theme/app_theme.dart';
import 'package:urbanthread/features/products/domain/entities/product.dart';
import 'package:urbanthread/features/products/domain/entities/review.dart';
import 'package:urbanthread/features/products/domain/repositories/product_repository.dart';
import 'package:urbanthread/features/products/domain/repositories/review_repository.dart';
import 'package:urbanthread/features/products/presentation/pages/product_detail_page.dart';
import 'package:urbanthread/features/products/presentation/providers/product_providers.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class MockReviewRepository extends Mock implements ReviewRepository {}

class MockTokenStorage extends Mock implements TokenStorage {}

class FakeReviewQuery extends Fake implements ReviewQuery {}

/// The wishlist had no entry point at all: `showWishlistButton` defaulted to
/// false and nothing in the app ever set it, so the heart the empty state
/// tells people to tap ("Tap the heart on anything you want to come back to")
/// did not exist on any screen. These pin the affordance to the product page.
void main() {
  const product = Product(
    id: '6a5b33243dfa5ecf061012ef',
    name: 'Linen Wrap Midi Dress',
    slug: 'linen-wrap-midi-dress-ab12c',
    price: 6799,
    effectivePrice: 5099.25,
    discountPercentage: 25,
    totalStock: 12,
    brand: BrandRef(id: 'b1', name: 'Everlane'),
    rating: ProductRating(average: 4.5, count: 128),
  );

  late MockProductRepository repository;
  late MockReviewRepository reviews;

  setUpAll(() => registerFallbackValue(FakeReviewQuery()));

  setUp(() {
    repository = MockProductRepository();
    reviews = MockReviewRepository();
    // The reviews block is not what is under test here; letting it fail keeps
    // it inline and off the network.
    when(() => reviews.getProductReviews(any(), any()))
        .thenAnswer((_) async => const Result.failure(NetworkFailure()));
    when(() => reviews.getProductReviewStats(any()))
        .thenAnswer((_) async => const Result.failure(NetworkFailure()));
    when(() => repository.getProductBySlug(any()))
        .thenAnswer((_) async => const Result.success(product));
    when(() => repository.getRelatedProducts(any(), limit: any(named: 'limit')))
        .thenAnswer((_) async => const Result.success([]));
    when(
      () => repository.getFrequentlyBoughtTogether(
        any(),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const Result.success([]));
  });

  Future<void> pump(
    WidgetTester tester, {
    required bool showWishlistButton,
    bool isWishlisted = false,
    void Function(Product product)? onWishlistTap,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(repository),
          reviewRepositoryProvider.overrideWithValue(reviews),
          tokenStorageProvider.overrideWithValue(MockTokenStorage()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: ProductDetailPage(
            slug: product.slug,
            showWishlistButton: showWishlistButton,
            isWishlisted: (_) => isWishlisted,
            onWishlistTap: onWishlistTap,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('the product page offers a way to save', (tester) async {
    await pump(tester, showWishlistButton: true);

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.ancestor(
              of: find.byIcon(Icons.favorite_border),
              matching: find.byType(IconButton),
            ),
          )
          .tooltip,
      'Save to wishlist',
    );
  });

  testWidgets('tapping it reports the product to the route', (tester) async {
    Product? saved;
    await pump(
      tester,
      showWishlistButton: true,
      onWishlistTap: (product) => saved = product,
    );

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pump();

    expect(saved?.id, product.id);
  });

  testWidgets('an already-saved product shows a filled heart', (tester) async {
    await pump(tester, showWishlistButton: true, isWishlisted: true);

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);
  });

  // The page must stay mountable without the wishlist, which is what lets the
  // products feature avoid depending on it.
  testWidgets('it stays opt-in', (tester) async {
    await pump(tester, showWishlistButton: false);

    expect(find.byIcon(Icons.favorite_border), findsNothing);
    expect(find.byIcon(Icons.favorite), findsNothing);
  });
}
