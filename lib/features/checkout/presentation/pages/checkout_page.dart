import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/router/navigation_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/privacy_guard.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/entities/order_failures.dart';
import '../../../orders/presentation/widgets/order_pricing_summary.dart';
import '../../domain/entities/checkout_cart.dart';
import '../providers/checkout_notifier.dart';
import '../providers/checkout_state.dart';
import '../widgets/address_form_sheet.dart';
import '../widgets/address_selector.dart';
import '../widgets/coupon_section.dart';
import '../widgets/payment_method_selector.dart';

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkoutProvider);
    final notifier = ref.read(checkoutProvider.notifier);

    return PrivacyGuard(
      label: 'Checkout hidden',
      child: Scaffold(
        backgroundColor: context.palette.canvas,
        appBar: AppBar(title: const Text('Checkout')),
        body: switch (state) {
          CheckoutState(isLoading: true, cart: null) =>
            const LoadingView(message: 'Checking your basket…'),
          CheckoutState(failure: final failure?, cart: null) =>
            _LoadFailure(failure: failure, onRetry: notifier.refresh),
          _ => _Body(state: state),
        },
        bottomNavigationBar: state.cart == null
            ? null
            : _PlaceOrderBar(state: state),
      ),
    );
  }
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.failure, required this.onRetry});

  final Failure failure;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (failure is ValidationFailure) {
      final reasons = OrderFailures.reasons(failure);

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.space32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.remove_shopping_cart_outlined,
                size: 40,
                color: context.palette.warning,
              ),
              const SizedBox(height: AppDimens.space20),
              Text(
                'Your basket needs attention',
                style: context.text.headlineSmall,
              ),
              const SizedBox(height: AppDimens.space12),
              for (final reason in reasons)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.space8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('•  ', style: context.text.bodyMedium),
                      Expanded(
                        child: Text(reason, style: context.text.bodyMedium),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppDimens.space20),
              Row(
                children: [
                  OutlinedButton(
                    style: AppTheme.hugContent,
                    onPressed: () => context.popOrGo(AppRoutes.cart),
                    child: const Text('BACK TO BASKET'),
                  ),
                  const SizedBox(width: AppDimens.space12),
                  TextButton(
                    onPressed: onRetry,
                    child: const Text('RECHECK'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return FailureView(failure: failure, onRetry: onRetry);
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.state});

  final CheckoutState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(checkoutProvider.notifier);
    final cart = state.cart!;

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pageGutter,
          AppDimens.space16,
          AppDimens.pageGutter,
          AppDimens.space32,
        ),
        children: [
          if (state.isOffline) ...[
            const _OfflineCard(),
            const SizedBox(height: AppDimens.space20),
          ],

          const OrderSectionHeader(title: 'Deliver to'),
          AddressSelector(
            addresses: state.addresses,
            selectedId: state.shippingAddressId,
            onSelected: notifier.selectShippingAddress,
            onAddPressed: () => _addAddress(context, ref),
            onEdit: (address) async {
              final draft = await AddressFormSheet.show(
                context,
                initial: address,
              );
              if (draft != null) {
                await notifier.updateAddress(address.id, draft);
              }
            },
          ),

          if (state.addresses.isNotEmpty) ...[
            const SizedBox(height: AppDimens.space8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: state.billToShippingAddress,
              onChanged: (value) => notifier.setBillToShipping(value ?? true),
              title: const Text('Billing address is the same'),
            ),
            if (!state.billToShippingAddress) ...[
              const SizedBox(height: AppDimens.space8),
              const OrderSectionHeader(title: 'Bill to'),
              AddressSelector(
                addresses: state.addresses,
                selectedId: state.billingAddressId,
                onSelected: notifier.selectBillingAddress,
              ),
            ],
          ],

          const SizedBox(height: AppDimens.space24),
          const OrderSectionHeader(title: 'Payment'),
          PaymentMethodSelector(
            selected: state.paymentMethod,
            onSelected: notifier.selectPaymentMethod,
            declineWarning: state.expectsMockDecline,
          ),

          const SizedBox(height: AppDimens.space24),
          const OrderSectionHeader(title: 'Coupon'),
          CouponSection(
            appliedCoupon: state.appliedCoupon,
            isApplying: state.isApplyingCoupon,
            errorMessage: state.couponFailure?.message,
            onApply: notifier.applyCoupon,
            onRemove: notifier.removeCoupon,
          ),

          const SizedBox(height: AppDimens.space24),
          const OrderSectionHeader(title: 'Order note'),
          TextField(
            maxLines: 3,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            onChanged: notifier.setCustomerNote,
            decoration: const InputDecoration(
              hintText: 'Anything the courier should know? (optional)',
            ),
          ),

          const SizedBox(height: AppDimens.space16),
          const OrderSectionHeader(title: 'Your items'),
          _Lines(cart: cart),

          const SizedBox(height: AppDimens.space24),
          const OrderSectionHeader(title: 'Summary'),
          Container(
            padding: const EdgeInsets.all(AppDimens.space16),
            decoration: BoxDecoration(
              color: context.palette.surface,
              border: Border.all(color: context.palette.line),
              borderRadius: AppDimens.borderRadius,
            ),
            child: OrderPricingSummary(
              subtotal: cart.summary.subtotal,
              discount: cart.summary.discount,
              tax: cart.summary.tax,
              shipping: cart.summary.shipping,
              grandTotal: cart.summary.grandTotal,
              couponCode: cart.coupon?.code,
            ),
          ),

          if (state.appliedCoupon != null) ...[
            const SizedBox(height: AppDimens.space8),
            Text(
              'Your coupon is applied when the order is placed, so the total '
              'above does not include it yet.',
              style: context.text.bodySmall,
            ),
          ],

          if (state.paymentMethod == PaymentMethod.mockGateway) ...[
            const SizedBox(height: AppDimens.space16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: state.simulateFailure,
              onChanged: notifier.setSimulateFailure,
              title: const Text('Simulate a declined payment'),
              subtitle: Text(
                'For demonstrating the failure path. The order rolls back '
                'entirely — nothing is charged and nothing is created.',
                style: context.text.bodySmall,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _addAddress(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(checkoutProvider.notifier);
    final draft = await AddressFormSheet.show(
      context,
      isFirstAddress: state.addresses.isEmpty,
    );
    if (draft == null) return;

    final ok = await notifier.addAddress(draft);
    if (ok && context.mounted) {
      context.showSnack('Address saved.');
    }
  }
}

class _Lines extends StatelessWidget {
  const _Lines({required this.cart});

  final CheckoutCart cart;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.space16),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.line),
        borderRadius: AppDimens.borderRadius,
      ),
      child: Column(
        children: [
          for (var index = 0; index < cart.lines.length; index += 1) ...[
            if (index > 0) Divider(height: 1, color: palette.line),
            _LineTile(line: cart.lines[index]),
          ],
        ],
      ),
    );
  }
}

class _LineTile extends StatelessWidget {
  const _LineTile({required this.line});

  final CheckoutLine line;

  @override
  Widget build(BuildContext context) {
    final variant = line.variantLabel;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppNetworkImage(
            url: line.image,
            width: 48,
            height: 62,
            borderRadius: AppDimens.borderRadiusSm,
          ),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.name,
                  style: context.text.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (variant != null) ...[
                  const SizedBox(height: AppDimens.space2),
                  Text(variant, style: context.text.bodySmall),
                ],
                const SizedBox(height: AppDimens.space2),
                Text(
                  '${Formatters.price(line.unitPrice)} × ${line.quantity}',
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            Formatters.price(line.lineTotal),
            style: context.text.titleSmall,
          ),
        ],
      ),
    );
  }
}

class _OfflineCard extends StatelessWidget {
  const _OfflineCard();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: palette.surfaceSunken,
        borderRadius: AppDimens.borderRadius,
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, color: palette.inkMuted),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Text(
              'You are offline. Orders are confirmed against live stock and '
              'prices, so this one cannot be saved for later — reconnect to '
              'place it.',
              style: context.text.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceOrderBar extends ConsumerWidget {
  const _PlaceOrderBar({required this.state});

  final CheckoutState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final failure = state.placeFailure;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: palette.surface,
          border: Border(top: BorderSide(color: palette.line)),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pageGutter,
          AppDimens.space12,
          AppDimens.pageGutter,
          AppDimens.space12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (failure != null) ...[
              _FailureNotice(failure: failure),
              const SizedBox(height: AppDimens.space12),
            ],
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total', style: context.text.bodySmall),
                      Text(
                        Formatters.price(state.summary.grandTotal),
                        style: context.text.titleLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimens.space16),
                Expanded(
                  child: FilledButton(
                    onPressed: state.canPlaceOrder
                        ? () => _place(context, ref)
                        : null,
                    child: Text(
                      state.isPlacingOrder
                          ? 'PLACING…'
                          : state.paymentMethod == PaymentMethod.cod
                              ? 'PLACE ORDER'
                              : 'PAY & ORDER',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _place(BuildContext context, WidgetRef ref) async {
    final order = await ref.read(checkoutProvider.notifier).placeOrder();
    if (order == null || !context.mounted) return;

    context.pushReplacement(
      AppRoutes.orderConfirmationPath(order.id),
      extra: order,
    );
  }
}

class _FailureNotice extends StatelessWidget {
  const _FailureNotice({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final declined = OrderFailures.isPaymentDeclined(failure);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.space12),
      decoration: BoxDecoration(
        color: palette.dangerSubtle,
        borderRadius: AppDimens.borderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            declined ? 'Payment declined' : 'We could not place your order',
            style: context.text.titleSmall?.copyWith(color: palette.danger),
          ),
          const SizedBox(height: AppDimens.space4),
          for (final reason in OrderFailures.reasons(failure))
            Text(
              reason,
              style: context.text.bodySmall?.copyWith(color: palette.danger),
            ),
          if (declined) ...[
            const SizedBox(height: AppDimens.space8),
            Text(
              'Nothing was charged and no order was created — your basket is '
              'untouched. Try cash on delivery, or place the order again.',
              style: context.text.bodySmall?.copyWith(color: palette.danger),
            ),
          ],
        ],
      ),
    );
  }
}
