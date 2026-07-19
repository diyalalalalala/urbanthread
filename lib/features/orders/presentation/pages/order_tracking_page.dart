import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/order.dart';
import '../providers/orders_notifier.dart';
import '../providers/orders_state.dart';
import '../widgets/order_pricing_summary.dart';
import '../widgets/order_status_chip.dart';
import '../widgets/order_timeline.dart';

/// Where the parcel is.
///
/// Backed by `GET /orders/{id}/track`, a projection the backend assembles by
/// hand — it carries no prices and no address, which is why this page cannot
/// show a total or a delivery address however convenient that would be.
class OrderTrackingPage extends ConsumerWidget {
  const OrderTrackingPage({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderTrackingProvider(orderId));
    final notifier = ref.read(orderTrackingProvider(orderId).notifier);

    return Scaffold(
      backgroundColor: context.palette.canvas,
      appBar: AppBar(
        title: Text(state.tracking?.orderNumber ?? 'Tracking'),
      ),
      body: switch (state) {
        OrderTrackingState(isLoading: true) => const LoadingView(),
        OrderTrackingState(failure: final failure?) => FailureView(
            failure: failure,
            onRetry: notifier.refresh,
          ),
        OrderTrackingState(tracking: final tracking?) => _Body(
            tracking: tracking,
            onRefresh: notifier.refresh,
          ),
        _ => const LoadingView(),
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.tracking, required this.onRefresh});

  final OrderTracking tracking;
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
          AppDimens.space20,
          AppDimens.pageGutter,
          AppDimens.space32,
        ),
        children: [
          Row(
            children: [
              OrderStatusChip(status: tracking.status),
              const Spacer(),
              Text(
                Formatters.items(tracking.totalItems),
                style: context.text.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space16),
          Text(tracking.status.description, style: context.text.bodyLarge),
          const SizedBox(height: AppDimens.space24),

          OrderProgressStepper(status: tracking.status),
          const SizedBox(height: AppDimens.space32),

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
                // `placedAt` is the order's `createdAt` under another name —
                // the tracking route renames it on the way out.
                _Fact(
                  label: 'Placed',
                  value: Formatters.dateTime(tracking.placedAt),
                ),
                if (tracking.hasTrackingNumber)
                  _Fact(
                    label: 'Tracking number',
                    value: tracking.trackingNumber!,
                  ),
                if (tracking.estimatedDeliveryDate != null &&
                    tracking.deliveredAt == null)
                  _Fact(
                    label: 'Estimated delivery',
                    value: Formatters.date(tracking.estimatedDeliveryDate),
                  ),
                if (tracking.deliveredAt != null)
                  _Fact(
                    label: 'Delivered',
                    value: Formatters.dateTime(tracking.deliveredAt),
                  ),
                if (tracking.cancelledAt != null)
                  _Fact(
                    label: 'Cancelled',
                    value: Formatters.dateTime(tracking.cancelledAt),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.space32),

          const OrderSectionHeader(title: 'History'),
          OrderTimeline(
            entries: tracking.chronologicalTimeline,
            currentStatus: tracking.status,
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.space4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              child: Text(
                label.toUpperCase(),
                style: AppTypography.eyebrow.copyWith(
                  color: context.palette.inkSubtle,
                ),
              ),
            ),
            Expanded(
              child: Text(value, style: context.text.bodyMedium),
            ),
          ],
        ),
      );
}
