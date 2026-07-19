import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/app_notification.dart';
import '../providers/notifications_notifier.dart';
import '../widgets/failure_from_error.dart';
import '../widgets/notification_link.dart';
import '../widgets/notification_tile.dart';

/// The notification inbox: filter, read, delete.
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      ref.read(notificationsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);
    final value = state.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (value != null && value.hasUnread)
            IconButton(
              tooltip: 'Mark all as read',
              onPressed: _markAllRead,
              icon: const Icon(Icons.done_all),
            ),
          PopupMenuButton<_InboxAction>(
            onSelected: _handleMenu,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _InboxAction.markAllRead,
                child: Text('Mark all as read'),
              ),
              PopupMenuItem(
                value: _InboxAction.deleteRead,
                child: Text('Delete read notifications'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _Filters(state: value),
          Expanded(
            child: switch (state) {
              AsyncData(:final value) when value.notifications.isEmpty =>
                _EmptyInbox(unreadOnly: value.unreadOnly, hasType: value.type != null),
              AsyncData(:final value) => RefreshIndicator(
                  onRefresh: () =>
                      ref.read(notificationsProvider.notifier).refresh(),
                  child: ListView.separated(
                    controller: _scrollController,
                    itemCount: value.notifications.items.length +
                        (value.isLoadingMore ? 1 : 0),
                    separatorBuilder: (context, _) =>
                        Divider(height: 1, color: context.palette.line),
                    itemBuilder: (context, index) {
                      if (index >= value.notifications.items.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppDimens.space16,
                          ),
                          child: LoadingView(),
                        );
                      }

                      final notification = value.notifications.items[index];
                      return Dismissible(
                        key: ValueKey(notification.id),
                        direction: DismissDirection.endToStart,
                        background: const _DeleteBackground(),
                        // Confirm rather than delete-then-undo: the endpoint
                        // has no restore, so an accidental swipe would be
                        // unrecoverable.
                        confirmDismiss: (_) => _confirmDelete(notification),
                        child: NotificationTile(
                          notification: notification,
                          onTap: () => _open(notification),
                        ),
                      );
                    },
                  ),
                ),
              AsyncError(:final error) => FailureView(
                  failure: failureFrom(error),
                  onRetry: () => ref.invalidate(notificationsProvider),
                ),
              _ => const LoadingView(),
            },
          ),
        ],
      ),
    );
  }

  /// Marks the row read, then follows its link if the app has a screen for it.
  Future<void> _open(AppNotification notification) async {
    if (!notification.isRead) {
      await ref.read(notificationsProvider.notifier).markAsRead(notification.id);
    }
    if (!mounted) return;

    final target = NotificationLink.resolve(notification.link);
    if (target == null) {
      // An unrecognised link is not an error — the backend writes links for
      // the web client, and some of them have no mobile equivalent.
      if (notification.hasLink) {
        context.showSnack('That link cannot be opened in the app.');
      }
      return;
    }

    context.push(target);
  }

  Future<bool> _confirmDelete(AppNotification notification) async {
    final failure =
        await ref.read(notificationsProvider.notifier).delete(notification.id);

    if (!mounted) return failure == null;
    if (failure != null) {
      context.showSnack(failure.message, isError: true);
      return false;
    }
    // The notifier already removed it from the list, so the Dismissible is
    // told not to animate a second removal.
    return false;
  }

  Future<void> _markAllRead() async {
    final result = await ref.read(notificationsProvider.notifier).markAllAsRead();
    if (!mounted) return;

    context.showSnack(
      switch (result) {
        Success(:final value) => value == 0
            ? 'Nothing left to mark.'
            : '$value marked as read.',
        FailureResult(:final failure) => failure.message,
      },
      isError: result.isFailure,
    );
  }

  Future<void> _handleMenu(_InboxAction action) async {
    switch (action) {
      case _InboxAction.markAllRead:
        await _markAllRead();
      case _InboxAction.deleteRead:
        final result = await ref.read(notificationsProvider.notifier).deleteRead();
        if (!mounted) return;
        context.showSnack(
          switch (result) {
            // This one answers 200 with a count, unlike the single delete's
            // bare 204 — so there is a real number to report.
            Success(:final value) => value == 0
                ? 'No read notifications to remove.'
                : '$value removed.',
            FailureResult(:final failure) => failure.message,
          },
          isError: result.isFailure,
        );
    }
  }
}

enum _InboxAction { markAllRead, deleteRead }

class _Filters extends ConsumerWidget {
  const _Filters({required this.state});

  final NotificationsState? state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(notificationsProvider.notifier);
    final unreadOnly = state?.unreadOnly ?? false;
    final type = state?.type;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.palette.line)),
      ),
      padding: const EdgeInsets.symmetric(vertical: AppDimens.space8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.pageGutter),
        child: Row(
          children: [
            FilterChip(
              label: const Text('Unread only'),
              selected: unreadOnly,
              onSelected: notifier.setUnreadOnly,
            ),
            const SizedBox(width: AppDimens.space8),
            ChoiceChip(
              label: const Text('All types'),
              selected: type == null,
              onSelected: (_) => notifier.setType(null),
            ),
            // Only the customer-facing half of the enum is offered; the admin
            // types are never delivered to this audience, so filtering by one
            // would always return nothing.
            for (final option in NotificationType.customerFacing) ...[
              const SizedBox(width: AppDimens.space8),
              ChoiceChip(
                label: Text(option.label),
                selected: type == option,
                onSelected: (selected) =>
                    notifier.setType(selected ? option : null),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox({required this.unreadOnly, required this.hasType});

  final bool unreadOnly;
  final bool hasType;

  @override
  Widget build(BuildContext context) => EmptyView(
        title: unreadOnly ? 'Nothing unread' : 'No notifications',
        message: hasType || unreadOnly
            ? 'Try widening the filters above.'
            : 'Order updates and delivery news will appear here.',
        icon: Icons.notifications_none,
      );
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) => Container(
        color: context.palette.dangerSubtle,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.pageGutter),
        child: Icon(Icons.delete_outline, color: context.palette.danger),
      );
}
