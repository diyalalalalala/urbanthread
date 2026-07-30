import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbanthread/core/theme/app_dimens.dart';
import 'package:urbanthread/core/theme/app_theme.dart';
import 'package:urbanthread/features/wishlist/domain/entities/wishlist.dart';
import 'package:urbanthread/features/wishlist/presentation/widgets/wishlist_tile.dart';

/// The wishlist grid used to size its cells with a hardcoded
/// `childAspectRatio: 0.48`. That fitted a plain tile and overflowed by about
/// fifteen pixels once the price-drop line appeared — and clipped outright at
/// a raised text scale, which a fixed ratio cannot account for. These render
/// the tile in a cell built by the real delegate, at the tallest each
/// configuration gets.
void main() {
  const longName = 'Oversized Merino Wool Crew Neck Sweater in Charcoal';

  WishlistItem item({
    String name = longName,
    double discountPercentage = 0,
    double priceWhenAdded = 0,
    bool inStock = true,
    bool hasBrand = true,
  }) =>
      WishlistItem(
        id: 'w1',
        priceWhenAdded: priceWhenAdded,
        product: WishlistProduct(
          id: 'p1',
          name: name,
          slug: 'sweater',
          price: 12999,
          effectivePrice: 8999,
          discountPercentage: discountPercentage,
          totalStock: inStock ? 12 : 0,
          brand: hasBrand
              ? const WishlistReference(id: 'b1', name: 'Everlane')
              : null,
        ),
      );

  Future<void> pump(
    WidgetTester tester,
    List<WishlistItem> items, {
    double textScale = 1,
  }) async {
    // A phone, not the 800x600 default: the grid is two columns here and
    // three there, and the narrower cell is both what the customer reported
    // and the harder case for the caption.
    tester.view.physicalSize = const Size(411.4, 866.3);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: Scaffold(
              body: Builder(
                // The delegate reads the screen width and text scale off the
                // context, so it has to be built inside the MediaQuery it is
                // being measured against — exactly as the page does it.
                builder: (context) => GridView.builder(
                  padding: const EdgeInsets.all(AppDimens.pageGutter),
                  gridDelegate: WishlistTileGeometry.delegate(context),
                  itemCount: items.length,
                  itemBuilder: (context, index) => WishlistTile(
                    item: items[index],
                    onMoveToCart: () {},
                    onRemove: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('a plain saved product fits its cell', (tester) async {
    await pump(tester, [item()]);

    expect(tester.takeException(), isNull);
  });

  // The regression: `priceWhenAdded` above the current price adds a line.
  testWidgets('a price-drop line fits too', (tester) async {
    await pump(tester, [item(priceWhenAdded: 11999)]);

    expect(tester.takeException(), isNull);
  });

  testWidgets('a discount badge and a price drop together fit', (tester) async {
    // Widest the price row gets: current price, struck-through original and
    // the badge, which is what can push it onto a second line.
    await pump(tester, [item(discountPercentage: 31, priceWhenAdded: 11999)]);

    expect(tester.takeException(), isNull);
  });

  testWidgets('the tallest tile holds at a doubled font scale', (tester) async {
    await pump(
      tester,
      [item(discountPercentage: 31, priceWhenAdded: 11999)],
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('an out-of-stock tile fits', (tester) async {
    await pump(tester, [item(inStock: false, priceWhenAdded: 11999)]);

    expect(tester.takeException(), isNull);
  });

  testWidgets('a full row of mixed tiles fits', (tester) async {
    await pump(tester, [
      item(),
      item(priceWhenAdded: 11999),
      item(name: 'Beanie', hasBrand: false),
      item(discountPercentage: 31, priceWhenAdded: 11999),
    ]);

    expect(tester.takeException(), isNull);
  });
}
