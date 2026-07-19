import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/cart_summary.dart';

/// The money block.
///
/// Every figure comes from the server, which recomputes them at checkout and
/// charges what *it* derives — so this never does arithmetic of its own beyond
/// the free-shipping progress bar.
class CartSummaryCard extends StatelessWidget {
  const CartSummaryCard({required this.summary, super.key, this.isEstimated = false});

  final CartSummary summary;

  /// True while an optimistic edit is in flight and the totals are the
  /// client's estimate rather than the server's. Said out loud rather than
  /// hidden — a number that silently corrects itself is worse than one that
  /// admits it is provisional.
  final bool isEstimated;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(AppDimens.space20),
      decoration: BoxDecoration(
        color: palette.surfaceSunken,
        borderRadius: AppDimens.borderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('ORDER SUMMARY', style: AppTypography.eyebrow),
              const Spacer(),
              if (isEstimated)
                Text(
                  'UPDATING',
                  style: AppTypography.eyebrow.copyWith(
                    color: palette.inkSubtle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.space16),
          _Row(
            label: summary.itemCount == 0
                ? 'Subtotal'
                : 'Subtotal (${Formatters.items(summary.itemCount)})',
            value: Formatters.price(summary.subtotal),
          ),
          if (summary.discount > 0)
            _Row(
              label: summary.coupon == null
                  ? 'Discount'
                  : 'Discount (${summary.coupon!.code})',
              value: '− ${Formatters.price(summary.discount)}',
              valueColor: palette.success,
            ),
          _Row(
            label: 'Tax',
            value: Formatters.price(summary.tax),
          ),
          _Row(
            label: 'Shipping',
            value: summary.shipping <= 0
                ? 'Free'
                : Formatters.price(summary.shipping),
            valueColor: summary.shipping <= 0 ? palette.success : null,
          ),
          const SizedBox(height: AppDimens.space16),
          Divider(height: 1, color: palette.line),
          const SizedBox(height: AppDimens.space16),
          Row(
            children: [
              Text('Total', style: context.text.titleMedium),
              const Spacer(),
              Text(
                // `grandTotal`, never `total` — the latter key does not exist
                // on this API.
                Formatters.price(summary.grandTotal),
                style: AppTypography.price.copyWith(
                  color: palette.ink,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          if (summary.currency != 'NPR') ...[
            const SizedBox(height: AppDimens.space4),
            Text(
              'Amounts in ${summary.currency}',
              style: context.text.bodySmall?.copyWith(color: palette.inkMuted),
            ),
          ],
          const SizedBox(height: AppDimens.space16),
          FreeShippingProgress(summary: summary),
        ],
      ),
    );
  }
}

/// How far the cart is from free delivery.
///
/// Split out because it is the one part of the summary that is a nudge rather
/// than a statement of account, and it disappears entirely on an empty cart —
/// where the threshold is not information, it is an obstacle.
class FreeShippingProgress extends StatelessWidget {
  const FreeShippingProgress({required this.summary, super.key});

  final CartSummary summary;

  @override
  Widget build(BuildContext context) {
    if (summary.subtotal <= 0) return const SizedBox.shrink();

    final palette = context.palette;
    final eligible = summary.freeShippingEligible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              eligible ? Icons.check_circle_outline : Icons.local_shipping_outlined,
              size: 14,
              color: eligible ? palette.success : palette.inkMuted,
            ),
            const SizedBox(width: AppDimens.space8),
            Expanded(
              child: Text(
                eligible
                    ? 'Your order ships free.'
                    : 'Add ${Formatters.price(summary.amountToFreeShipping)} '
                        'for free shipping.',
                style: context.text.bodySmall?.copyWith(
                  color: eligible ? palette.success : palette.inkMuted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.space8),
        ClipRRect(
          borderRadius: AppDimens.borderRadiusSm,
          child: LinearProgressIndicator(
            value: summary.freeShippingProgress,
            minHeight: 4,
            backgroundColor: palette.line,
            valueColor: AlwaysStoppedAnimation<Color>(
              eligible ? palette.success : palette.accent,
            ),
          ),
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
        padding: const EdgeInsets.only(bottom: AppDimens.space8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: context.text.bodyMedium?.copyWith(
                  color: context.palette.inkMuted,
                ),
              ),
            ),
            Text(
              value,
              style: context.text.bodyMedium?.copyWith(
                color: valueColor ?? context.palette.ink,
              ),
            ),
          ],
        ),
      );
}
