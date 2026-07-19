import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/brand.dart';

/// A brand, as a bordered card with its logo.
///
/// Brand logos are wildly inconsistent in aspect ratio, so the image is
/// contained rather than cropped — a cover fit would slice the wordmark off
/// half the catalogue. When there is no logo at all the initials stand in,
/// which reads better than a generic image placeholder for a name-led brand.
class BrandTile extends StatelessWidget {
  const BrandTile({
    required this.brand,
    required this.onTap,
    super.key,
    this.width,
  });

  final Brand brand;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: palette.line),
            borderRadius: AppDimens.borderRadius,
            color: palette.surface,
          ),
          padding: const EdgeInsets.all(AppDimens.space12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 48,
                child: brand.hasLogo
                    ? AppNetworkImage(
                        url: brand.logoUrl,
                        fit: BoxFit.contain,
                        height: 48,
                        placeholderIcon: Icons.storefront_outlined,
                      )
                    : _Initials(brand: brand),
              ),
              const SizedBox(height: AppDimens.space8),
              Text(
                brand.name,
                style: context.text.labelLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              if (brand.country.isNotEmpty) ...[
                const SizedBox(height: AppDimens.space2),
                Text(
                  brand.country.toUpperCase(),
                  style: AppTypography.eyebrow.copyWith(
                    color: palette.inkSubtle,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.brand});

  final Brand brand;

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.center,
        color: context.palette.surfaceSunken,
        child: Text(
          brand.initials,
          style: context.text.titleLarge?.copyWith(
            color: context.palette.inkMuted,
          ),
        ),
      );
}
