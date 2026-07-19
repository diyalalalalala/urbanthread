import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';

/// One row of the account menu.
///
/// Square by design — the brand's radius is 4px, so Material's default rounded
/// list tiles are overridden rather than inherited.
class AccountTile extends StatelessWidget {
  const AccountTile({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
    this.subtitle,
    this.trailing,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final foreground = isDestructive ? palette.danger : palette.ink;

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: AppDimens.minTapTarget),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.pageGutter,
          vertical: AppDimens.space12,
        ),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: palette.line)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: foreground),
            const SizedBox(width: AppDimens.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: context.text.bodyMedium?.copyWith(color: foreground),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppDimens.space2),
                    Text(
                      subtitle!,
                      style: context.text.bodySmall?.copyWith(
                        color: palette.inkSubtle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppDimens.space8),
              trailing!,
            ] else if (!isDestructive)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: palette.inkSubtle,
              ),
          ],
        ),
      ),
    );
  }
}

/// A small caps label above a group of [AccountTile]s.
class AccountSectionHeader extends StatelessWidget {
  const AccountSectionHeader(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pageGutter,
          AppDimens.space24,
          AppDimens.pageGutter,
          AppDimens.space8,
        ),
        child: Text(
          label.toUpperCase(),
          style: context.text.labelSmall?.copyWith(
            color: context.palette.inkSubtle,
            letterSpacing: 1.2,
          ),
        ),
      );
}
