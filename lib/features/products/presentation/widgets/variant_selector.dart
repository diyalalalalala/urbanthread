import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/product.dart';

/// Colour swatches and size chips for the product page.
///
/// The two axes are not independent: a size can exist for one colour and not
/// another, because a variant is a *pair*. So the size row is derived from
/// the selected colour rather than from the product's full size list, and a
/// size that pair does not offer is shown disabled rather than hidden —
/// hiding it makes the row jump as colours are tried, which reads as a bug.
class VariantSelector extends StatelessWidget {
  const VariantSelector({
    required this.product,
    required this.selectedColor,
    required this.selectedSize,
    required this.onColorSelected,
    required this.onSizeSelected,
    super.key,
  });

  final Product product;
  final String? selectedColor;
  final String? selectedSize;
  final ValueChanged<String> onColorSelected;
  final ValueChanged<String> onSizeSelected;

  @override
  Widget build(BuildContext context) {
    final colors = product.availableColors;
    final sizes = product.availableSizes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (colors.isNotEmpty) ...[
          _SectionLabel(
            label: 'Colour',
            value: selectedColor,
          ),
          const SizedBox(height: AppDimens.space12),
          Wrap(
            spacing: AppDimens.space12,
            runSpacing: AppDimens.space12,
            children: [
              for (final color in colors)
                _ColorSwatch(
                  color: color,
                  isSelected: color.name == selectedColor,
                  // A colour with no stocked variant is still selectable: the
                  // shopper should be able to inspect it and see which sizes
                  // sold out, rather than find the swatch inert.
                  isSoldOut: !product.variants.any(
                    (variant) =>
                        variant.color.name == color.name &&
                        variant.isSelectable,
                  ),
                  onTap: () => onColorSelected(color.name),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.space24),
        ],
        if (sizes.isNotEmpty) ...[
          _SectionLabel(label: 'Size', value: selectedSize),
          const SizedBox(height: AppDimens.space12),
          Wrap(
            spacing: AppDimens.space8,
            runSpacing: AppDimens.space8,
            children: [
              for (final size in sizes)
                _SizeChip(
                  size: size,
                  isSelected: size == selectedSize,
                  isAvailable: selectedColor == null
                      ? product.variants.any(
                          (variant) =>
                              variant.size == size && variant.isSelectable,
                        )
                      : product
                          .variants
                          .any(
                            (variant) =>
                                variant.size == size &&
                                variant.color.name == selectedColor &&
                                variant.isSelectable,
                          ),
                  onTap: () => onSizeSelected(size),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.eyebrow.copyWith(
              color: context.palette.inkSubtle,
            ),
          ),
          if (value != null) ...[
            const SizedBox(width: AppDimens.space8),
            Text(value!, style: context.text.titleSmall),
          ],
        ],
      );
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.isSoldOut,
    required this.onTap,
  });

  final ProductColor color;
  final bool isSelected;
  final bool isSoldOut;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final argb = color.argb;
    final swatch = argb == null ? palette.surfaceSunken : Color(argb);

    return Semantics(
      label: '${color.name}${isSoldOut ? ', sold out' : ''}',
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: AppDimens.minTapTarget,
          height: AppDimens.minTapTarget,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? palette.accent : palette.line,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: swatch,
                  // A near-white swatch would vanish against the surface, so
                  // every swatch carries a hairline of its own.
                  border: Border.all(color: palette.line),
                ),
              ),
              if (isSoldOut)
                Center(
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: palette.canvas,
                    shadows: [
                      Shadow(color: palette.ink, blurRadius: 2),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SizeChip extends StatelessWidget {
  const _SizeChip({
    required this.size,
    required this.isSelected,
    required this.isAvailable,
    required this.onTap,
  });

  final String size;
  final bool isSelected;
  final bool isAvailable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return InkWell(
      onTap: isAvailable ? onTap : null,
      borderRadius: AppDimens.borderRadius,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: AppDimens.minTapTarget,
          minHeight: AppDimens.controlHeightSm,
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.space12),
        decoration: BoxDecoration(
          color: isSelected ? palette.ink : palette.surface,
          borderRadius: AppDimens.borderRadius,
          border: Border.all(
            color: isSelected ? palette.ink : palette.line,
          ),
        ),
        child: Text(
          size,
          style: AppTypography.button.copyWith(
            color: isSelected
                ? palette.canvas
                : (isAvailable ? palette.ink : palette.inkSubtle),
            decoration: isAvailable ? null : TextDecoration.lineThrough,
            decorationColor: palette.inkSubtle,
          ),
        ),
      ),
    );
  }
}
