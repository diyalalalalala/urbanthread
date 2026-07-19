import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/presentation/widgets/order_pricing_summary.dart';
import '../../../orders/presentation/widgets/order_status_chip.dart';

/// Confirmation, after a successful `POST /orders`.
///
/// Takes the placed order as a value rather than re-fetching it by id: the
/// checkout response *is* the finished order, already in its settled state.
/// A round trip here would only risk showing a spinner — or an error — on the
/// one screen that must reassure.
class OrderSuccessPage extends ConsumerWidget {
  const OrderSuccessPage({required this.order, super.key});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final isPaid = order.payment.isPaid;

    return PopScope(
      // The order is placed and the basket is gone; there is no checkout to
      // return to. Back leaves for the order itself instead.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(AppRoutes.orderDetailPath(order.id));
      },
      child: Scaffold(
        backgroundColor: palette.canvas,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.pageGutter,
              AppDimens.space40,
              AppDimens.pageGutter,
              AppDimens.space32,
            ),
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: palette.successSubtle,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 34,
                    color: palette.success,
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.space24),
              Text(
                'Thank you',
                textAlign: TextAlign.center,
                style: context.text.displaySmall,
              ),
              const SizedBox(height: AppDimens.space8),
              Text(
                isPaid
                    ? 'Your payment went through and your order is confirmed.'
                    : 'Your order is in. You will pay when it arrives.',
                textAlign: TextAlign.center,
                style: context.text.bodyLarge,
              ),
              const SizedBox(height: AppDimens.space24),

              // The reference customers quote to support. Given its own
              // treatment because it is the single most useful thing on the
              // page.
              Container(
                padding: const EdgeInsets.all(AppDimens.space16),
                decoration: BoxDecoration(
                  color: palette.surface,
                  border: Border.all(color: palette.line),
                  borderRadius: AppDimens.borderRadius,
                ),
                child: Column(
                  children: [
                    Text('ORDER NUMBER', style: context.text.labelSmall),
                    const SizedBox(height: AppDimens.space4),
                    Text(
                      order.orderNumber,
                      style: context.text.headlineSmall,
                    ),
                    const SizedBox(height: AppDimens.space12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OrderStatusChip(status: order.status, dense: true),
                        const SizedBox(width: AppDimens.space8),
                        PaymentStatusChip(payment: order.payment),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.space24),
              const OrderSectionHeader(title: 'What happens next'),
              _NextSteps(order: order),

              const SizedBox(height: AppDimens.space24),
              const OrderSectionHeader(title: 'Summary'),
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
                    Text(
                      Formatters.items(order.totalItems),
                      style: context.text.bodySmall,
                    ),
                    const SizedBox(height: AppDimens.space12),
                    OrderPricingSummary.fromOrder(order),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.space24),
              const OrderSectionHeader(title: 'Delivering to'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimens.space16),
                decoration: BoxDecoration(
                  color: palette.surface,
                  border: Border.all(color: palette.line),
                  borderRadius: AppDimens.borderRadius,
                ),
                child: OrderAddressBlock(
                  title: 'Shipping address',
                  address: order.shippingAddress,
                ),
              ),

              const SizedBox(height: AppDimens.space32),
              FilledButton(
                onPressed: () =>
                    context.go(AppRoutes.orderDetailPath(order.id)),
                child: const Text('VIEW ORDER'),
              ),
              const SizedBox(height: AppDimens.space12),
              OutlinedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('CONTINUE SHOPPING'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The next steps, which genuinely differ by payment method.
///
/// Cash on delivery leaves the order `pending` with the payment `pending` —
/// the courier collects, and only then does the backend mark it paid. The
/// mock gateway settles during checkout, so that order arrives already
/// `confirmed` and `paid` and skips a stage.
class _NextSteps extends StatelessWidget {
  const _NextSteps({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final isCod = order.payment.method == PaymentMethod.cod;

    final steps = <({IconData icon, String title, String detail})>[
      if (isCod)
        (
          icon: Icons.task_alt_outlined,
          title: 'We confirm your order',
          detail: 'Usually within a few hours. You will get an email as soon '
              'as it is confirmed.',
        )
      else
        (
          icon: Icons.check_circle_outline,
          title: 'Payment received',
          detail: 'Your order is confirmed and already being prepared.',
        ),
      (
        icon: Icons.inventory_2_outlined,
        title: 'We pack it',
        detail: 'Your items are picked and packed at our warehouse.',
      ),
      (
        icon: Icons.local_shipping_outlined,
        title: 'On its way',
        detail: order.estimatedDeliveryDate == null
            ? 'You will get a tracking number when it ships.'
            : 'Estimated delivery '
                '${Formatters.date(order.estimatedDeliveryDate)}.',
      ),
      if (isCod)
        (
          icon: Icons.payments_outlined,
          title: 'Pay the courier',
          detail: 'Have ${Formatters.price(order.pricing.grandTotal)} ready in '
              'cash when your parcel arrives.',
        )
      else
        (
          icon: Icons.home_outlined,
          title: 'Delivered',
          detail: 'Nothing left to pay — just answer the door.',
        ),
    ];

    return Column(
      children: [
        for (final step in steps)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.space16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(step.icon, size: 20, color: context.palette.inkMuted),
                const SizedBox(width: AppDimens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.title, style: context.text.titleSmall),
                      const SizedBox(height: AppDimens.space2),
                      Text(step.detail, style: context.text.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
