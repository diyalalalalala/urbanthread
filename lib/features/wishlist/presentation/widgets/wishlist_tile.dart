import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/wishlist.dart';

/// One saved product, as a grid card.
///
/// Carries two affordances beyond a plain product card: a remove control, and
/// the price-drop line that `priceWhenAdded` exists to make possible — the
/// reason a customer saves something rather than buying it is usually that
/// they are waiting for exactly that.
class WishlistTile extends StatelessWidget {
  const WishlistTile({
    required this.item,
    required this.onMoveToCart,
    required this.onRemove,
    super.key,
    this.onTap,
    this.isBusy = false,
  });

  final WishlistItem item;
  final VoidCallback onMoveToCart;
  final VoidCallback onRemove;
  final VoidCallback? onTap;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final product = item.product;
    final canBuy = product.inStock && product.isActive;

    return Opacity(
      opacity: isBusy ? 0.6 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: onTap,
                child: AspectRatio(
                  aspectRatio: AppDimens.productAspectRatio,
                  child: AppNetworkImage(
                    url: product.imageUrl,
                    borderRadius: AppDimens.borderRadius,
                  ),
                ),
              ),
              Positioned(
                top: AppDimens.space4,
                right: AppDimens.space4,
                child: _RemoveButton(onPressed: isBusy ? null : onRemove),
              ),
              if (!canBuy)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: palette.canvas.withValues(alpha: 0.7),
                      borderRadius: AppDimens.borderRadius,
                    ),
                    child: Center(
                      child: Text(
                        product.isActive ? 'OUT OF STOCK' : 'UNAVAILABLE',
                        style: AppTypography.eyebrow.copyWith(
                          color: palette.ink,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.space8),
          if (product.brand != null)
            Text(
              product.brand!.name.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.eyebrow.copyWith(color: palette.inkSubtle),
            ),
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodyMedium,
          ),
          const SizedBox(height: AppDimens.space4),
          _Price(product: product),
          if (item.priceDropped) ...[
            const SizedBox(height: AppDimens.space4),
            Text(
              'Down ${Formatters.price(item.priceDropAmount)} since you saved it',
              style: context.text.bodySmall?.copyWith(color: palette.success),
            ),
          ],
          const SizedBox(height: AppDimens.space12),
          SizedBox(
            width: double.infinity,
            height: AppDimens.controlHeightSm,
            child: OutlinedButton(
              onPressed: canBuy && !isBusy ? onMoveToCart : null,
              child: Text(canBuy ? 'MOVE TO BAG' : 'UNAVAILABLE'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Price extends StatelessWidget {
  const _Price({required this.product});

  final WishlistProduct product;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final badge = Formatters.discountBadge(product.discountPercentage);

    return Wrap(
      spacing: AppDimens.space8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          Formatters.price(product.effectivePrice),
          style: AppTypography.price.copyWith(color: palette.ink, fontSize: 14),
        ),
        // `price` is the pre-discount figure; there is no `comparePrice` on
        // this API, so the strike-through is the original price itself.
        if (product.discountPercentage > 0)
          Text(
            Formatters.price(product.price),
            style: context.text.bodySmall?.copyWith(
              color: palette.inkSubtle,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        if (badge != null)
          Text(
            badge.toUpperCase(),
            style: AppTypography.eyebrow.copyWith(color: palette.danger),
          ),
      ],
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: palette.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.space8),
          child: Icon(
            Icons.close,
            size: 16,
            color: onPressed == null ? palette.inkSubtle : palette.ink,
          ),
        ),
      ),
    );
  }
}
