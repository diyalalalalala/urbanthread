import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/product.dart';
import 'price_label.dart';
import 'rating_stars.dart';

/// The catalogue tile, used by the product grid, search results, wishlist,
/// recently-viewed, the home collections and the recommendation carousels.
///
/// Self-contained by design, because it is the one widget almost every other
/// feature reuses: it needs nothing but a [Product], and it navigates to the
/// product page itself unless [onTap] overrides that. Callers therefore never
/// have to know that detail routing is by **slug** — a distinction that is
/// easy to get wrong given `/related` and `/frequently-bought-together` are
/// keyed by id.
///
/// The wishlist affordance is opt-in ([showWishlistButton]) so that this
/// feature does not acquire a dependency on the wishlist feature; the owner
/// passes the state and the callback in.
class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    super.key,
    this.onTap,
    this.showWishlistButton = false,
    this.isWishlisted = false,
    this.onWishlistTap,
    this.width,
    this.dense = false,
  });

  final Product product;

  /// Defaults to pushing `/products/{slug}`.
  final VoidCallback? onTap;

  final bool showWishlistButton;
  final bool isWishlisted;
  final VoidCallback? onWishlistTap;

  /// Fixed width, for a horizontally scrolling carousel. Null means "fill the
  /// grid cell".
  final double? width;

  /// Trims the metadata to name and price — for tight rows such as the
  /// frequently-bought-together strip.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final card = Material(
      color: palette.surface,
      borderRadius: AppDimens.borderRadius,
      child: InkWell(
        onTap: onTap ?? () => context.push(AppRoutes.productDetailPath(product.slug)),
        borderRadius: AppDimens.borderRadius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _Media(
              product: product,
              showWishlistButton: showWishlistButton,
              isWishlisted: isWishlisted,
              onWishlistTap: onWishlistTap,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.space4,
                AppDimens.space12,
                AppDimens.space4,
                AppDimens.space4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Brand is polymorphic on some endpoints — a bare id with no
                  // name — so the eyebrow is skipped rather than printed blank.
                  if (!dense && (product.brand?.isResolved ?? false)) ...[
                    Text(
                      product.brand!.name.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.eyebrow.copyWith(
                        color: palette.inkSubtle,
                      ),
                    ),
                    const SizedBox(height: AppDimens.space8),
                  ],
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleSmall,
                  ),
                  if (!dense && product.rating.hasReviews) ...[
                    const SizedBox(height: AppDimens.space4),
                    RatingStars(
                      rating: product.rating.average,
                      count: product.rating.count,
                      size: 12,
                    ),
                  ],
                  const SizedBox(height: AppDimens.space8),
                  PriceLabel.forProduct(
                    product,
                    size: dense ? PriceLabelSize.small : PriceLabelSize.medium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return width == null ? card : SizedBox(width: width, child: card);
  }
}

/// Image, badges and the out-of-stock veil.
class _Media extends StatelessWidget {
  const _Media({
    required this.product,
    required this.showWishlistButton,
    required this.isWishlisted,
    this.onWishlistTap,
  });

  final Product product;
  final bool showWishlistButton;
  final bool isWishlisted;
  final VoidCallback? onWishlistTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final discount = Formatters.discountBadge(product.discountPercentage);

    return AspectRatio(
      aspectRatio: AppDimens.productAspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppNetworkImage(
            url: product.displayImageUrl,
            borderRadius: AppDimens.borderRadius,
          ),

          // Out of stock is a full veil rather than a corner badge: it changes
          // whether the tile is worth tapping at all, so it should read before
          // the price does.
          if (product.isOutOfStock)
            DecoratedBox(
              decoration: BoxDecoration(
                color: palette.canvas.withValues(alpha: 0.66),
                borderRadius: AppDimens.borderRadius,
              ),
              child: Center(
                child: _Badge(
                  label: 'Sold out',
                  background: palette.ink,
                  foreground: palette.canvas,
                ),
              ),
            ),

          Positioned(
            top: AppDimens.space8,
            left: AppDimens.space8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (discount != null)
                  _Badge(
                    label: discount,
                    background: palette.accent,
                    foreground: palette.accentInk,
                  ),
                if (product.isNewArrival) ...[
                  const SizedBox(height: AppDimens.space4),
                  _Badge(
                    label: 'New',
                    background: palette.surface,
                    foreground: palette.ink,
                  ),
                ],
                if (product.inStock && product.isLowStock) ...[
                  const SizedBox(height: AppDimens.space4),
                  _Badge(
                    label: 'Low stock',
                    background: palette.warningSubtle,
                    foreground: palette.warning,
                  ),
                ],
              ],
            ),
          ),

          if (showWishlistButton)
            Positioned(
              top: AppDimens.space4,
              right: AppDimens.space4,
              child: Material(
                color: palette.surface.withValues(alpha: 0.9),
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: onWishlistTap,
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                  tooltip:
                      isWishlisted ? 'Remove from wishlist' : 'Add to wishlist',
                  icon: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted ? palette.accent : palette.ink,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space8,
          vertical: AppDimens.space4,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppDimens.borderRadiusSm,
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTypography.eyebrow.copyWith(color: foreground),
        ),
      );
}
