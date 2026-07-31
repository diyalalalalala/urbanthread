import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../entities/app_notification.dart';

abstract interface class NotificationRepository {
  Future<Result<Paginated<AppNotification>>> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
    NotificationType? type,
  });

  Future<Result<int>> getUnreadCount();

  Future<Result<AppNotification>> markAsRead(String id);

  Future<Result<int>> markAllAsRead();

  Future<Result<void>> deleteNotification(String id);

  Future<Result<int>> deleteReadNotifications();

  List<AppNotification> get cachedNotifications;
}
