import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../entities/app_notification.dart';

abstract interface class NotificationRepository {
  /// `GET /notifications`, newest first. Only rows with
  /// `audience: "user"` belonging to the caller are returned.
  ///
  /// [unreadOnly] maps to the `unread` param, which **only narrows when
  /// truthy** — sending `false` is the same as omitting it, so there is no way
  /// to ask for read-only rows.
  Future<Result<Paginated<AppNotification>>> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
    NotificationType? type,
  });

  /// `GET /notifications/unread-count` → `{ unread }`.
  Future<Result<int>> getUnreadCount();

  /// `PATCH /notifications/{id}/read`.
  Future<Result<AppNotification>> markAsRead(String id);

  /// `PATCH /notifications/read-all` → `{ updated }`, the number changed.
  Future<Result<int>> markAllAsRead();

  /// `DELETE /notifications/{id}` — 204, no body.
  Future<Result<void>> deleteNotification(String id);

  /// `DELETE /notifications/read` → **200 with `{ deleted }`**, unlike the
  /// single delete above. The asymmetry is the backend's, not a typo.
  Future<Result<int>> deleteReadNotifications();

  /// The last list written to the cache, for read-only offline viewing.
  List<AppNotification> get cachedNotifications;
}
