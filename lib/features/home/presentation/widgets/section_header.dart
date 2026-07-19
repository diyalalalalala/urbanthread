import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';

/// The heading above every strip on the storefront: eyebrow, title, and an
/// optional "see all" on the right.
///
/// Factored out because six strips share it, and a home screen whose section
/// headings drift apart by a few pixels reads as unfinished more quickly than
/// almost anything else on the page.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    super.key,
    this.eyebrow,
    this.onSeeAll,
    this.seeAllLabel = 'SEE ALL',
  });

  final String title;
  final String? eyebrow;
  final VoidCallback? onSeeAll;
  final String seeAllLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pageGutter,
        AppDimens.space32,
        AppDimens.pageGutter,
        AppDimens.space16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (eyebrow != null) ...[
                  Text(
                    eyebrow!.toUpperCase(),
                    style: AppTypography.eyebrow.copyWith(
                      color: palette.inkSubtle,
                    ),
                  ),
                  const SizedBox(height: AppDimens.space8),
                ],
                Text(
                  title,
                  style: context.text.headlineSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text(seeAllLabel),
            ),
        ],
      ),
    );
  }
}
