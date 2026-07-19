import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/home_product.dart';

/// The compact product card used by the storefront rails.
///
/// Home-local on purpose. The catalogue grid's card and this one look similar
/// but answer different questions — a grid card can afford a wishlist button,
/// a size run and a two-line description, while a rail card has 150dp and one
/// job: be recognisable enough to tap. Sharing one widget between them means
/// a prop for every difference and a card that is slightly wrong in both
/// places.
class HomeProductCard extends StatelessWidget {
  const HomeProductCard({
    required this.product,
    required this.onTap,
    super.key,
    this.width = 156,
  });

  final HomeProduct product;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final discount = Formatters.discountBadge(product.discountPercentage);

    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                AspectRatio(
                  // Catalogue photography is shot 3:4 throughout, so the frame
                  // is fixed rather than sized to whatever arrives — a rail of
                  // cards at different heights is the fastest way to make a
                  // storefront look broken.
                  aspectRatio: AppDimens.productAspectRatio,
                  child: AppNetworkImage(
                    url: product.imageUrl,
                    width: width,
                    borderRadius: AppDimens.borderRadius,
                  ),
                ),
                if (discount != null)
                  Positioned(
                    top: AppDimens.space8,
                    left: AppDimens.space8,
                    child: _Badge(
                      label: discount.toUpperCase(),
                      background: palette.accent,
                      foreground: palette.accentInk,
                    ),
                  )
                else if (product.isNewArrival)
                  Positioned(
                    top: AppDimens.space8,
                    left: AppDimens.space8,
                    child: _Badge(
                      label: 'NEW',
                      background: palette.ink,
                      foreground: palette.canvas,
                    ),
                  ),
                // Stock is recomputed from `totalStock` because the `inStock`
                // virtual is absent on these lean collection responses.
                if (!product.inStock)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: palette.canvas.withValues(alpha: 0.66),
                        borderRadius: AppDimens.borderRadius,
                      ),
                      child: Center(
                        child: Text(
                          'SOLD OUT',
                          style: AppTypography.eyebrow.copyWith(
                            color: palette.ink,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppDimens.space12),
            if (product.brandName != null && product.brandName!.isNotEmpty) ...[
              Text(
                product.brandName!.toUpperCase(),
                style: AppTypography.eyebrow.copyWith(color: palette.inkSubtle),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimens.space4),
            ],
            Text(
              product.name,
              style: context.text.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppDimens.space8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    Formatters.price(product.effectivePrice),
                    style: context.text.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (product.hasDiscount) ...[
                  const SizedBox(width: AppDimens.space8),
                  Flexible(
                    child: Text(
                      Formatters.price(product.price),
                      style: context.text.bodySmall?.copyWith(
                        color: palette.inkSubtle,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: palette.inkSubtle,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            if (product.hasRating) ...[
              const SizedBox(height: AppDimens.space4),
              Row(
                children: [
                  Icon(Icons.star_rounded, size: 14, color: palette.warning),
                  const SizedBox(width: AppDimens.space4),
                  Text(
                    product.ratingAverage.toStringAsFixed(1),
                    style: context.text.bodySmall,
                  ),
                  const SizedBox(width: AppDimens.space4),
                  Text(
                    '(${Formatters.compact(product.ratingCount)})',
                    style: context.text.bodySmall?.copyWith(
                      color: palette.inkSubtle,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
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
          label,
          style: AppTypography.eyebrow.copyWith(color: foreground),
        ),
      );
}
