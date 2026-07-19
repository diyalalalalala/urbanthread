import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/order.dart';

/// The money breakdown, shared by the order detail screen and the checkout
/// review step.
///
/// The total row reads `grandTotal`. There is no `total` field on this API,
/// and a summary that quietly showed zero would be the worst possible bug on
/// this particular screen.
class OrderPricingSummary extends StatelessWidget {
  const OrderPricingSummary({
    required this.subtotal,
    required this.grandTotal,
    super.key,
    this.discount = 0,
    this.tax = 0,
    this.shipping = 0,
    this.taxLabel = 'Tax',
    this.couponCode,
  });

  /// Builds one straight from a placed order.
  factory OrderPricingSummary.fromOrder(Order order, {Key? key}) =>
      OrderPricingSummary(
        key: key,
        subtotal: order.pricing.subtotal,
        discount: order.pricing.discount,
        tax: order.pricing.tax,
        shipping: order.pricing.shipping,
        grandTotal: order.pricing.grandTotal,
        taxLabel: order.pricing.taxLabel,
        couponCode: order.coupon.isApplied ? order.coupon.code : null,
      );

  final double subtotal;
  final double discount;
  final double tax;
  final double shipping;
  final double grandTotal;
  final String taxLabel;
  final String? couponCode;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      children: [
        _Row(label: 'Subtotal', value: Formatters.price(subtotal)),
        if (discount > 0)
          _Row(
            label: couponCode == null ? 'Discount' : 'Discount ($couponCode)',
            // Signed, so it reads as a subtraction rather than a second
            // charge sitting next to the others.
            value: '− ${Formatters.price(discount)}',
            valueColor: palette.success,
          ),
        _Row(label: taxLabel, value: Formatters.price(tax)),
        _Row(
          label: 'Shipping',
          // Free shipping is a benefit worth naming. "Rs 0" reads as an
          // absent value; "Free" reads as something earned.
          value: shipping <= 0 ? 'Free' : Formatters.price(shipping),
          valueColor: shipping <= 0 ? palette.success : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.space12),
          child: Divider(height: 1, color: palette.line),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total', style: context.text.titleMedium),
            Text(
              Formatters.price(grandTotal),
              style: AppTypography.price.copyWith(color: palette.ink),
            ),
          ],
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.space4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: context.text.bodyMedium),
            Text(
              value,
              style: context.text.bodyMedium?.copyWith(color: valueColor),
            ),
          ],
        ),
      );
}

/// A labelled address block, used for both shipping and billing.
class OrderAddressBlock extends StatelessWidget {
  const OrderAddressBlock({
    required this.title,
    required this.address,
    super.key,
  });

  final String title;
  final OrderAddress address;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTypography.eyebrow.copyWith(
              color: context.palette.inkSubtle,
            ),
          ),
          const SizedBox(height: AppDimens.space8),
          Text(address.fullName, style: context.text.titleSmall),
          const SizedBox(height: AppDimens.space2),
          Text(address.singleLine, style: context.text.bodySmall),
          const SizedBox(height: AppDimens.space2),
          Text(address.phone, style: context.text.bodySmall),
        ],
      );
}

/// A section heading with a rule under it, matching the web client's
/// editorial section breaks.
class OrderSectionHeader extends StatelessWidget {
  const OrderSectionHeader({required this.title, super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppDimens.space12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: AppTypography.eyebrow.copyWith(
                  color: context.palette.inkSubtle,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      );
}
