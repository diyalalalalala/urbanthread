import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/product_query.dart';

/// Opens the sort picker and resolves to the chosen order, or null if the
/// sheet was dismissed.
Future<ProductSort?> showSortSheet(
  BuildContext context, {
  required ProductSort current,
}) =>
    showModalBottomSheet<ProductSort>(
      context: context,
      backgroundColor: context.palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusLg),
        ),
      ),
      builder: (context) => SortSheet(current: current),
    );

/// The eight sort orders the catalogue endpoint accepts.
///
/// Enumerating [ProductSort.values] rather than hardcoding a list means the
/// sheet can never offer an order the API would answer with a 422 — the enum
/// is the same closed set the validator checks against.
class SortSheet extends StatelessWidget {
  const SortSheet({required this.current, super.key});

  final ProductSort current;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SafeArea(
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
              'SORT BY',
              style: AppTypography.eyebrow.copyWith(color: palette.inkSubtle),
            ),
          ),
          for (final sort in ProductSort.values)
            ListTile(
              title: Text(
                sort.label,
                style: context.text.bodyMedium?.copyWith(
                  color: sort == current ? palette.accent : palette.ink,
                  fontWeight:
                      sort == current ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              trailing: sort == current
                  ? Icon(Icons.check, size: 18, color: palette.accent)
                  : null,
              onTap: () => Navigator.of(context).pop(sort),
            ),
          const SizedBox(height: AppDimens.space8),
        ],
      ),
    );
  }
}
