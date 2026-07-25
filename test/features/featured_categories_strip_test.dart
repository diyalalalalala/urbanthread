import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbanthread/core/theme/app_theme.dart';
import 'package:urbanthread/features/categories/domain/entities/category.dart';
import 'package:urbanthread/features/home/domain/entities/home_feed.dart';
import 'package:urbanthread/features/home/presentation/widgets/featured_categories_strip.dart';

/// The strip gives its chips a fixed height, so the label underneath the
/// artwork has to be measured rather than guessed. Two lines of `bodySmall`
/// come to 37.5, which is why the 44 that used to be reserved for gap plus
/// label overflowed by two pixels on every category with a long name.
void main() {
  Future<void> pumpStrip(
    WidgetTester tester, {
    required String name,
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(
            body: FeaturedCategoriesStrip(
              section: HomeSection<Category>(
                items: [Category(id: '1', name: name, slug: 'slug')],
              ),
              onOpenCategory: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('a two-line label does not overflow the chip', (tester) async {
    await pumpStrip(tester, name: 'Coats and Outerwear');

    expect(tester.takeException(), isNull);
  });

  testWidgets('a label longer than two lines is ellipsised, not overflowed', (
    tester,
  ) async {
    await pumpStrip(
      tester,
      name: 'Coats, Jackets, Outerwear and Everything Else Warm',
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('the strip grows with the system font scale', (tester) async {
    await pumpStrip(tester, name: 'Coats and Outerwear', textScale: 2);

    expect(tester.takeException(), isNull);
  });
}
