import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';

/// One row of the settings list.
///
/// A local copy of the account menu row rather than an import from the profile
/// feature: two presentation layers importing each other's widgets is how a
/// shared-widget tangle starts, and the shape is small enough that a copy is
/// cheaper than the coupling.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
    this.subtitle,
    this.trailing,
    this.isDestructive = false,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool showChevron;

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
            ] else if (showChevron && !isDestructive)
              Icon(Icons.chevron_right, size: 20, color: palette.inkSubtle),
          ],
        ),
      ),
    );
  }
}

/// A small caps label above a group of [SettingsTile]s.
class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader(this.label, {super.key});

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
