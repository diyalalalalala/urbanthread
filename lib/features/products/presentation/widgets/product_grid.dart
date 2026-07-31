import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/text_metrics.dart';
import '../../domain/entities/product.dart';
import 'product_card.dart';

class ProductGridGeometry {
  const ProductGridGeometry._();

  static const spacing = AppDimens.space16;

  static double captionHeight(BuildContext context, {bool dense = false}) {
    final text = context.text;
    final priceStyle = AppTypography.price.copyWith(
      fontSize: dense ? 15 : 18,
    );

    var height = AppDimens.space12 +
        AppDimens.space4 +
        textBlockHeight(context, text.titleSmall, lines: _nameLines) +
        AppDimens.space8 +
        textBlockHeight(context, priceStyle);

    if (!dense) {
      height += textBlockHeight(context, AppTypography.eyebrow) +
          AppDimens.space8 +
          AppDimens.space4 +
          math.max(
            _ratingIconSize,
            textBlockHeight(context, text.labelMedium),
          );
    }

    return height.ceilToDouble();
  }

  static const _nameLines = 2;
  static const _ratingIconSize = 12.0;

  static SliverGridDelegate delegate(BuildContext context) {
    final columns = context.productGridColumns;
    final available = context.screenWidth -
        (AppDimens.pageGutter * 2) -
        (spacing * (columns - 1));
    final cellWidth = available / columns;
    final cellHeight =
        (cellWidth / AppDimens.productAspectRatio) + captionHeight(context);

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: cellWidth / cellHeight,
    );
  }
}

class SliverProductGrid extends StatelessWidget {
  const SliverProductGrid({
    required this.products,
    super.key,
    this.showWishlistButton = false,
    this.isWishlisted,
    this.onWishlistTap,
    this.onProductTap,
  });

  final List<Product> products;
  final bool showWishlistButton;

  final bool Function(Product product)? isWishlisted;

  final void Function(Product product)? onWishlistTap;
  final void Function(Product product)? onProductTap;

  @override
  Widget build(BuildContext context) => SliverGrid.builder(
        gridDelegate: ProductGridGeometry.delegate(context),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            showWishlistButton: showWishlistButton,
            isWishlisted: isWishlisted?.call(product) ?? false,
            onWishlistTap: onWishlistTap == null
                ? null
                : () => onWishlistTap!(product),
            onTap:
                onProductTap == null ? null : () => onProductTap!(product),
          );
        },
      );
}

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    required this.products,
    super.key,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppDimens.pageGutter,
    ),
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
    this.showWishlistButton = false,
    this.isWishlisted,
    this.onWishlistTap,
    this.onProductTap,
  });

  final List<Product> products;
  final EdgeInsetsGeometry padding;

  final bool shrinkWrap;
  final ScrollPhysics? physics;

  final bool showWishlistButton;
  final bool Function(Product product)? isWishlisted;
  final void Function(Product product)? onWishlistTap;
  final void Function(Product product)? onProductTap;

  @override
  Widget build(BuildContext context) => GridView.builder(
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics,
        gridDelegate: ProductGridGeometry.delegate(context),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            showWishlistButton: showWishlistButton,
            isWishlisted: isWishlisted?.call(product) ?? false,
            onWishlistTap:
                onWishlistTap == null ? null : () => onWishlistTap!(product),
            onTap: onProductTap == null ? null : () => onProductTap!(product),
          );
        },
      );
}

class ProductCarousel extends StatelessWidget {
  const ProductCarousel({
    required this.products,
    super.key,
    this.title,
    this.onSeeAll,
    this.itemWidth = 168,
    this.dense = false,
  });

  final List<Product> products;
  final String? title;
  final VoidCallback? onSeeAll;
  final double itemWidth;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    final height = (itemWidth / AppDimens.productAspectRatio) +
        ProductGridGeometry.captionHeight(context, dense: dense);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.pageGutter,
              0,
              AppDimens.pageGutter,
              AppDimens.space12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(title!, style: context.text.headlineSmall),
                ),
                if (onSeeAll != null)
                  TextButton(
                    onPressed: onSeeAll,
                    child: const Text('SEE ALL'),
                  ),
              ],
            ),
          ),
        SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.pageGutter,
            ),
            itemCount: products.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: AppDimens.space12),
            itemBuilder: (context, index) => ProductCard(
              product: products[index],
              width: itemWidth,
              dense: dense,
            ),
          ),
        ),
      ],
    );
  }
}
