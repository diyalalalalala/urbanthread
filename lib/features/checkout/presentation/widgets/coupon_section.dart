import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/coupon.dart';
import '../providers/checkout_notifier.dart';

/// Enter a code, or pick one from what the account can use.
///
/// The discount shown before the order is placed is always an **estimate**,
/// and is labelled as one. `POST /coupons/validate` scores the code against
/// the subtotal it is handed; the binding figure is recomputed server-side
/// inside the order transaction, where a category-restricted coupon is
/// applied only to the lines it may touch.
class CouponSection extends ConsumerStatefulWidget {
  const CouponSection({
    required this.appliedCoupon,
    required this.isApplying,
    required this.errorMessage,
    required this.onApply,
    required this.onRemove,
    super.key,
  });

  final CouponPreview? appliedCoupon;
  final bool isApplying;
  final String? errorMessage;
  final ValueChanged<String> onApply;
  final VoidCallback onRemove;

  @override
  ConsumerState<CouponSection> createState() => _CouponSectionState();
}

class _CouponSectionState extends ConsumerState<CouponSection> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final applied = widget.appliedCoupon;

    if (applied != null) {
      return Container(
        padding: const EdgeInsets.all(AppDimens.space16),
        decoration: BoxDecoration(
          color: palette.successSubtle,
          borderRadius: AppDimens.borderRadius,
        ),
        child: Row(
          children: [
            Icon(Icons.local_offer_outlined, size: 18, color: palette.success),
            const SizedBox(width: AppDimens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    applied.code,
                    style: context.text.titleSmall?.copyWith(
                      color: palette.success,
                    ),
                  ),
                  const SizedBox(height: AppDimens.space2),
                  Text(
                    'About ${Formatters.price(applied.estimatedDiscount)} off — '
                    'confirmed when you place the order.',
                    style: context.text.bodySmall
                        ?.copyWith(color: palette.success),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: widget.onRemove,
              child: const Text('REMOVE'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Coupon code',
                  errorText: widget.errorMessage,
                ),
                onSubmitted: widget.onApply,
              ),
            ),
            const SizedBox(width: AppDimens.space8),
            OutlinedButton(
              onPressed: widget.isApplying
                  ? null
                  : () => widget.onApply(_controller.text),
              child: Text(widget.isApplying ? '…' : 'APPLY'),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.space8),
        TextButton.icon(
          onPressed: _showAvailableCoupons,
          icon: const Icon(Icons.local_offer_outlined, size: 16),
          label: const Text('SEE AVAILABLE OFFERS'),
        ),
      ],
    );
  }

  Future<void> _showAvailableCoupons() async {
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AvailableCouponsSheet(),
    );

    if (code != null && mounted) {
      _controller.text = code;
      widget.onApply(code);
    }
  }
}

/// The offers this account could still use, scored against the basket.
class _AvailableCouponsSheet extends ConsumerWidget {
  const _AvailableCouponsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupons = ref.watch(availableCouponsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(AppDimens.pageGutter),
        child: coupons.when(
          loading: () => const LoadingView(),
          error: (error, _) => EmptyView(
            icon: Icons.local_offer_outlined,
            title: 'Could not load offers',
            message: error.toString(),
          ),
          data: (list) {
            if (list.isEmpty) {
              return const EmptyView(
                icon: Icons.local_offer_outlined,
                title: 'No offers right now',
                message: 'Check back soon — new codes appear regularly.',
              );
            }

            return ListView(
              controller: scrollController,
              children: [
                Text('Available offers', style: context.text.headlineSmall),
                const SizedBox(height: AppDimens.space16),
                for (final coupon in list)
                  _CouponTile(
                    coupon: coupon,
                    // A coupon below its minimum spend is shown but not
                    // selectable — hiding it would lose the "spend Rs 400
                    // more" nudge, which is the more useful message.
                    onTap: coupon.isApplicable
                        ? () => Navigator.of(context).pop(coupon.code)
                        : null,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CouponTile extends StatelessWidget {
  const _CouponTile({required this.coupon, this.onTap});

  final AvailableCoupon coupon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final enabled = onTap != null;

    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppDimens.space12),
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
                  Text(coupon.code, style: context.text.titleSmall),
                  const SizedBox(width: AppDimens.space8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.space8,
                      vertical: AppDimens.space2,
                    ),
                    decoration: BoxDecoration(
                      color: palette.accentSubtle,
                      borderRadius: AppDimens.borderRadiusSm,
                    ),
                    child: Text(
                      coupon.valueLabel.toUpperCase(),
                      style: AppTypography.eyebrow.copyWith(
                        fontSize: 9,
                        color: palette.accent,
                      ),
                    ),
                  ),
                ],
              ),
              if (coupon.description.isNotEmpty) ...[
                const SizedBox(height: AppDimens.space4),
                Text(coupon.description, style: context.text.bodySmall),
              ],
              const SizedBox(height: AppDimens.space8),
              Text(
                coupon.isApplicable
                    ? 'Saves about ${Formatters.price(coupon.estimatedDiscount)}'
                    : 'Spend ${Formatters.price(coupon.amountToQualify)} more '
                        'to use this',
                style: context.text.bodySmall?.copyWith(
                  color: coupon.isApplicable ? palette.success : palette.warning,
                ),
              ),
              if (coupon.isRestricted) ...[
                const SizedBox(height: AppDimens.space4),
                Text(
                  'Applies to selected brands or categories only.',
                  style: context.text.labelMedium,
                ),
              ],
              if (coupon.expiresAt != null) ...[
                const SizedBox(height: AppDimens.space4),
                Text(
                  'Expires ${Formatters.date(coupon.expiresAt)}',
                  style: context.text.labelMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
