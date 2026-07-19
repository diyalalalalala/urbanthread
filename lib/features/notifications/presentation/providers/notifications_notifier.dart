import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/usecases/notification_usecases.dart';
import 'notification_providers.dart';
import 'unread_notification_count.dart';

part 'notifications_notifier.g.dart';

/// The notification list, its filters and its paging cursor.
class NotificationsState extends Equatable {
  const NotificationsState({
    required this.notifications,
    this.unreadOnly = false,
    this.type,
    this.isLoadingMore = false,
    this.loadMoreFailure,
  });

  final Paginated<AppNotification> notifications;

  /// Maps to the `unread` query param, which only narrows when truthy.
  final bool unreadOnly;

  /// Null means "every type".
  final NotificationType? type;

  final bool isLoadingMore;
  final Failure? loadMoreFailure;

  bool get canLoadMore => notifications.hasNextPage && !isLoadingMore;

  bool get hasUnread =>
      notifications.items.any((notification) => !notification.isRead);

  NotificationsState copyWith({
    Paginated<AppNotification>? notifications,
    bool? unreadOnly,
    NotificationType? type,
    bool clearType = false,
    bool? isLoadingMore,
    Failure? loadMoreFailure,
    bool clearLoadMoreFailure = false,
  }) =>
      NotificationsState(
        notifications: notifications ?? this.notifications,
        unreadOnly: unreadOnly ?? this.unreadOnly,
        type: clearType ? null : (type ?? this.type),
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        loadMoreFailure: clearLoadMoreFailure
            ? null
            : (loadMoreFailure ?? this.loadMoreFailure),
      );

  @override
  List<Object?> get props =>
      [notifications, unreadOnly, type, isLoadingMore, loadMoreFailure];
}

@riverpod
class NotificationsNotifier extends _$NotificationsNotifier {
  static const _pageSize = 20;

  bool _unreadOnly = false;
  NotificationType? _type;

  @override
  Future<NotificationsState> build() async => NotificationsState(
        notifications: await _fetch(1),
        unreadOnly: _unreadOnly,
        type: _type,
      );

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () async => NotificationsState(
        notifications: await _fetch(1),
        unreadOnly: _unreadOnly,
        type: _type,
      ),
    );
    // The list and the badge are read from different endpoints, so a pull to
    // refresh has to resync both or they drift.
    await ref.read(unreadNotificationCountProvider.notifier).refresh();
  }

  /// Switches between "all" and "unread only" and reloads from page one.
  Future<void> setUnreadOnly(bool value) async {
    if (_unreadOnly == value) return;
    _unreadOnly = value;
    await _reload();
  }

  /// Filters by [type], or clears the filter when null.
  Future<void> setType(NotificationType? type) async {
    if (_type == type) return;
    _type = type;
    await _reload();
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.canLoadMore) return;

    state = AsyncData(
      current.copyWith(isLoadingMore: true, clearLoadMoreFailure: true),
    );

    final result = await ref.read(getNotificationsUseCaseProvider)(
      NotificationQuery(
        page: current.notifications.page + 1,
        limit: _pageSize,
        unreadOnly: _unreadOnly,
        type: _type,
      ),
    );

    state = AsyncData(
      result.fold(
        onSuccess: (next) => current.copyWith(
          notifications: current.notifications.append(next),
          isLoadingMore: false,
        ),
        onFailure: (failure) =>
            current.copyWith(isLoadingMore: false, loadMoreFailure: failure),
      ),
    );
  }

  /// Marks one row read and adopts the server's version of it.
  ///
  /// While "unread only" is active the row no longer belongs in the list, so
  /// it is dropped rather than left behind as a contradiction.
  Future<Failure?> markAsRead(String id) async {
    final current = state.value;
    if (current == null) return null;

    final target = _find(current, id);
    if (target != null && target.isRead) return null;

    final result = await ref.read(markNotificationReadUseCaseProvider)(id);

    return result.fold(
      onSuccess: (updated) {
        final items = _unreadOnly
            ? current.notifications.items
                .where((notification) => notification.id != id)
                .toList(growable: false)
            : current.notifications.items
                .map(
                  (notification) =>
                      notification.id == id ? updated : notification,
                )
                .toList(growable: false);

        state = AsyncData(
          current.copyWith(notifications: _withItems(current, items)),
        );
        ref.read(unreadNotificationCountProvider.notifier).decrement();
        return null;
      },
      onFailure: (failure) => failure,
    );
  }

  /// `PATCH /notifications/read-all`. Returns how many rows changed, or the
  /// failure.
  Future<Result<int>> markAllAsRead() async {
    final result = await ref.read(markAllNotificationsReadUseCaseProvider)(
      const NoParams(),
    );

    if (result case Success(:final value)) {
      final current = state.value;
      if (current != null) {
        // Under "unread only" the whole page has just stopped matching the
        // filter, so it empties instead of showing rows marked read.
        final items = _unreadOnly
            ? const <AppNotification>[]
            : current.notifications.items
                .map(
                  (notification) => notification.copyWith(
                    isRead: true,
                    readAt: notification.readAt ?? DateTime.now(),
                  ),
                )
                .toList(growable: false);

        state = AsyncData(
          current.copyWith(notifications: _withItems(current, items)),
        );
      }
      ref.read(unreadNotificationCountProvider.notifier).setCount(0);
      return Result.success(value);
    }

    return result;
  }

  /// Deletes one row — 204, no body, so the list is trimmed locally.
  Future<Failure?> delete(String id) async {
    final current = state.value;
    final wasUnread = current == null || (_find(current, id)?.isRead == false);

    final result = await ref.read(deleteNotificationUseCaseProvider)(id);

    return result.fold(
      onSuccess: (_) {
        if (current != null) {
          final items = current.notifications.items
              .where((notification) => notification.id != id)
              .toList(growable: false);
          state = AsyncData(
            current.copyWith(
              notifications: _withItems(current, items, deltaTotal: -1),
            ),
          );
        }
        // Deleting an unread row lowers the badge; deleting a read one does
        // not.
        if (wasUnread) {
          ref.read(unreadNotificationCountProvider.notifier).decrement();
        }
        return null;
      },
      onFailure: (failure) => failure,
    );
  }

  /// `DELETE /notifications/read` — answers **200 with `{deleted}`**, unlike
  /// the single delete. Returns the count, or the failure.
  Future<Result<int>> deleteRead() async {
    final result = await ref.read(deleteReadNotificationsUseCaseProvider)(
      const NoParams(),
    );

    if (result case Success()) {
      final current = state.value;
      if (current != null) {
        final items = current.notifications.items
            .where((notification) => !notification.isRead)
            .toList(growable: false);
        state = AsyncData(
          current.copyWith(
            notifications: _withItems(
              current,
              items,
              deltaTotal: items.length - current.notifications.items.length,
            ),
          ),
        );
      }
    }

    return result;
  }

  Future<void> _reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => NotificationsState(
        notifications: await _fetch(1),
        unreadOnly: _unreadOnly,
        type: _type,
      ),
    );
  }

  AppNotification? _find(NotificationsState state, String id) {
    for (final notification in state.notifications.items) {
      if (notification.id == id) return notification;
    }
    return null;
  }

  /// Rebuilds the page around a new item list, preserving the paging cursor
  /// so an in-place edit does not look like a fresh first page.
  Paginated<AppNotification> _withItems(
    NotificationsState current,
    List<AppNotification> items, {
    int deltaTotal = 0,
  }) =>
      Paginated<AppNotification>(
        items: items,
        page: current.notifications.page,
        totalPages: current.notifications.totalPages,
        total: (current.notifications.total + deltaTotal).clamp(0, 1 << 31),
        hasNextPage: current.notifications.hasNextPage,
      );

  Future<Paginated<AppNotification>> _fetch(int page) async {
    final result = await ref.read(getNotificationsUseCaseProvider)(
      NotificationQuery(
        page: page,
        limit: _pageSize,
        unreadOnly: _unreadOnly,
        type: _type,
      ),
    );
    return switch (result) {
      Success(:final value) => value,
      FailureResult(:final failure) => throw failure,
    };
  }
}
