import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/formatters.dart';

/// Five stars for a 0–5 average, with optional half-fill and review count.
///
/// The API rounds `rating.average` to one decimal, so halves are the finest
/// distinction worth rendering — anything more precise would be invented
/// resolution.
class RatingStars extends StatelessWidget {
  const RatingStars({
    required this.rating,
    super.key,
    this.count,
    this.size = 14,
    this.showValue = false,
    this.color,
  });

  final double rating;

  /// Number of reviews. Rendered as `(1.2K)` when present.
  final int? count;

  final double size;

  /// Prints the numeric average next to the stars, for a summary block.
  final bool showValue;

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? context.palette.warning;
    final emptyColor = context.palette.line;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < 5; index++)
          Icon(
            _iconFor(index),
            size: size,
            color: rating >= index + 0.25 ? starColor : emptyColor,
          ),
        if (showValue) ...[
          const SizedBox(width: AppDimens.space4),
          Text(
            rating.toStringAsFixed(1),
            style: context.text.labelMedium?.copyWith(
              color: context.palette.ink,
            ),
          ),
        ],
        if (count != null) ...[
          const SizedBox(width: AppDimens.space4),
          Text(
            '(${Formatters.compact(count)})',
            style: context.text.labelMedium,
          ),
        ],
      ],
    );
  }

  /// A star is half-filled between .25 and .75 of its position — the same
  /// thresholds Material's own rating widgets use, so 4.5 shows four and a
  /// half rather than rounding to five.
  IconData _iconFor(int index) {
    final filled = rating - index;
    if (filled >= 0.75) return Icons.star_rounded;
    if (filled >= 0.25) return Icons.star_half_rounded;
    return Icons.star_outline_rounded;
  }
}
