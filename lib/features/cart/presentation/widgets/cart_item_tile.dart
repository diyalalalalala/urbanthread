import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_notice.dart';
import 'quantity_stepper.dart';

/// One line in the cart, in either of its two forms.
///
/// The saved-for-later variant shows the same product but swaps the stepper
/// for a "move to bag" action, because a parked item has no quantity that
/// counts — it is excluded from every total until it comes back.
class CartItemTile extends StatelessWidget {
  const CartItemTile({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
    required this.onSaveForLater,
    required this.onMoveToCart,
    super.key,
    this.notice,
    this.isBusy = false,
    this.onTapProduct,
  });

  final CartItem item;

  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;
  final VoidCallback onSaveForLater;
  final VoidCallback onMoveToCart;

  /// The server's explanation for a change it made to this line on the last
  /// read. Shown inline, next to the thing it is about.
  final CartNotice? notice;

  final bool isBusy;
  final VoidCallback? onTapProduct;

  @override
  Widget build(BuildContext context) {
    final saved = item.savedForLater;

    return Opacity(
      // A line with a request in flight dims rather than disappearing, so the
      // list does not reflow under the customer's thumb mid-tap.
      opacity: isBusy ? 0.6 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onTapProduct,
                  child: AppNetworkImage(
                    url: item.imageUrl,
                    width: 88,
                    height: 88 / AppDimens.productAspectRatio,
                    borderRadius: AppDimens.borderRadius,
                  ),
                ),
                const SizedBox(width: AppDimens.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(item: item, onTapProduct: onTapProduct),
                      const SizedBox(height: AppDimens.space4),
                      _VariantLine(item: item),
                      const SizedBox(height: AppDimens.space8),
                      _PriceLine(item: item),
                      const SizedBox(height: AppDimens.space12),
                      if (saved)
                        _SavedActions(
                          onMoveToCart: isBusy ? null : onMoveToCart,
                          onRemove: isBusy ? null : onRemove,
                        )
                      else
                        _ActiveActions(
                          item: item,
                          isBusy: isBusy,
                          onQuantityChanged: onQuantityChanged,
                          onSaveForLater: isBusy ? null : onSaveForLater,
                          onRemove: isBusy ? null : onRemove,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (notice != null) ...[
              const SizedBox(height: AppDimens.space12),
              _NoticeStrip(notice: notice!),
            ],
            if (!item.product.isActive) ...[
              const SizedBox(height: AppDimens.space12),
              _NoticeStrip(
                notice: const CartNotice(
                  type: CartNoticeType.removed,
                  message:
                      'This product is no longer available and will be removed '
                      'at checkout.',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.item, this.onTapProduct});

  final CartItem item;
  final VoidCallback? onTapProduct;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTapProduct,
        child: Text(
          item.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.text.titleSmall,
        ),
      );
}

class _VariantLine extends StatelessWidget {
  const _VariantLine({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    // Colour and size live under `snapshot`, not on the item — this is the
    // only place they exist on a cart payload.
    final parts = [
      if (item.color.isNotEmpty) item.color,
      if (item.size.isNotEmpty) 'Size ${item.size}',
    ];
    if (parts.isEmpty) return const SizedBox.shrink();

    return Text(
      parts.join('  ·  '),
      style: context.text.bodySmall?.copyWith(color: context.palette.inkMuted),
    );
  }
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Wrap(
      spacing: AppDimens.space8,
      runSpacing: AppDimens.space4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          // There is no per-item subtotal on the API — it is unit price times
          // quantity, computed here.
          Formatters.price(item.lineTotal),
          style: AppTypography.price.copyWith(color: palette.ink, fontSize: 15),
        ),
        if (item.quantity > 1)
          Text(
            '${Formatters.price(item.unitPrice)} each',
            style: context.text.bodySmall?.copyWith(color: palette.inkMuted),
          ),
        if (item.priceChanged)
          _Chip(
            // The snapshot is what the cart is priced at until the server
            // reconciles it, so this is a heads-up rather than a correction.
            label: item.product.effectivePrice < item.unitPrice
                ? 'PRICE DROPPED'
                : 'PRICE CHANGED',
            color: item.product.effectivePrice < item.unitPrice
                ? palette.success
                : palette.warning,
            background: item.product.effectivePrice < item.unitPrice
                ? palette.successSubtle
                : palette.warningSubtle,
          ),
      ],
    );
  }
}

class _ActiveActions extends StatelessWidget {
  const _ActiveActions({
    required this.item,
    required this.isBusy,
    required this.onQuantityChanged,
    required this.onSaveForLater,
    required this.onRemove,
  });

  final CartItem item;
  final bool isBusy;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback? onSaveForLater;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: AppDimens.space12,
        runSpacing: AppDimens.space8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          QuantityStepper(
            quantity: item.quantity,
            isBusy: isBusy,
            // Falls back to the API's own cap when stock is unknown, rather
            // than disabling the control over missing data.
            maximum: item.maxSelectableQuantity ?? CartItem.maxQuantityPerLine,
            // Zero is not a valid quantity for the API; the page turns a
            // decrement at 1 into a removal instead.
            onChanged: onQuantityChanged,
          ),
          _TextAction(
            label: 'Save for later',
            icon: Icons.bookmark_border,
            onPressed: onSaveForLater,
          ),
          _TextAction(
            label: 'Remove',
            icon: Icons.close,
            onPressed: onRemove,
            isDestructive: true,
          ),
        ],
      );
}

class _SavedActions extends StatelessWidget {
  const _SavedActions({required this.onMoveToCart, required this.onRemove});

  final VoidCallback? onMoveToCart;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: AppDimens.space12,
        runSpacing: AppDimens.space8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _TextAction(
            label: 'Move to bag',
            icon: Icons.shopping_bag_outlined,
            onPressed: onMoveToCart,
          ),
          _TextAction(
            label: 'Remove',
            icon: Icons.close,
            onPressed: onRemove,
            isDestructive: true,
          ),
        ],
      );
}

class _TextAction extends StatelessWidget {
  const _TextAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = onPressed == null
        ? palette.inkSubtle
        : (isDestructive ? palette.danger : palette.inkMuted);

    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.space8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: AppDimens.space4),
            Text(
              label.toUpperCase(),
              style: AppTypography.eyebrow.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders one reconciliation notice.
///
/// These are worth real estate: they are the customer's only explanation for a
/// cart that changed between sessions, and the server regenerates them on
/// every read, so nothing else will ever tell them.
class _NoticeStrip extends StatelessWidget {
  const _NoticeStrip({required this.notice});

  final CartNotice notice;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final severe = notice.isSevere;
    final foreground = severe ? palette.danger : palette.warning;
    final background = severe ? palette.dangerSubtle : palette.warningSubtle;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space12,
        vertical: AppDimens.space8,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppDimens.borderRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            severe ? Icons.error_outline : Icons.info_outline,
            size: 14,
            color: foreground,
          ),
          const SizedBox(width: AppDimens.space8),
          Expanded(
            child: Text(
              notice.message,
              style: context.text.bodySmall?.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space8,
          vertical: AppDimens.space2,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppDimens.borderRadiusSm,
        ),
        child: Text(label, style: AppTypography.eyebrow.copyWith(color: color)),
      );
}
