import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/product.dart';

enum PriceLabelSize { small, medium, large }

/// Price, struck-through original and discount badge as one unit.
///
/// Kept together deliberately: the three parts have to agree, and the field
/// names invite a mistake — `price` on the API is the *pre*-discount amount
/// and `effectivePrice` is what the customer pays, so a widget that took a
/// single "price" would show the wrong number half the time. This one takes
/// the paid price and the compare-at price separately, and
/// [PriceLabel.forProduct] wires an entity up correctly.
class PriceLabel extends StatelessWidget {
  const PriceLabel({
    required this.price,
    super.key,
    this.compareAtPrice,
    this.discountPercentage = 0,
    this.size = PriceLabelSize.medium,
    this.alignment = MainAxisAlignment.start,
    this.singleLine = false,
  });

  /// Reads the paid price, the strike-through and the badge off an entity.
  PriceLabel.forProduct(
    Product product, {
    Key? key,
    PriceLabelSize size = PriceLabelSize.medium,
    MainAxisAlignment alignment = MainAxisAlignment.start,
    bool singleLine = false,
  }) : this(
          key: key,
          price: product.sellingPrice,
          compareAtPrice: product.compareAtPrice,
          discountPercentage: product.discountPercentage,
          size: size,
          alignment: alignment,
          singleLine: singleLine,
        );

  /// What the customer pays.
  final double price;

  /// The pre-discount price, or null when nothing is on offer.
  final double? compareAtPrice;

  final double discountPercentage;
  final PriceLabelSize size;
  final MainAxisAlignment alignment;

  /// Keeps the label to one line, for a caller whose height is fixed.
  ///
  /// The default [Wrap] grows a run whenever the three parts do not fit side
  /// by side, which on a narrow tile is most of the time — and a caption that
  /// silently gets taller is what overflows a grid cell. In single-line mode
  /// the strike-through ellipsises instead and the badge is dropped, which
  /// costs a card nothing: the tiles that use this already paint the discount
  /// over the photograph.
  final bool singleLine;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final badge = Formatters.discountBadge(discountPercentage);
    final showsCompare = compareAtPrice != null && compareAtPrice! > price;

    final priceStyle = AppTypography.price.copyWith(
      color: palette.ink,
      fontSize: switch (size) {
        PriceLabelSize.small => 15,
        PriceLabelSize.medium => 18,
        PriceLabelSize.large => 26,
      },
    );

    final compareStyle = context.text.bodySmall?.copyWith(
      color: palette.inkSubtle,
      decoration: TextDecoration.lineThrough,
      decorationColor: palette.inkSubtle,
    );

    if (singleLine) {
      return Row(
        mainAxisAlignment: alignment,
        children: [
          Flexible(
            child: Text(
              Formatters.price(price),
              style: priceStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showsCompare) ...[
            const SizedBox(width: AppDimens.space8),
            Flexible(
              child: Text(
                Formatters.price(compareAtPrice),
                style: compareStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      );
    }

    return Wrap(
      spacing: AppDimens.space8,
      runSpacing: AppDimens.space4,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: switch (alignment) {
        MainAxisAlignment.center => WrapAlignment.center,
        MainAxisAlignment.end => WrapAlignment.end,
        _ => WrapAlignment.start,
      },
      children: [
        Text(Formatters.price(price), style: priceStyle),
        if (showsCompare)
          Text(Formatters.price(compareAtPrice), style: compareStyle),
        if (badge != null && size != PriceLabelSize.small)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.space8,
              vertical: AppDimens.space4,
            ),
            decoration: BoxDecoration(
              color: palette.accentSubtle,
              borderRadius: AppDimens.borderRadiusSm,
            ),
            child: Text(
              badge.toUpperCase(),
              style: AppTypography.eyebrow.copyWith(color: palette.accent),
            ),
          ),
      ],
    );
  }
}
