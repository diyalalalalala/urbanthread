import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/order.dart';
import '../providers/orders_notifier.dart';
import '../providers/orders_state.dart';
import '../widgets/order_card.dart';
import '../widgets/order_pricing_summary.dart';
import '../widgets/order_status_chip.dart';
import '../widgets/order_timeline.dart';
import 'return_request_page.dart';

/// Everything about one order: what was bought, where it is going, what it
/// cost, and the two actions a customer can still take.
class OrderDetailPage extends ConsumerWidget {
  const OrderDetailPage({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderDetailProvider(orderId));
    final notifier = ref.read(orderDetailProvider(orderId).notifier);
    final isOnline = ref.watch(isOnlineProvider);

    // A refused cancel or return is transient — the order itself is still
    // valid and on screen, so it belongs in a snack bar rather than replacing
    // the page with an error.
    ref.listen(orderDetailProvider(orderId), (previous, next) {
      final failure = next.actionFailure;
      if (failure != null && failure != previous?.actionFailure) {
        context.showSnack(failure.message, isError: true);
        notifier.clearActionFailure();
      }
    });

    final order = state.order;

    return Scaffold(
      backgroundColor: context.palette.canvas,
      appBar: AppBar(
        title: Text(order?.orderNumber ?? 'Order'),
        actions: [
          if (order != null)
            IconButton(
              tooltip: 'Track',
              icon: const Icon(Icons.local_shipping_outlined),
              onPressed: () =>
                  context.push(AppRoutes.orderTrackingPath(order.id)),
            ),
        ],
      ),
      body: switch (state) {
        OrderDetailState(isLoading: true, order: null) => const LoadingView(),
        OrderDetailState(failure: final failure?, order: null) => FailureView(
            failure: failure,
            onRetry: notifier.refresh,
          ),
        _ when order != null => _Body(
            order: order,
            isOnline: isOnline,
            isSubmitting: state.isSubmitting,
            onRefresh: notifier.refresh,
          ),
        _ => const LoadingView(),
      },
      bottomNavigationBar: order == null
          ? null
          : _Actions(
              order: order,
              isSubmitting: state.isSubmitting,
              isOnline: isOnline,
              orderId: orderId,
            ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.order,
    required this.isOnline,
    required this.isSubmitting,
    required this.onRefresh,
  });

  final Order order;
  final bool isOnline;
  final bool isSubmitting;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pageGutter,
          AppDimens.space16,
          AppDimens.pageGutter,
          AppDimens.space32,
        ),
        children: [
          if (!isOnline) ...[
            const OfflineBanner(),
            const SizedBox(height: AppDimens.space16),
          ],

          // ── Status ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppDimens.space16),
            decoration: BoxDecoration(
              color: palette.surface,
              border: Border.all(color: palette.line),
              borderRadius: AppDimens.borderRadius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    OrderStatusChip(status: order.status),
                    const SizedBox(width: AppDimens.space8),
                    PaymentStatusChip(payment: order.payment),
                  ],
                ),
                const SizedBox(height: AppDimens.space12),
                Text(order.status.description, style: context.text.bodyMedium),
                const SizedBox(height: AppDimens.space8),
                Text(
                  'Placed ${Formatters.dateTime(order.createdAt)}',
                  style: context.text.bodySmall,
                ),
                if (order.estimatedDeliveryDate != null &&
                    !order.status.isTerminal) ...[
                  const SizedBox(height: AppDimens.space2),
                  Text(
                    'Estimated delivery '
                    '${Formatters.date(order.estimatedDeliveryDate)}',
                    style: context.text.bodySmall,
                  ),
                ],
                if (order.trackingNumber != null) ...[
                  const SizedBox(height: AppDimens.space2),
                  Text(
                    'Tracking ${order.trackingNumber}',
                    style: context.text.bodySmall,
                  ),
                ],
                if (order.cancellationReason.isNotEmpty) ...[
                  const SizedBox(height: AppDimens.space8),
                  Text(
                    'Reason: ${order.cancellationReason}',
                    style: context.text.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppDimens.space24),

          // ── Items ─────────────────────────────────────────────────
          OrderSectionHeader(
            title: 'Items',
            trailing: Text(
              Formatters.items(order.totalItems),
              style: context.text.bodySmall,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.space16,
            ),
            decoration: BoxDecoration(
              color: palette.surface,
              border: Border.all(color: palette.line),
              borderRadius: AppDimens.borderRadius,
            ),
            child: Column(
              children: [
                for (var index = 0; index < order.items.length; index += 1) ...[
                  if (index > 0) Divider(height: 1, color: palette.line),
                  OrderItemTile(item: order.items[index]),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppDimens.space24),

          // ── Money ─────────────────────────────────────────────────
          const OrderSectionHeader(title: 'Payment'),
          Container(
            padding: const EdgeInsets.all(AppDimens.space16),
            decoration: BoxDecoration(
              color: palette.surface,
              border: Border.all(color: palette.line),
              borderRadius: AppDimens.borderRadius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OrderPricingSummary.fromOrder(order),
                const SizedBox(height: AppDimens.space16),
                Divider(height: 1, color: palette.line),
                const SizedBox(height: AppDimens.space16),
                _PaymentDetails(payment: order.payment),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.space24),

          // ── Addresses ─────────────────────────────────────────────
          const OrderSectionHeader(title: 'Delivery'),
          Container(
            padding: const EdgeInsets.all(AppDimens.space16),
            decoration: BoxDecoration(
              color: palette.surface,
              border: Border.all(color: palette.line),
              borderRadius: AppDimens.borderRadius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OrderAddressBlock(
                  title: 'Shipping address',
                  address: order.shippingAddress,
                ),
                // Only shown when it differs — repeating an identical address
                // under a second heading just makes the screen longer.
                if (order.hasSeparateBillingAddress) ...[
                  const SizedBox(height: AppDimens.space20),
                  Divider(height: 1, color: palette.line),
                  const SizedBox(height: AppDimens.space20),
                  OrderAddressBlock(
                    title: 'Billing address',
                    address: order.billingAddress,
                  ),
                ],
                if (order.customerNote.isNotEmpty) ...[
                  const SizedBox(height: AppDimens.space20),
                  Divider(height: 1, color: palette.line),
                  const SizedBox(height: AppDimens.space20),
                  Text(
                    'YOUR NOTE',
                    style: AppTypography.eyebrow.copyWith(
                      color: palette.inkSubtle,
                    ),
                  ),
                  const SizedBox(height: AppDimens.space8),
                  Text(order.customerNote, style: context.text.bodySmall),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppDimens.space24),

          // ── History ───────────────────────────────────────────────
          const OrderSectionHeader(title: 'History'),
          OrderTimeline(
            entries: order.chronologicalTimeline,
            currentStatus: order.status,
          ),
        ],
      ),
    );
  }
}

class _PaymentDetails extends StatelessWidget {
  const _PaymentDetails({required this.payment});

  final OrderPayment payment;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Method', style: context.text.bodyMedium),
              Text(payment.method.label, style: context.text.bodyMedium),
            ],
          ),
          if (payment.paidAt != null) ...[
            const SizedBox(height: AppDimens.space4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Paid', style: context.text.bodyMedium),
                Text(
                  Formatters.dateTime(payment.paidAt),
                  style: context.text.bodyMedium,
                ),
              ],
            ),
          ],
          if (payment.transactionId != null) ...[
            const SizedBox(height: AppDimens.space4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reference', style: context.text.bodyMedium),
                Flexible(
                  child: Text(
                    payment.transactionId!,
                    style: context.text.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (payment.isRefunded) ...[
            const SizedBox(height: AppDimens.space4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Refunded', style: context.text.bodyMedium),
                Text(
                  Formatters.price(payment.refundAmount),
                  style: context.text.bodyMedium?.copyWith(
                    color: context.palette.success,
                  ),
                ),
              ],
            ),
          ],
          if (payment.failureReason.isNotEmpty) ...[
            const SizedBox(height: AppDimens.space8),
            Text(
              payment.failureReason,
              style: context.text.bodySmall?.copyWith(
                color: context.palette.danger,
              ),
            ),
          ],
        ],
      );
}

/// The action bar. Renders nothing when neither action applies, which is the
/// case for most orders most of the time.
class _Actions extends ConsumerWidget {
  const _Actions({
    required this.order,
    required this.isSubmitting,
    required this.isOnline,
    required this.orderId,
  });

  final Order order;
  final bool isSubmitting;
  final bool isOnline;
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canCancel = order.isCancellable;
    final canReturn = order.canRequestReturn;

    if (!canCancel && !canReturn) return const SizedBox.shrink();

    final palette = context.palette;
    final daysLeft = order.returnWindowDaysRemaining;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        AppDimens.pageGutter,
        AppDimens.space12,
        AppDimens.pageGutter,
        AppDimens.space12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canReturn && daysLeft != null) ...[
            Text(
              daysLeft == 0
                  ? 'The return window closes today.'
                  : '$daysLeft ${daysLeft == 1 ? 'day' : 'days'} left to '
                      'request a return.',
              style: context.text.bodySmall,
            ),
            const SizedBox(height: AppDimens.space8),
          ],
          if (canCancel)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                // Both actions move stock server-side, so neither is offered
                // offline — a queued cancellation could not be honoured.
                onPressed: isSubmitting || !isOnline
                    ? null
                    : () => _confirmCancel(context, ref),
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.danger,
                  side: BorderSide(color: palette.danger),
                ),
                child: Text(
                  isSubmitting ? 'WORKING…' : 'CANCEL ORDER',
                ),
              ),
            ),
          if (canReturn)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: isSubmitting || !isOnline
                    ? null
                    : () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ReturnRequestPage(order: order),
                          ),
                        ),
                child: const Text('REQUEST A RETURN'),
              ),
            ),
          if (!isOnline) ...[
            const SizedBox(height: AppDimens.space8),
            Text(
              'Reconnect to change this order.',
              style: context.text.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel this order?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The items go back on sale and any payment is refunded. This '
              'cannot be undone.',
              style: dialogContext.text.bodyMedium,
            ),
            const SizedBox(height: AppDimens.space16),
            TextField(
              controller: controller,
              maxLength: 300,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'Tell us why, if you like',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('KEEP ORDER'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('CANCEL ORDER'),
          ),
        ],
      ),
    );

    final reason = controller.text;
    controller.dispose();

    if (confirmed != true || !context.mounted) return;

    final ok = await ref
        .read(orderDetailProvider(orderId).notifier)
        .cancel(reason: reason);

    // The failure path already surfaces through the page's listener, so only
    // the success needs saying here.
    if (ok && context.mounted) {
      context.showSnack('Your order has been cancelled.');
    }
  }
}
