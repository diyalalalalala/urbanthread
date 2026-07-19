import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/order.dart';
import 'order_status_chip.dart';

/// One row of the order history.
///
/// Built to survive a lean payload: `GET /orders/my-orders` drops the
/// `totalItems` virtual, so the count shown here comes from the entity's
/// fallback rather than the wire. Nothing on this card may assume a virtual
/// is present.
class OrderCard extends StatelessWidget {
  const OrderCard({required this.order, super.key, this.onTap});

  final Order order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final preview = order.items.take(3).toList(growable: false);
    final overflow = order.items.length - preview.length;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: palette.surface,
          border: Border.all(color: palette.line),
          borderRadius: AppDimens.borderRadius,
        ),
        padding: const EdgeInsets.all(AppDimens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        style: context.text.titleSmall,
                      ),
                      const SizedBox(height: AppDimens.space2),
                      Text(
                        Formatters.date(order.createdAt),
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                ),
                OrderStatusChip(status: order.status, dense: true),
              ],
            ),
            const SizedBox(height: AppDimens.space16),
            Row(
              children: [
                for (final item in preview) ...[
                  AppNetworkImage(
                    url: item.image,
                    width: 44,
                    height: 56,
                    borderRadius: AppDimens.borderRadiusSm,
                  ),
                  const SizedBox(width: AppDimens.space8),
                ],
                if (overflow > 0)
                  Container(
                    width: 44,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: palette.surfaceSunken,
                      borderRadius: AppDimens.borderRadiusSm,
                    ),
                    child: Text(
                      '+$overflow',
                      style: context.text.labelMedium,
                    ),
                  ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Formatters.items(order.totalItems),
                      style: context.text.bodySmall,
                    ),
                    const SizedBox(height: AppDimens.space2),
                    Text(
                      Formatters.price(order.pricing.grandTotal),
                      style: AppTypography.price.copyWith(
                        fontSize: 17,
                        color: palette.ink,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (order.returnStatus != null) ...[
              const SizedBox(height: AppDimens.space12),
              ReturnStatusChip(status: order.returnStatus!),
            ],
          ],
        ),
      ),
    );
  }
}

/// A single purchased line, as shown on the detail screen.
class OrderItemTile extends StatelessWidget {
  const OrderItemTile({required this.item, super.key, this.trailing});

  final OrderItem item;

  /// A checkbox on the return screen; nothing elsewhere.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final variant = item.variantLabel;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: AppDimens.space8),
          ],
          AppNetworkImage(
            url: item.image,
            width: 56,
            height: 72,
            borderRadius: AppDimens.borderRadiusSm,
          ),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.brandName.isNotEmpty)
                  Text(
                    item.brandName.toUpperCase(),
                    style: AppTypography.eyebrow.copyWith(
                      color: context.palette.inkSubtle,
                    ),
                  ),
                const SizedBox(height: AppDimens.space4),
                Text(
                  item.name,
                  style: context.text.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (variant != null) ...[
                  const SizedBox(height: AppDimens.space4),
                  Text(variant, style: context.text.bodySmall),
                ],
                const SizedBox(height: AppDimens.space4),
                Text(
                  '${Formatters.price(item.unitPrice)} × ${item.quantity}',
                  style: context.text.bodySmall,
                ),
                if (item.returnStatus != null) ...[
                  const SizedBox(height: AppDimens.space8),
                  ReturnStatusChip(status: item.returnStatus!),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppDimens.space8),
          Text(
            Formatters.price(item.lineTotal),
            style: context.text.titleSmall,
          ),
        ],
      ),
    );
  }
}
