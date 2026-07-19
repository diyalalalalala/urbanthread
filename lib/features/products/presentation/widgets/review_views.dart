import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/review.dart';
import 'rating_stars.dart';

/// The average, the count and the 1–5 histogram.
///
/// Fed from `/reviews/product/{id}/stats` rather than from the product's own
/// `rating` block: the product document holds a denormalised copy that is
/// only recomputed when the review service writes it back, so it can trail a
/// review posted seconds ago. Two different numbers on one screen is worse
/// than one extra request.
class RatingSummary extends StatelessWidget {
  const RatingSummary({
    required this.stats,
    super.key,
    this.selectedRating,
    this.onRatingSelected,
  });

  final ReviewStats stats;

  /// The star filter currently applied to the list below, if any.
  final int? selectedRating;

  /// Tapping a histogram row filters the list. Null makes the bars inert.
  final ValueChanged<int?>? onRatingSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stats.average.toStringAsFixed(1),
              style: context.text.displaySmall,
            ),
            const SizedBox(height: AppDimens.space4),
            RatingStars(rating: stats.average, size: 16),
            const SizedBox(height: AppDimens.space4),
            Text(
              '${stats.count} ${stats.count == 1 ? 'review' : 'reviews'}',
              style: context.text.bodySmall,
            ),
          ],
        ),
        const SizedBox(width: AppDimens.space24),
        Expanded(
          child: Column(
            children: [
              // Descending, so five stars sits at the top where shoppers look.
              for (var stars = 5; stars >= 1; stars--)
                _HistogramRow(
                  stars: stars,
                  count: stats.countFor(stars),
                  fraction: stats.fractionFor(stars),
                  isSelected: selectedRating == stars,
                  onTap: onRatingSelected == null
                      ? null
                      // Tapping the active row clears the filter, which is the
                      // only way back to "all reviews" from the histogram.
                      : () => onRatingSelected!(
                            selectedRating == stars ? null : stars,
                          ),
                  barColor: palette.warning,
                  trackColor: palette.surfaceSunken,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HistogramRow extends StatelessWidget {
  const _HistogramRow({
    required this.stars,
    required this.count,
    required this.fraction,
    required this.isSelected,
    required this.barColor,
    required this.trackColor,
    this.onTap,
  });

  final int stars;
  final int count;
  final double fraction;
  final bool isSelected;
  final Color barColor;
  final Color trackColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.space2),
          child: Row(
            children: [
              SizedBox(
                width: 14,
                child: Text('$stars', style: context.text.labelMedium),
              ),
              Icon(
                Icons.star_rounded,
                size: 12,
                color: context.palette.inkSubtle,
              ),
              const SizedBox(width: AppDimens.space8),
              Expanded(
                child: ClipRRect(
                  borderRadius: AppDimens.borderRadiusSm,
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 6,
                    backgroundColor: trackColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isSelected ? context.palette.accent : barColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.space8),
              SizedBox(
                width: 32,
                child: Text(
                  Formatters.compact(count),
                  style: context.text.labelMedium,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      );
}

/// One review.
class ReviewTile extends StatelessWidget {
  const ReviewTile({required this.review, super.key});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(review: review),
              const SizedBox(width: AppDimens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName, style: context.text.titleSmall),
                    const SizedBox(height: AppDimens.space2),
                    Text(
                      // `isEdited` matters to a reader deciding how much to
                      // trust a review, so it is surfaced rather than hidden.
                      review.isEdited
                          ? '${Formatters.relative(review.createdAt)} · edited'
                          : Formatters.relative(review.createdAt),
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
              RatingStars(rating: review.rating.toDouble(), size: 13),
            ],
          ),
          if (review.isVerifiedPurchase) ...[
            const SizedBox(height: AppDimens.space12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space8,
                vertical: AppDimens.space4,
              ),
              decoration: BoxDecoration(
                color: palette.successSubtle,
                borderRadius: AppDimens.borderRadiusSm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_outlined,
                    size: 12,
                    color: palette.success,
                  ),
                  const SizedBox(width: AppDimens.space4),
                  Text(
                    'VERIFIED PURCHASE',
                    style: AppTypography.eyebrow.copyWith(
                      color: palette.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (review.hasTitle) ...[
            const SizedBox(height: AppDimens.space12),
            Text(review.title, style: context.text.titleMedium),
          ],
          const SizedBox(height: AppDimens.space8),
          Text(review.comment, style: context.text.bodyMedium),
          if (review.helpfulCount > 0) ...[
            const SizedBox(height: AppDimens.space8),
            Text(
              '${Formatters.compact(review.helpfulCount)} found this helpful',
              style: context.text.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    if (review.userAvatarUrl != null) {
      return ClipOval(
        child: AppNetworkImage(
          url: review.userAvatarUrl,
          width: 36,
          height: 36,
          placeholderIcon: Icons.person_outline,
        ),
      );
    }

    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.surfaceSunken,
      ),
      child: Text(review.initials, style: context.text.titleSmall),
    );
  }
}

/// The review sort control — the review-list counterpart of the catalogue's
/// sort sheet, with its own closed set of wire values.
Future<ReviewSort?> showReviewSortSheet(
  BuildContext context, {
  required ReviewSort current,
}) =>
    showModalBottomSheet<ReviewSort>(
      context: context,
      backgroundColor: context.palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusLg),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.pageGutter,
                AppDimens.space20,
                AppDimens.pageGutter,
                AppDimens.space12,
              ),
              child: Text(
                'SORT REVIEWS',
                style: AppTypography.eyebrow.copyWith(
                  color: context.palette.inkSubtle,
                ),
              ),
            ),
            for (final sort in ReviewSort.values)
              ListTile(
                title: Text(
                  sort.label,
                  style: context.text.bodyMedium?.copyWith(
                    color: sort == current
                        ? context.palette.accent
                        : context.palette.ink,
                  ),
                ),
                trailing: sort == current
                    ? Icon(
                        Icons.check,
                        size: 18,
                        color: context.palette.accent,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(sort),
              ),
            const SizedBox(height: AppDimens.space8),
          ],
        ),
      ),
    );
