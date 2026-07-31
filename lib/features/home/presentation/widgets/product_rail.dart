import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/text_metrics.dart';
import '../../domain/entities/home_feed.dart';
import '../../domain/entities/home_product.dart';
import 'home_product_card.dart';
import 'section_header.dart';
import 'shimmer_block.dart';

class ProductRail extends StatelessWidget {
  const ProductRail({
    required this.collection,
    required this.section,
    required this.onOpenProduct,
    super.key,
    this.onSeeAll,
    this.onRetry,
    this.isLoading = false,
  });

  final HomeCollection collection;
  final HomeSection<HomeProduct> section;

  final ValueChanged<HomeProduct> onOpenProduct;

  final VoidCallback? onSeeAll;
  final VoidCallback? onRetry;
  final bool isLoading;

  static const _cardWidth = 156.0;

  static const _nameLines = 2;
  static const _ratingIconSize = 14.0;

  static double railHeight(BuildContext context) {
    final text = context.text;

    final caption = AppDimens.space12 +
        textBlockHeight(context, AppTypography.eyebrow) +
        AppDimens.space4 +
        textBlockHeight(context, text.bodyMedium, lines: _nameLines) +
        AppDimens.space8 +
        textBlockHeight(context, text.titleSmall) +
        AppDimens.space4 +
        math.max(_ratingIconSize, textBlockHeight(context, text.bodySmall));

    return (_cardWidth / AppDimens.productAspectRatio + caption)
        .ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && section.isEmpty) return const _RailSkeleton();

    if (section.isEmpty) {
      final failure = section.failure;
      if (failure == null) return const SizedBox.shrink();
      return _RailFailure(
        collection: collection,
        message: failure.message,
        onRetry: onRetry,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: collection.title,
          eyebrow: collection.subtitle,
          onSeeAll: onSeeAll,
        ),
        SizedBox(
          height: railHeight(context),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.pageGutter,
            ),
            itemCount: section.items.length,
            separatorBuilder: (context, _) =>
                const SizedBox(width: AppDimens.space12),
            itemBuilder: (context, index) {
              final product = section.items[index];
              return HomeProductCard(
                product: product,
                width: _cardWidth,
                onTap: () => onOpenProduct(product),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RailFailure extends StatelessWidget {
  const _RailFailure({
    required this.collection,
    required this.message,
    this.onRetry,
  });

  final HomeCollection collection;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: collection.title, eyebrow: collection.subtitle),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.pageGutter,
            ),
            child: Container(
              padding: const EdgeInsets.all(AppDimens.space16),
              decoration: BoxDecoration(
                border: Border.all(color: context.palette.line),
                borderRadius: AppDimens.borderRadius,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      message,
                      style: context.text.bodySmall?.copyWith(
                        color: context.palette.inkMuted,
                      ),
                    ),
                  ),
                  if (onRetry != null)
                    TextButton(
                      onPressed: onRetry,
                      child: const Text('RETRY'),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
}

class _RailSkeleton extends StatelessWidget {
  const _RailSkeleton();

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimens.pageGutter,
              AppDimens.space32,
              AppDimens.pageGutter,
              AppDimens.space16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBlock(width: 90, height: 9),
                SizedBox(height: AppDimens.space8),
                ShimmerBlock(width: 170, height: 20),
              ],
            ),
          ),
          SizedBox(
            height: ProductRail.railHeight(context),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.pageGutter,
              ),
              itemCount: 4,
              separatorBuilder: (context, _) =>
                  const SizedBox(width: AppDimens.space12),
              itemBuilder: (context, _) => const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBlock(
                    width: 156,
                    height: 156 / AppDimens.productAspectRatio,
                    borderRadius: AppDimens.borderRadius,
                  ),
                  SizedBox(height: AppDimens.space12),
                  ShimmerBlock(width: 60, height: 9),
                  SizedBox(height: AppDimens.space8),
                  ShimmerBlock(width: 130, height: 12),
                  SizedBox(height: AppDimens.space8),
                  ShimmerBlock(width: 80, height: 14),
                ],
              ),
            ),
          ),
        ],
      );
}
