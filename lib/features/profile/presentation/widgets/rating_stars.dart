import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';

/// A read-only 1–5 star row.
class RatingStars extends StatelessWidget {
  const RatingStars({required this.rating, super.key, this.size = 16});

  final num rating;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          final filled = index < rating.round();
          return Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: filled ? context.palette.warning : context.palette.inkSubtle,
          );
        }),
      );
}

/// The tappable version, for composing a review.
///
/// There is no "zero stars" state: the backend requires 1..5, so the control
/// starts at whatever the caller seeds it with and can never be cleared —
/// letting it reach zero would just produce a 422 on submit.
class RatingInput extends StatelessWidget {
  const RatingInput({
    required this.rating,
    required this.onChanged,
    super.key,
    this.size = 36,
  });

  final int rating;
  final ValueChanged<int> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          final value = index + 1;
          final filled = value <= rating;
          return IconButton(
            onPressed: () => onChanged(value),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.space2,
            ),
            constraints: const BoxConstraints(
              minWidth: AppDimens.minTapTarget,
              minHeight: AppDimens.minTapTarget,
            ),
            tooltip: '$value ${value == 1 ? 'star' : 'stars'}',
            icon: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color:
                  filled ? context.palette.warning : context.palette.inkSubtle,
            ),
          );
        }),
      );
}
