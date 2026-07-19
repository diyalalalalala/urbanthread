import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';

/// Recent searches, shown while the box is empty or too short to query.
///
/// Nothing is rendered when the history is empty rather than showing an
/// "empty history" placeholder — a first-time shopper does not need to be
/// told they have not searched before.
class SearchHistoryList extends StatelessWidget {
  const SearchHistoryList({
    required this.terms,
    required this.onTermSelected,
    required this.onTermRemoved,
    required this.onCleared,
    super.key,
  });

  final List<String> terms;
  final ValueChanged<String> onTermSelected;
  final ValueChanged<String> onTermRemoved;
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context) {
    if (terms.isEmpty) return const SizedBox.shrink();

    final palette = context.palette;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.space8),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.pageGutter,
            AppDimens.space12,
            AppDimens.space8,
            AppDimens.space4,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'RECENT SEARCHES',
                  style: AppTypography.eyebrow.copyWith(
                    color: palette.inkSubtle,
                  ),
                ),
              ),
              TextButton(
                onPressed: onCleared,
                child: const Text('CLEAR'),
              ),
            ],
          ),
        ),
        for (final term in terms)
          ListTile(
            leading: Icon(
              Icons.history,
              size: 20,
              color: palette.inkSubtle,
            ),
            title: Text(term, style: context.text.bodyMedium),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 16),
              tooltip: 'Remove',
              onPressed: () => onTermRemoved(term),
            ),
            onTap: () => onTermSelected(term),
          ),
      ],
    );
  }
}
