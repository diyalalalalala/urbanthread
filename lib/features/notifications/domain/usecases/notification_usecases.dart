import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/app_notification.dart';
import '../repositories/notification_repository.dart';

class NotificationQuery {
  const NotificationQuery({
    this.page = 1,
    this.limit = 20,
    this.unreadOnly = false,
    this.type,
  });

  final int page;
  final int limit;
  final bool unreadOnly;
  final NotificationType? type;
}

class GetNotificationsUseCase
    extends UseCase<Paginated<AppNotification>, NotificationQuery> {
  const GetNotificationsUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Result<Paginated<AppNotification>>> call(NotificationQuery params) =>
      _repository.getNotifications(
        page: params.page,
        limit: params.limit,
        unreadOnly: params.unreadOnly,
        type: params.type,
      );
}

class GetUnreadCountUseCase extends UseCase<int, NoParams> {
  const GetUnreadCountUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Result<int>> call(NoParams params) => _repository.getUnreadCount();
}

class MarkNotificationReadUseCase extends UseCase<AppNotification, String> {
  const MarkNotificationReadUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Result<AppNotification>> call(String id) => _repository.markAsRead(id);
}

/// Returns how many rows the server actually changed.
class MarkAllNotificationsReadUseCase extends UseCase<int, NoParams> {
  const MarkAllNotificationsReadUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Result<int>> call(NoParams params) => _repository.markAllAsRead();
}

class DeleteNotificationUseCase extends UseCase<void, String> {
  const DeleteNotificationUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Result<void>> call(String id) => _repository.deleteNotification(id);
}

/// Returns how many read rows were removed.
class DeleteReadNotificationsUseCase extends UseCase<int, NoParams> {
  const DeleteReadNotificationsUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Result<int>> call(NoParams params) =>
      _repository.deleteReadNotifications();
}
