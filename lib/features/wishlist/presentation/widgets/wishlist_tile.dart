import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/text_metrics.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/wishlist.dart';

/// Cell sizing for the wishlist grid.
///
/// The same job [ProductGridGeometry] does for the catalogue, and here for the
/// same reason: a grid cell has to state its height before its contents are
/// laid out, so the caption has to be measured up front. This replaces a
/// hardcoded `childAspectRatio: 0.48`, which was very slightly too short — it
/// fitted a tile without a price-drop line and overflowed by about fifteen
/// pixels with one, and clipped at any raised text scale, since a fixed ratio
/// cannot know what the reader's font size is.
///
/// The budget is the *tallest* the caption gets, price-drop line included.
/// Every cell in a grid is one ratio, so a tile whose price has not moved
/// simply leaves slack — which is what keeps the buttons on a row aligned.
abstract final class WishlistTileGeometry {
  const WishlistTileGeometry._();

  static const crossAxisSpacing = AppDimens.space16;
  static const mainAxisSpacing = AppDimens.space24;

  /// Kept in step with the tile's own `maxLines`.
  static const _nameLines = 2;
  static const _priceDropLines = 2;

  static double captionHeight(BuildContext context) {
    final text = context.text;

    final height = AppDimens.space8 +
        // Brand eyebrow, then the name at both of the lines it may take.
        textBlockHeight(context, AppTypography.eyebrow) +
        textBlockHeight(context, text.bodyMedium, lines: _nameLines) +
        AppDimens.space4 +
        // One line, and reliably so: the price row ellipsises rather than
        // wrapping, which is what makes this budget something other than a
        // guess. The price is the tallest style in that row.
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
              // Capped, and budgeted at the same two lines by
              // [WishlistTileGeometry]: this is a whole sentence in a cell a
              // third of a phone wide, so it always takes more than one line
              // and used to take three when the amount was long.
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

    // One line, always. A `Wrap` here — which is what this was — grows a run
    // whenever the three parts do not fit side by side, and on a cell this
    // narrow that is the common case with a discount; the caption then gets
    // taller than the grid budgeted for it. `PriceLabel.singleLine` exists for
    // the same reason and explains it at length.
    //
    // Every part is flexible and ellipsises rather than dropping the badge the
    // way `PriceLabel` does: nothing else on this tile shows the discount, and
    // a price cut is the whole reason a saved item is worth coming back to.
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
        // `price` is the pre-discount figure; there is no `comparePrice` on
        // this API, so the strike-through is the original price itself.
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
