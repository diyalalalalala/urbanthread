import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../categories/domain/entities/brand.dart';
import '../../domain/entities/home_feed.dart';
import 'section_header.dart';
import 'shimmer_block.dart';

/// Horizontally scrolling strip of featured brands.
///
/// Logos are contained, never cropped — brand marks arrive at every aspect
/// ratio the catalogue's suppliers felt like uploading, and a cover fit would
/// slice the wordmark off half of them.
class FeaturedBrandsStrip extends StatelessWidget {
  const FeaturedBrandsStrip({
    required this.section,
    required this.onOpenBrand,
    super.key,
    this.onSeeAll,
    this.isLoading = false,
  });

  final HomeSection<Brand> section;
  final ValueChanged<Brand> onOpenBrand;
  final VoidCallback? onSeeAll;
  final bool isLoading;

  static const _tileWidth = 132.0;
  static const _tileHeight = 84.0;

  @override
  Widget build(BuildContext context) {
    if (isLoading && section.isEmpty) return const _BrandsSkeleton();

    // Same reasoning as the categories strip: a failed brand strip is left
    // out rather than replaced with an error, because nothing else on the
    // page depends on it.
    if (section.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Brands we carry',
          eyebrow: 'Featured',
          onSeeAll: onSeeAll,
        ),
        SizedBox(
          height: _tileHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.pageGutter,
            ),
            itemCount: section.items.length,
            separatorBuilder: (context, _) =>
                const SizedBox(width: AppDimens.space12),
            itemBuilder: (context, index) {
              final brand = section.items[index];
              return _BrandCard(
                brand: brand,
                onTap: () => onOpenBrand(brand),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BrandCard extends StatelessWidget {
  const _BrandCard({required this.brand, required this.onTap});

  final Brand brand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: FeaturedBrandsStrip._tileWidth,
        padding: const EdgeInsets.all(AppDimens.space12),
        decoration: BoxDecoration(
          border: Border.all(color: palette.line),
          borderRadius: AppDimens.borderRadius,
          color: palette.surface,
        ),
        alignment: Alignment.center,
        child: brand.hasLogo
            ? AppNetworkImage(
                url: brand.logoUrl,
                fit: BoxFit.contain,
                placeholderIcon: Icons.storefront_outlined,
              )
            : Text(
                brand.name.toUpperCase(),
                style: context.text.labelLarge,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
  }
}

class _BrandsSkeleton extends StatelessWidget {
  const _BrandsSkeleton();

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
                ShimmerBlock(width: 70, height: 9),
                SizedBox(height: AppDimens.space8),
                ShimmerBlock(width: 160, height: 20),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimens.pageGutter),
            child: Row(
              children: [
                ShimmerBlock(
                  width: FeaturedBrandsStrip._tileWidth,
                  height: FeaturedBrandsStrip._tileHeight,
                  borderRadius: AppDimens.borderRadius,
                ),
                SizedBox(width: AppDimens.space12),
                ShimmerBlock(
                  width: FeaturedBrandsStrip._tileWidth,
                  height: FeaturedBrandsStrip._tileHeight,
                  borderRadius: AppDimens.borderRadius,
                ),
                SizedBox(width: AppDimens.space12),
                ShimmerBlock(
                  width: FeaturedBrandsStrip._tileWidth,
                  height: FeaturedBrandsStrip._tileHeight,
                  borderRadius: AppDimens.borderRadius,
                ),
              ],
            ),
          ),
        ],
      );
}
