import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/formatters.dart';

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

  final int? count;

  final double size;

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

  IconData _iconFor(int index) {
    final filled = rating - index;
    if (filled >= 0.75) return Icons.star_rounded;
    if (filled >= 0.25) return Icons.star_half_rounded;
    return Icons.star_outline_rounded;
  }
}
