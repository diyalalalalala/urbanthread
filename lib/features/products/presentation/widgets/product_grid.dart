import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/text_metrics.dart';
import '../../domain/entities/product.dart';
import 'product_card.dart';

/// Grid geometry shared by every catalogue surface.
///
/// Column count comes from `context.productGridColumns` (2 / 3 / 4 by width)
/// and the cell ratio is derived from the 3:4 product image plus a fixed
/// allowance for the text block underneath — a hardcoded `childAspectRatio`
/// would clip the price on a large text scale.
class ProductGridGeometry {
  const ProductGridGeometry._();

  static const spacing = AppDimens.space16;

  /// Vertical space the caption needs under the image.
  ///
  /// Measured from the styles the card actually uses, at the tallest the
  /// caption can get: brand eyebrow, a name that takes both of its lines, the
  /// rating row and the price. Every cell in a grid is one ratio, so it has
  /// to be the tallest one that fits — and a card with no brand or no reviews
  /// simply leaves slack, which is what keeps the prices on a row aligned.
  ///
  /// This used to be a hardcoded 108, which was a couple of pixels short of
  /// two lines of name and clipped the price outright at a large text scale.
  static double captionHeight(BuildContext context, {bool dense = false}) {
    final text = context.text;
    final priceStyle = AppTypography.price.copyWith(
      fontSize: dense ? 15 : 18,
    );

    // The caption's own padding, then name and price — the two parts every
    // card has.
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

  /// Kept in step with the card: the name's `maxLines` and the size passed to
  /// its [RatingStars].
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

/// A sliver of product tiles, for pages that own a [CustomScrollView] — the
/// product list and search results both need to interleave a toolbar and a
/// loading footer with the grid, which a boxed [GridView] cannot do.
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

  /// Queried per product so the caller can back it with its own state
  /// without this widget depending on the wishlist feature.
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

/// The boxed equivalent, for embedding a fixed set of products inside another
/// scroll view (a category landing page, a "you may also like" block).
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

  /// Defaults suit the common case — a non-scrolling grid nested in a page
  /// that scrolls. Override both together when it is the primary scroller.
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

/// A horizontally scrolling strip, for the home collections and the
/// detail page's related / frequently-bought-together sections.
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

    // The strip's height has to be fixed for a horizontal list, so it is
    // derived from the tile width the same way the grid derives its cells.
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
