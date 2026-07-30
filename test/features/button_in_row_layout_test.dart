import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbanthread/core/theme/app_dimens.dart';
import 'package:urbanthread/core/theme/app_theme.dart';
import 'package:urbanthread/features/cart/domain/entities/cart_summary.dart';
import 'package:urbanthread/features/cart/presentation/widgets/coupon_field.dart';
import 'package:urbanthread/features/checkout/presentation/widgets/coupon_section.dart';

/// The button themes give `minimumSize` an infinite width so a stacked CTA
/// fills its column. A [Row] hands its non-flexible children an unbounded
/// width, which leaves that infinite minimum with nothing to be clamped
/// against — layout then dies on "BoxConstraints forces an infinite width",
/// and the whole page goes red. Every button sitting directly in a row has to
/// opt out with [AppTheme.hugContent]; these hold that line.
void main() {
  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: Scaffold(
                body: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.pageGutter,
                  ),
                  children: [child],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('bag coupon field', () {
    Widget field(CartSummary summary) => CouponField(
          summary: summary,
          onApply: (_) async {},
          onRemove: () {},
        );

    testWidgets('the apply button lays out beside the input', (tester) async {
      await pump(tester, field(const CartSummary()));

      expect(tester.takeException(), isNull);
    });

    testWidgets('and still does at a doubled font scale', (tester) async {
      await pump(tester, field(const CartSummary()), textScale: 2);

      expect(tester.takeException(), isNull);
    });

    // A rejected code keeps the input — and so the button — on screen, which
    // an applied one does not.
    testWidgets('a rejected code keeps the row intact', (tester) async {
      await pump(
        tester,
        field(
          const CartSummary(
            coupon: CartSummaryCoupon(
              code: 'SAVE10',
              valid: false,
              message: 'This coupon has expired.',
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('checkout coupon section', () {
    testWidgets('the apply button lays out beside the input', (tester) async {
      await pump(
        tester,
        CouponSection(
          appliedCoupon: null,
          isApplying: false,
          errorMessage: null,
          onApply: (_) {},
          onRemove: () {},
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('hugContent gives a row-placed button a finite width', (
    tester,
  ) async {
    const rowKey = Key('row');

    await pump(
      tester,
      Row(
        key: rowKey,
        children: [
          OutlinedButton(
            style: AppTheme.hugContent,
            onPressed: () {},
            child: const Text('BACK TO BASKET'),
          ),
          const SizedBox(width: AppDimens.space12),
          TextButton(onPressed: () {}, child: const Text('CONTINUE')),
        ],
      ),
    );

    expect(tester.takeException(), isNull);
    // Hugging, not filling: without the override the minimum width is
    // infinite, which is what blows the row up in the first place.
    expect(
      tester.getSize(find.byType(OutlinedButton)).width,
      lessThan(tester.getSize(find.byKey(rowKey)).width),
    );
  });
}
