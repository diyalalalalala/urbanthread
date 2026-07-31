import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/product.dart';

enum PriceLabelSize { small, medium, large }

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

  final double price;

  final double? compareAtPrice;

  final double discountPercentage;
  final PriceLabelSize size;
  final MainAxisAlignment alignment;

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
