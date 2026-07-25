import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbanthread/core/theme/app_theme.dart';
import 'package:urbanthread/features/home/domain/entities/home_product.dart';
import 'package:urbanthread/features/home/presentation/widgets/home_product_card.dart';
import 'package:urbanthread/features/home/presentation/widgets/product_rail.dart';
import 'package:urbanthread/features/products/domain/entities/product.dart';
import 'package:urbanthread/features/products/presentation/widgets/product_grid.dart';

/// A product tile is a fixed-size cell — a grid ratio or a strip height — with
/// a caption that is almost entirely text. Every one of these renders the
/// tallest caption the card can produce: a brand eyebrow, a name long enough
/// to take both of its lines, a rating row and a discounted price.
void main() {
  const longName = 'Oversized Merino Wool Crew Neck Sweater in Charcoal';

  Product product({String name = longName}) => Product(
        id: '1',
        name: name,
        slug: 'sweater',
        price: 12999,
        effectivePrice: 8999,
        discountPercentage: 30,
        totalStock: 12,
        brand: const BrandRef(id: 'b1', name: 'Everlane'),
        rating: const ProductRating(average: 4.5, count: 128),
      );

  HomeProduct homeProduct({String name = longName}) => HomeProduct(
        id: '1',
        name: name,
        slug: 'sweater',
        price: 12999,
        effectivePrice: 8999,
        discountPercentage: 30,
        totalStock: 12,
        brandName: 'Everlane',
        ratingAverage: 4.5,
        ratingCount: 128,
      );

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          // Copied rather than replaced: the grid sizes its cells off the
          // screen width, and a fresh MediaQueryData would hand it zero.
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: Scaffold(body: child),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('catalogue grid', () {
    testWidgets('a two-line name does not overflow the cell', (tester) async {
      await pump(
        tester,
        ProductGrid(products: List.generate(4, (_) => product())),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('the cell holds at a doubled font scale', (tester) async {
      await pump(
        tester,
        ProductGrid(products: [product()]),
        textScale: 2,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('a one-line name is unaffected', (tester) async {
      await pump(tester, ProductGrid(products: [product(name: 'Scarf')]));

      expect(tester.takeException(), isNull);
    });
  });

  group('carousel', () {
    testWidgets('a two-line name does not overflow the strip', (tester) async {
      await pump(tester, ProductCarousel(products: [product()]));

      expect(tester.takeException(), isNull);
    });

    testWidgets('the dense variant does not overflow either', (tester) async {
      await pump(
        tester,
        ProductCarousel(products: [product()], dense: true),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('home rail', () {
    /// The rail hands its cards a fixed height, so the card is measured
    /// against exactly that rather than against a convenient one.
    Widget railSizedCard() => Builder(
          builder: (context) => SizedBox(
            height: ProductRail.railHeight(context),
            child: HomeProductCard(product: homeProduct(), onTap: () {}),
          ),
        );

    testWidgets('a two-line name does not overflow the card', (tester) async {
      await pump(tester, railSizedCard());

      expect(tester.takeException(), isNull);
    });

    testWidgets('the card holds at a doubled font scale', (tester) async {
      await pump(tester, railSizedCard(), textScale: 2);

      expect(tester.takeException(), isNull);
    });
  });
}
