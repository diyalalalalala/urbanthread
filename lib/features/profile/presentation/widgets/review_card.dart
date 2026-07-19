import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/review.dart';
import 'rating_stars.dart';

/// One of the customer's own reviews, with the product it is about.
class ReviewCard extends StatelessWidget {
  const ReviewCard({
    required this.review,
    required this.onEdit,
    required this.onDelete,
    super.key,
    this.onOpenProduct,
  });

  final Review review;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onOpenProduct;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final product = review.product;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.space12),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.line),
        borderRadius: AppDimens.borderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onOpenProduct,
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.space12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppNetworkImage(
                    url: product?.imageUrl,
                    width: 56,
                    height: 72,
                    borderRadius: AppDimens.borderRadiusSm,
                  ),
                  const SizedBox(width: AppDimens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // `my-reviews` populates the product, but a review
                          // fetched any other way carries only the id.
                          product?.name ?? 'Product',
                          style: context.text.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppDimens.space4),
                        Row(
                          children: [
                            RatingStars(rating: review.rating),
                            const SizedBox(width: AppDimens.space8),
                            Text(
                              Formatters.relative(review.displayedAt),
                              style: context.text.bodySmall?.copyWith(
                                color: palette.inkSubtle,
                              ),
                            ),
                          ],
                        ),
                        if (review.isVerifiedPurchase) ...[
                          const SizedBox(height: AppDimens.space4),
                          Text(
                            'VERIFIED PURCHASE',
                            style: context.text.labelSmall?.copyWith(
                              color: palette.success,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.space12,
              0,
              AppDimens.space12,
              AppDimens.space8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (review.title.isNotEmpty) ...[
                  Text(review.title, style: context.text.titleSmall),
                  const SizedBox(height: AppDimens.space4),
                ],
                Text(review.comment, style: context.text.bodySmall),
                if (!review.status.isVisibleToOthers) ...[
                  const SizedBox(height: AppDimens.space8),
                  _StatusNotice(review: review),
                ],
                if (review.helpfulCount > 0) ...[
                  const SizedBox(height: AppDimens.space8),
                  Text(
                    '${Formatters.compact(review.helpfulCount)} found this '
                    'helpful',
                    style: context.text.bodySmall?.copyWith(
                      color: palette.inkSubtle,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: palette.line),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('EDIT'),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('DELETE'),
                style: TextButton.styleFrom(foregroundColor: palette.danger),
              ),
              const SizedBox(width: AppDimens.space4),
            ],
          ),
        ],
      ),
    );
  }
}

/// Explains a non-approved review.
///
/// New reviews default to `approved`, so seeing this at all means a moderator
/// acted — worth surfacing plainly rather than silently hiding the row.
class _StatusNotice extends StatelessWidget {
  const _StatusNotice({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isRejected = review.status == ReviewStatus.rejected;
    final colour = isRejected ? palette.danger : palette.warning;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.space8),
      decoration: BoxDecoration(
        color: isRejected ? palette.dangerSubtle : palette.warningSubtle,
        borderRadius: AppDimens.borderRadiusSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            review.status.label,
            style: context.text.labelSmall?.copyWith(color: colour),
          ),
          if (review.moderationNote.isNotEmpty) ...[
            const SizedBox(height: AppDimens.space2),
            Text(
              review.moderationNote,
              style: context.text.bodySmall?.copyWith(color: colour),
            ),
          ],
        ],
      ),
    );
  }
}
