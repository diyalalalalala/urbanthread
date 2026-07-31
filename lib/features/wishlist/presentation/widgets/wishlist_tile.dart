import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/text_metrics.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/wishlist.dart';

abstract final class WishlistTileGeometry {
  const WishlistTileGeometry._();

  static const crossAxisSpacing = AppDimens.space16;
  static const mainAxisSpacing = AppDimens.space24;

  static const _nameLines = 2;
  static const _priceDropLines = 2;

  static double captionHeight(BuildContext context) {
    final text = context.text;

    final height = AppDimens.space8 +
        textBlockHeight(context, AppTypography.eyebrow) +
        textBlockHeight(context, text.bodyMedium, lines: _nameLines) +
        AppDimens.space4 +
        textBlockHeight(context, AppTypography.price.copyWith(fontSize: 14)) +
        AppDimens.space4 +
        textBlockHeight(context, text.bodySmall, lines: _priceDropLines) +
        AppDimens.space12 +
        AppDimens.controlHeightSm;

    return height.ceilToDouble();
  }

  static SliverGridDelegate delegate(BuildContext context) {
    final columns = context.productGridColumns;
    final available = context.screenWidth -
        (AppDimens.pageGutter * 2) -
        (crossAxisSpacing * (columns - 1));
    final cellWidth = available / columns;
    final cellHeight =
        (cellWidth / AppDimens.productAspectRatio) + captionHeight(context);

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      childAspectRatio: cellWidth / cellHeight,
    );
  }
}

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
              maxLines: WishlistTileGeometry._priceDropLines,
              overflow: TextOverflow.ellipsis,
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

    return Row(
      children: [
        Flexible(
          child: Text(
            Formatters.price(product.effectivePrice),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.price.copyWith(
              color: palette.ink,
              fontSize: 14,
            ),
          ),
        ),
        if (product.discountPercentage > 0) ...[
          const SizedBox(width: AppDimens.space8),
          Flexible(
            child: Text(
              Formatters.price(product.price),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySmall?.copyWith(
                color: palette.inkSubtle,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
        if (badge != null) ...[
          const SizedBox(width: AppDimens.space8),
          Flexible(
            child: Text(
              badge.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.eyebrow.copyWith(color: palette.danger),
            ),
          ),
        ],
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
