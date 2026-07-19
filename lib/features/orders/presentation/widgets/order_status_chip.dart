import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/order.dart';

/// Colour pairing for a status, drawn from the brand palette.
///
/// Kept as one function rather than scattered `switch`es so the tracking
/// stepper, the list row and the detail header cannot drift apart on what
/// "shipped" looks like.
({Color foreground, Color background}) orderStatusColors(
  BuildContext context,
  OrderStatus status,
) {
  final palette = context.palette;

  return switch (status) {
    OrderStatus.pending =>
      (foreground: palette.warning, background: palette.warningSubtle),
    OrderStatus.confirmed ||
    OrderStatus.packed ||
    OrderStatus.shipped ||
    OrderStatus.outForDelivery =>
      (foreground: palette.info, background: palette.infoSubtle),
    OrderStatus.delivered =>
      (foreground: palette.success, background: palette.successSubtle),
    OrderStatus.cancelled =>
      (foreground: palette.danger, background: palette.dangerSubtle),
    // Returned is not a failure — it is a completed, if unhappy, outcome. A
    // neutral treatment says "closed" without the alarm of red.
    OrderStatus.returned =>
      (foreground: palette.inkMuted, background: palette.surfaceSunken),
  };
}

IconData orderStatusIcon(OrderStatus status) => switch (status) {
      OrderStatus.pending => Icons.schedule_outlined,
      OrderStatus.confirmed => Icons.task_alt_outlined,
      OrderStatus.packed => Icons.inventory_2_outlined,
      OrderStatus.shipped => Icons.local_shipping_outlined,
      OrderStatus.outForDelivery => Icons.moped_outlined,
      OrderStatus.delivered => Icons.check_circle_outline,
      OrderStatus.cancelled => Icons.cancel_outlined,
      OrderStatus.returned => Icons.assignment_return_outlined,
    };

/// The small uppercase status badge, used everywhere an order is listed.
class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({required this.status, super.key, this.dense = false});

  final OrderStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colors = orderStatusColors(context, status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? AppDimens.space8 : AppDimens.space12,
        vertical: dense ? AppDimens.space4 : AppDimens.space8,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: AppDimens.borderRadius,
      ),
      child: Text(
        status.label.toUpperCase(),
        style: AppTypography.eyebrow.copyWith(color: colors.foreground),
      ),
    );
  }
}

/// The payment state badge, shown beside the status on the detail screen.
class PaymentStatusChip extends StatelessWidget {
  const PaymentStatusChip({required this.payment, super.key});

  final OrderPayment payment;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final (Color foreground, Color background, String label) = switch (
        payment.status) {
      // Pending on a cash order is the normal, expected state rather than a
      // problem — the courier has simply not collected yet — so it is worded
      // as the plan, not as an outstanding debt.
      PaymentStatus.pending when payment.method == PaymentMethod.cod => (
          palette.inkMuted,
          palette.surfaceSunken,
          'Pay on delivery',
        ),
      PaymentStatus.pending => (
          palette.warning,
          palette.warningSubtle,
          'Payment pending',
        ),
      PaymentStatus.paid => (palette.success, palette.successSubtle, 'Paid'),
      PaymentStatus.failed => (
          palette.danger,
          palette.dangerSubtle,
          'Payment failed',
        ),
      PaymentStatus.refunded => (palette.info, palette.infoSubtle, 'Refunded'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space8,
        vertical: AppDimens.space4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppDimens.borderRadius,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.eyebrow.copyWith(color: foreground),
      ),
    );
  }
}

/// Badge for a line whose return is in progress.
class ReturnStatusChip extends StatelessWidget {
  const ReturnStatusChip({required this.status, super.key});

  final ReturnStatus status;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final (Color foreground, Color background) = switch (status) {
      ReturnStatus.requested => (palette.warning, palette.warningSubtle),
      ReturnStatus.approved => (palette.info, palette.infoSubtle),
      ReturnStatus.rejected => (palette.danger, palette.dangerSubtle),
      ReturnStatus.refunded => (palette.success, palette.successSubtle),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space8,
        vertical: AppDimens.space2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppDimens.borderRadiusSm,
      ),
      child: Text(
        status.label.toUpperCase(),
        style: AppTypography.eyebrow.copyWith(
          color: foreground,
          fontSize: 10,
        ),
      ),
    );
  }
}
