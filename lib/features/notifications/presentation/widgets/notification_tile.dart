import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/app_notification.dart';

/// The icon and accent colour for each notification type.
///
/// [NotificationType.unknown] resolves to a neutral bell rather than throwing:
/// the enum is shared with the admin app and gains members server-side, and a
/// single unfamiliar row must not blank the list.
({IconData icon, Color colour}) notificationStyle(
  NotificationType type,
  AppPalette palette,
) =>
    switch (type) {
      NotificationType.orderPlaced =>
        (icon: Icons.receipt_long_outlined, colour: palette.info),
      NotificationType.orderStatusChanged =>
        (icon: Icons.local_shipping_outlined, colour: palette.info),
      NotificationType.orderDelivered =>
        (icon: Icons.inventory_2_outlined, colour: palette.success),
      NotificationType.orderCancelled =>
        (icon: Icons.cancel_outlined, colour: palette.danger),
      NotificationType.returnRequested =>
        (icon: Icons.assignment_return_outlined, colour: palette.warning),
      NotificationType.returnResolved =>
        (icon: Icons.task_alt_outlined, colour: palette.success),
      NotificationType.lowStock =>
        (icon: Icons.warning_amber_outlined, colour: palette.warning),
      NotificationType.newUser =>
        (icon: Icons.person_add_outlined, colour: palette.info),
      NotificationType.newOrder =>
        (icon: Icons.shopping_bag_outlined, colour: palette.accent),
      NotificationType.reviewPosted =>
        (icon: Icons.rate_review_outlined, colour: palette.accent),
      NotificationType.unknown =>
        (icon: Icons.notifications_none, colour: palette.inkSubtle),
    };

/// One row of the notification list.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    required this.notification,
    required this.onTap,
    super.key,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final style = notificationStyle(notification.type, palette);
    final isUnread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        // Unread rows sit on a tinted background and carry a leading rule —
        // colour alone would not survive a grayscale or colour-blind view.
        color: isUnread ? palette.accentSubtle : palette.surface,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.pageGutter,
          vertical: AppDimens.space12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: palette.surfaceSunken,
                borderRadius: AppDimens.borderRadiusSm,
              ),
              alignment: Alignment.center,
              child: Icon(style.icon, size: 18, color: style.colour),
            ),
            const SizedBox(width: AppDimens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: context.text.bodyMedium?.copyWith(
                            fontWeight:
                                isUnread ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (isUnread) ...[
                        const SizedBox(width: AppDimens.space8),
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: AppDimens.space4),
                          decoration: BoxDecoration(
                            color: palette.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppDimens.space4),
                  Text(
                    notification.message,
                    style: context.text.bodySmall,
                  ),
                  const SizedBox(height: AppDimens.space4),
                  Row(
                    children: [
                      Text(
                        notification.type.label.toUpperCase(),
                        style: context.text.labelSmall?.copyWith(
                          color: style.colour,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: AppDimens.space8),
                      Text(
                        Formatters.relative(notification.createdAt),
                        style: context.text.bodySmall?.copyWith(
                          color: palette.inkSubtle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
