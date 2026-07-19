import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../providers/unread_notification_count.dart';

/// App-bar bell with an unread badge, backed by
/// `unreadNotificationCountProvider`.
///
/// The count never enters an error state — a failed fetch shows a plain bell,
/// because a broken badge is worse than no badge.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationCountProvider).value ?? 0;

    return IconButton(
      tooltip: unread > 0 ? '$unread unread notifications' : 'Notifications',
      onPressed: () => context.push(AppRoutes.notifications),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none),
          if (unread > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.space4,
                ),
                constraints: const BoxConstraints(minWidth: 16),
                height: 16,
                decoration: BoxDecoration(
                  color: context.palette.accent,
                  borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                ),
                alignment: Alignment.center,
                child: Text(
                  // Anything past 99 is noise in a 16px badge.
                  unread > 99 ? '99+' : '$unread',
                  style: context.text.labelSmall?.copyWith(
                    color: context.palette.accentInk,
                    fontSize: 10,
                    height: 1.2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
