import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../categories/domain/entities/category.dart';
import '../../domain/entities/home_feed.dart';
import 'section_header.dart';
import 'shimmer_block.dart';

/// Horizontally scrolling strip of featured categories.
///
/// Circular artwork here, against the square 4px radius used everywhere else.
/// The exception is deliberate and is the one the web client makes too:
/// circles read as "browse by" navigation, squares read as "buy this", and
/// the distinction is what stops the strip from being mistaken for a rail of
/// products a few pixels further down the page.
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
  static const _stripHeight = _diameter + 44;

  @override
  Widget build(BuildContext context) {
    if (isLoading && section.isEmpty) return const _StripSkeleton();

    // A failed featured strip is simply not drawn. Unlike a product rail it
    // carries no merchandising promise the user is waiting on, and the full
    // taxonomy is one tab away — an error box here would be noise.
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
          height: _stripHeight,
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
              Text(
                category.name,
                style: context.text.bodySmall,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
}

class _StripSkeleton extends StatelessWidget {
  const _StripSkeleton();

  @override
  Widget build(BuildContext context) => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
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
            height: FeaturedCategoriesStrip._stripHeight,
            child: Padding(
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
