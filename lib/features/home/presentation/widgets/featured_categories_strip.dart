import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../categories/domain/entities/category.dart';
import '../../domain/entities/home_feed.dart';
import 'section_header.dart';
import 'shimmer_block.dart';

class FeaturedCategoriesStrip extends StatelessWidget {
  const FeaturedCategoriesStrip({
    required this.section,
    required this.onOpenCategory,
    super.key,
    this.onSeeAll,
    this.isLoading = false,
  });

  final HomeSection<Category> section;
  final ValueChanged<Category> onOpenCategory;
  final VoidCallback? onSeeAll;
  final bool isLoading;

  static const _diameter = 76.0;
  static const _labelLines = 2;

  static double _stripHeight(BuildContext context) {
    final style = context.text.bodySmall;
    final fontSize = MediaQuery.textScalerOf(
      context,
    ).scale(style?.fontSize ?? 12.5);
    final lineHeight = fontSize * (style?.height ?? 1.5);

    return _diameter +
        AppDimens.space8 +
        (lineHeight * _labelLines).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && section.isEmpty) return const _StripSkeleton();

    if (section.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Shop by category',
          eyebrow: 'Collections',
          onSeeAll: onSeeAll,
        ),
        SizedBox(
          height: _stripHeight(context),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.pageGutter,
            ),
            itemCount: section.items.length,
            separatorBuilder: (context, _) =>
                const SizedBox(width: AppDimens.space16),
            itemBuilder: (context, index) {
              final category = section.items[index];
              return _CategoryChip(
                category: category,
                onTap: () => onOpenCategory(category),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: FeaturedCategoriesStrip._diameter,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppNetworkImage(
                url: category.imageUrl,
                width: FeaturedCategoriesStrip._diameter,
                height: FeaturedCategoriesStrip._diameter,
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppDimens.radiusPill),
                ),
                placeholderIcon: Icons.category_outlined,
              ),
              const SizedBox(height: AppDimens.space8),
              Flexible(
                child: Text(
                  category.name,
                  style: context.text.bodySmall,
                  maxLines: FeaturedCategoriesStrip._labelLines,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
}

class _StripSkeleton extends StatelessWidget {
  const _StripSkeleton();

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
                ShimmerBlock(width: 80, height: 9),
                SizedBox(height: AppDimens.space8),
                ShimmerBlock(width: 190, height: 20),
              ],
            ),
          ),
          SizedBox(
            height: FeaturedCategoriesStrip._stripHeight(context),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimens.pageGutter),
              child: Row(
                children: [
                  _ChipSkeleton(),
                  SizedBox(width: AppDimens.space16),
                  _ChipSkeleton(),
                  SizedBox(width: AppDimens.space16),
                  _ChipSkeleton(),
                  SizedBox(width: AppDimens.space16),
                  _ChipSkeleton(),
                ],
              ),
            ),
          ),
        ],
      );
}

class _ChipSkeleton extends StatelessWidget {
  const _ChipSkeleton();

  @override
  Widget build(BuildContext context) => const Column(
        children: [
          ShimmerBlock(
            width: FeaturedCategoriesStrip._diameter,
            height: FeaturedCategoriesStrip._diameter,
            borderRadius: BorderRadius.all(
              Radius.circular(AppDimens.radiusPill),
            ),
          ),
          SizedBox(height: AppDimens.space8),
          ShimmerBlock(width: 52, height: 9),
        ],
      );
}
