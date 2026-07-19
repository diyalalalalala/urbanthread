import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/product.dart';
import '../providers/product_detail_notifier.dart';
import '../providers/product_providers.dart';
import '../providers/product_reviews_notifier.dart';
import '../widgets/price_label.dart';
import '../widgets/product_grid.dart';
import '../widgets/rating_stars.dart';
import '../widgets/review_views.dart';
import '../widgets/variant_selector.dart';

/// Signature for handing a chosen variant to the cart.
///
/// The page does not import the cart feature — it reports the selection and
/// lets the owner of the route decide what to do with it. That keeps the
/// catalogue independent of the basket, which is what stops the two features
/// becoming one.
typedef AddToCartCallback = void Function(
  Product product,
  ProductVariant variant,
  int quantity,
);

/// The product page.
///
/// Addressed by **slug**, because the backend registers no `/products/:id`
/// route. Note that the two recommendation strips at the bottom take the
/// product's ObjectId instead — the asymmetry is the API's, and it is why the
/// id is only read after the product itself has loaded.
class ProductDetailPage extends ConsumerWidget {
  const ProductDetailPage({required this.slug, super.key, this.onAddToCart});

  final String slug;

  /// Wired up by whoever owns the route. Null renders the button disabled
  /// with an explanatory snack rather than hiding it, so the page layout does
  /// not change depending on how it was mounted.
  final AddToCartCallback? onAddToCart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productDetailProvider(slug));
    final notifier = ref.read(productDetailProvider(slug).notifier);

    if (state.isLoading) {
      return const Scaffold(body: LoadingView(message: 'Loading product…'));
    }

    final failure = state.failure;
    if (failure != null || state.product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: FailureView(
          failure: failure ?? const NotFoundFailure(),
          onRetry: notifier.retry,
        ),
      );
    }

    final product = state.product!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _GalleryAppBar(product: product),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.pageGutter,
                AppDimens.space24,
                AppDimens.pageGutter,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Heading(product: product),
                  const SizedBox(height: AppDimens.space16),
                  PriceLabel(
                    price: state.displayPrice,
                    compareAtPrice: product.compareAtPrice,
                    discountPercentage: product.discountPercentage,
                    size: PriceLabelSize.large,
                  ),
                  if (product.hasDiscount) ...[
                    const SizedBox(height: AppDimens.space4),
                    Text(
                      'You save ${Formatters.price(product.savings)}',
                      style: context.text.bodySmall?.copyWith(
                        color: context.palette.success,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppDimens.space16),
                  _StockState(product: product, state: state),
                  const SizedBox(height: AppDimens.space24),
                  VariantSelector(
                    product: product,
                    selectedColor: state.selectedColor,
                    selectedSize: state.selectedSize,
                    onColorSelected: notifier.selectColor,
                    onSizeSelected: notifier.selectSize,
                  ),
                  const SizedBox(height: AppDimens.space24),
                  _QuantityStepper(
                    quantity: state.quantity,
                    max: state.maxQuantity,
                    onDecrement: notifier.decrementQuantity,
                    onIncrement: notifier.incrementQuantity,
                  ),
                  const SizedBox(height: AppDimens.space32),
                  _Description(product: product),
                  if (product.specifications.isNotEmpty) ...[
                    const SizedBox(height: AppDimens.space32),
                    _Specifications(product: product),
                  ],
                  if (product.tags.isNotEmpty) ...[
                    const SizedBox(height: AppDimens.space24),
                    _Tags(tags: product.tags),
                  ],
                  const SizedBox(height: AppDimens.space32),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: _ReviewsSection(product: product)),
          SliverToBoxAdapter(
            child: _FrequentlyBoughtTogether(productId: product.id),
          ),
          SliverToBoxAdapter(child: _RelatedProducts(productId: product.id)),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimens.space48),
          ),
        ],
      ),
      bottomNavigationBar: _BuyBar(
        state: state,
        onAddToCart: onAddToCart,
      ),
    );
  }
}

/// Collapsing gallery. Swipeable, with a page indicator.
class _GalleryAppBar extends StatefulWidget {
  const _GalleryAppBar({required this.product});

  final Product product;

  @override
  State<_GalleryAppBar> createState() => _GalleryAppBarState();
}

class _GalleryAppBarState extends State<_GalleryAppBar> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.product.galleryUrls;
    final palette = context.palette;

    return SliverAppBar(
      pinned: true,
      // 3:4 portrait, matching how the catalogue is shot.
      expandedHeight: context.screenWidth / AppDimens.productAspectRatio,
      backgroundColor: palette.canvas,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (urls.isEmpty)
              const AppNetworkImage(url: null)
            else
              PageView.builder(
                controller: _controller,
                itemCount: urls.length,
                onPageChanged: (index) => setState(() => _index = index),
                itemBuilder: (context, index) => AppNetworkImage(
                  url: urls[index],
                  fit: BoxFit.cover,
                ),
              ),
            if (urls.length > 1)
              Positioned(
                bottom: AppDimens.space16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var index = 0; index < urls.length; index++)
                      AnimatedContainer(
                        duration: AppDimens.durationFast,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: index == _index ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: index == _index
                              ? palette.ink
                              : palette.ink.withValues(alpha: 0.3),
                          borderRadius: AppDimens.borderRadiusXl,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Populated on detail, but the entity tolerates a bare id elsewhere —
        // so the label is guarded rather than assumed.
        if (product.brand?.isResolved ?? false)
          Text(
            product.brand!.name.toUpperCase(),
            style: AppTypography.eyebrow.copyWith(color: palette.inkSubtle),
          ),
        const SizedBox(height: AppDimens.space8),
        Text(product.name, style: context.text.headlineLarge),
        if (product.shortDescription.isNotEmpty) ...[
          const SizedBox(height: AppDimens.space8),
          Text(product.shortDescription, style: context.text.bodyMedium),
        ],
        if (product.rating.hasReviews) ...[
          const SizedBox(height: AppDimens.space12),
          RatingStars(
            rating: product.rating.average,
            count: product.rating.count,
            size: 15,
            showValue: true,
          ),
        ],
      ],
    );
  }
}

class _StockState extends StatelessWidget {
  const _StockState({required this.product, required this.state});

  final Product product;
  final ProductDetailState state;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final variant = state.selectedVariant;

    // Variant-level stock is the honest number once a pair is chosen: the
    // product may have plenty in total while this exact colour and size has
    // two left.
    final (label, color) = switch (variant) {
      null when product.isOutOfStock => ('Sold out', palette.danger),
      null => ('In stock', palette.success),
      final v when v.stock == 0 => ('This combination is sold out', palette.danger),
      final v when v.stock <= Product.lowStockThreshold =>
        ('Only ${v.stock} left', palette.warning),
      _ => ('In stock', palette.success),
    };

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppDimens.space8),
        Text(
          label,
          style: context.text.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.max,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final int max;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      children: [
        Text(
          'QUANTITY',
          style: AppTypography.eyebrow.copyWith(color: palette.inkSubtle),
        ),
        const Spacer(),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: palette.line),
            borderRadius: AppDimens.borderRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: quantity > 1 ? onDecrement : null,
                icon: const Icon(Icons.remove, size: 18),
                visualDensity: VisualDensity.compact,
              ),
              SizedBox(
                width: 32,
                child: Text(
                  '$quantity',
                  textAlign: TextAlign.center,
                  style: context.text.titleMedium,
                ),
              ),
              IconButton(
                // Capped at the variant's stock: the server re-checks it at
                // checkout, and a 422 there is a much worse place to find out.
                onPressed: quantity < max ? onIncrement : null,
                icon: const Icon(Icons.add, size: 18),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Description extends StatefulWidget {
  const _Description({required this.product});

  final Product product;

  @override
  State<_Description> createState() => _DescriptionState();
}

class _DescriptionState extends State<_Description> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final description = widget.product.description;
    if (description.isEmpty) return const SizedBox.shrink();

    // Descriptions run to 5000 characters; collapsing keeps the variant
    // selector and the reviews within reach.
    final isLong = description.length > 240;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Details', style: context.text.headlineSmall),
        const SizedBox(height: AppDimens.space12),
        Text(
          description,
          style: context.text.bodyMedium,
          maxLines: isLong && !_isExpanded ? 5 : null,
          overflow: isLong && !_isExpanded ? TextOverflow.ellipsis : null,
        ),
        if (isLong)
          TextButton(
            onPressed: () => setState(() => _isExpanded = !_isExpanded),
            child: Text(_isExpanded ? 'SHOW LESS' : 'READ MORE'),
          ),
      ],
    );
  }
}

class _Specifications extends StatelessWidget {
  const _Specifications({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Specifications', style: context.text.headlineSmall),
        const SizedBox(height: AppDimens.space12),
        for (final entry in product.specifications.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.space8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    entry.key,
                    style: context.text.bodySmall?.copyWith(
                      color: palette.inkSubtle,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(entry.value, style: context.text.bodyMedium),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Tags extends StatelessWidget {
  const _Tags({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: AppDimens.space8,
        runSpacing: AppDimens.space8,
        children: [
          for (final tag in tags)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space12,
                vertical: AppDimens.space4,
              ),
              decoration: BoxDecoration(
                color: context.palette.surfaceSunken,
                borderRadius: AppDimens.borderRadiusSm,
              ),
              child: Text(tag, style: context.text.bodySmall),
            ),
        ],
      );
}

/// Rating summary plus the paged review list.
class _ReviewsSection extends ConsumerWidget {
  const _ReviewsSection({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(productReviewStatsProvider(product.id));
    final reviews = ref.watch(productReviewsProvider(product.id));
    final notifier = ref.read(productReviewsProvider(product.id).notifier);

    return Container(
      width: double.infinity,
      color: context.palette.surfaceRaised,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.pageGutter,
        vertical: AppDimens.space32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Reviews', style: context.text.headlineSmall),
              ),
              if (reviews.items.isNotEmpty)
                TextButton.icon(
                  onPressed: () async {
                    final sort = await showReviewSortSheet(
                      context,
                      current: reviews.query.sort,
                    );
                    if (sort != null) await notifier.setSort(sort);
                  },
                  icon: const Icon(Icons.swap_vert, size: 18),
                  label: Text(reviews.query.sort.label.toUpperCase()),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.space16),

          // Reviews are the one part of this page that is not cached, so an
          // offline visit shows a quiet note instead of an error card.
          stats.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppDimens.space24),
              child: LoadingView(),
            ),
            error: (error, _) => Text(
              error is Failure
                  ? error.message
                  : 'Ratings could not be loaded right now.',
              style: context.text.bodySmall,
            ),
            data: (value) => value.hasReviews
                ? RatingSummary(
                    stats: value,
                    selectedRating: reviews.query.rating,
                    onRatingSelected: notifier.filterByRating,
                  )
                : Text(
                    'No reviews yet. Be the first to write one.',
                    style: context.text.bodySmall,
                  ),
          ),

          if (reviews.query.hasActiveFilters) ...[
            const SizedBox(height: AppDimens.space16),
            Row(
              children: [
                Text(
                  reviews.query.rating == null
                      ? 'Verified purchases only'
                      : '${reviews.query.rating}-star reviews',
                  style: context.text.bodySmall,
                ),
                const Spacer(),
                TextButton(
                  onPressed: notifier.clearFilters,
                  child: const Text('CLEAR'),
                ),
              ],
            ),
          ],

          const SizedBox(height: AppDimens.space8),
          _ReviewList(state: reviews, onLoadMore: notifier.loadMore),
        ],
      ),
    );
  }
}

class _ReviewList extends StatelessWidget {
  const _ReviewList({required this.state, required this.onLoadMore});

  final ProductReviewsState state;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimens.space24),
        child: LoadingView(),
      );
    }

    final failure = state.failure;
    if (failure != null && state.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.space16),
        child: Text(failure.message, style: context.text.bodySmall),
      );
    }

    if (state.items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final review in state.items) ...[
          ReviewTile(review: review),
          Divider(height: 1, color: context.palette.line),
        ],
        if (state.hasNextPage)
          Padding(
            padding: const EdgeInsets.only(top: AppDimens.space16),
            child: state.isLoadingMore
                ? const LoadingView()
                : OutlinedButton(
                    onPressed: onLoadMore,
                    child: const Text('MORE REVIEWS'),
                  ),
          ),
      ],
    );
  }
}

/// Market-basket companions. Rendered as a dense strip because it is
/// supporting evidence, not a primary browse surface.
class _FrequentlyBoughtTogether extends ConsumerWidget {
  const _FrequentlyBoughtTogether({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(frequentlyBoughtTogetherProvider(productId));

    return entries.maybeWhen(
      data: (value) => value.isEmpty
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(top: AppDimens.space32),
              child: ProductCarousel(
                title: 'Often bought together',
                // Category and brand arrive as bare ObjectIds on this route,
                // so the dense card — which skips the brand eyebrow — is the
                // right one here rather than a stylistic choice.
                dense: true,
                products: value
                    .map((entry) => entry.product)
                    .toList(growable: false),
              ),
            ),
      // A recommendation strip is never worth an error card: if it cannot
      // load, the page simply does not show it.
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _RelatedProducts extends ConsumerWidget {
  const _RelatedProducts({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(relatedProductsProvider(productId));

    return products.maybeWhen(
      data: (value) => value.isEmpty
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(top: AppDimens.space32),
              child: ProductCarousel(
                title: 'You may also like',
                products: value,
              ),
            ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

/// The pinned price and add-to-cart bar.
class _BuyBar extends StatelessWidget {
  const _BuyBar({required this.state, this.onAddToCart});

  final ProductDetailState state;
  final AddToCartCallback? onAddToCart;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final product = state.product;
    if (product == null) return const SizedBox.shrink();

    final variant = state.selectedVariant;
    final canAdd = state.canAddToCart && onAddToCart != null;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.line)),
      ),
      child: SafeArea(
        minimum: const EdgeInsets.all(AppDimens.pageGutter),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'TOTAL',
                    style: AppTypography.eyebrow.copyWith(
                      color: palette.inkSubtle,
                    ),
                  ),
                  const SizedBox(height: AppDimens.space4),
                  Text(
                    Formatters.price(state.displayPrice * state.quantity),
                    style: AppTypography.price.copyWith(color: palette.ink),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimens.space16),
            SizedBox(
              height: AppDimens.controlHeightLg,
              child: FilledButton(
                onPressed: canAdd
                    ? () => onAddToCart!(product, variant!, state.quantity)
                    : null,
                child: Text(
                  switch (variant) {
                    null => 'SELECT OPTIONS',
                    final v when !v.isSelectable => 'SOLD OUT',
                    _ => 'ADD TO BAG',
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
