import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasource/notification_local_datasource.dart';
import '../datasource/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl({
    required NotificationRemoteDataSource remote,
    required NotificationLocalDataSource local,
    required NetworkInfo networkInfo,
  })  : _remote = remote,
        _local = local,
        _networkInfo = networkInfo;

  final NotificationRemoteDataSource _remote;
  final NotificationLocalDataSource _local;
  final NetworkInfo _networkInfo;

  @override
  List<AppNotification> get cachedNotifications {
    try {
      return _local
          .readNotifications()
          .map((model) => model.toEntity())
          .toList(growable: false);
    } on Object {
      return const [];
    }
  }

  @override
  Future<Result<Paginated<AppNotification>>> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
    NotificationType? type,
  }) async {
    if (!await _networkInfo.isConnected) return _cachedPage(page);

    try {
      final envelope = await _remote.getNotifications(
        page: page,
        limit: limit,
        // Omitted when false: the backend only narrows on a truthy value, and
        // sending `unread=false` would read as "give me the read ones", which
        // it does not do.
        unread: unreadOnly ? true : null,
        type: type == null || type == NotificationType.unknown
            ? null
            : type.wireValue,
      );

      final models = envelope.data;

      // Only the plain first page is worth caching — a filtered or deep page
      // is not what the screen opens on.
      if (page == 1 && !unreadOnly && type == null) {
        await _local.writeNotifications(models);
      }

      final meta = envelope.meta;
      final items =
          models.map((model) => model.toEntity()).toList(growable: false);

      return Result.success(
        meta == null
            ? Paginated<AppNotification>.single(items)
            : Paginated<AppNotification>(
                items: items,
                page: meta.page,
                totalPages: meta.totalPages,
                total: meta.total,
                hasNextPage: meta.hasNextPage,
              ),
      );
    } on Object catch (error) {
      final failure = ErrorMapper.toFailure(error);
      if (failure is NetworkFailure || failure is TimeoutFailure) {
        final cached = _cachedPage(page);
        if (cached.isSuccess) return cached;
      }
      return Result.failure(failure);
    }
  }

  /// The offline read path. Deep pages have nothing cached, so asking for one
  /// while offline is an empty cache rather than a silent first page.
  Result<Paginated<AppNotification>> _cachedPage(int page) {
    if (page > 1) return const Result.failure(EmptyCacheFailure());
    final cached = cachedNotifications;
    return cached.isEmpty
        ? const Result.failure(EmptyCacheFailure())
        : Result.success(Paginated<AppNotification>.single(cached));
  }

  @override
  Future<Result<int>> getUnreadCount() async {
    try {
      final envelope = await _remote.getUnreadCount();
      final count = envelope.data.unread;
      await _local.writeUnreadCount(count);
      return Result.success(count);
    } on Object catch (error) {
      final failure = ErrorMapper.toFailure(error);
      if (failure is NetworkFailure || failure is TimeoutFailure) {
        final cached = _local.readUnreadCount();
        if (cached != null) return Result.success(cached);
      }
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<AppNotification>> markAsRead(String id) async {
    try {
      final envelope = await _remote.markAsRead(id);
      final updated = envelope.data;

      // Swap the one row in the cached page, leaving the rest and its order
      // untouched.
      final current = _local.readNotifications();
      if (current.isNotEmpty) {
        await _local.writeNotifications(
          current
              .map((model) => model.id == id ? updated : model)
              .toList(growable: false),
        );
      }

      return Result.success(updated.toEntity());
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  @override
  Future<Result<int>> markAllAsRead() async {
    try {
      final envelope = await _remote.markAllAsRead();
      await _local.writeNotifications(
        _local
            .readNotifications()
            .map(
              (model) => model.copyWith(
                isRead: true,
                readAt: model.readAt ?? DateTime.now().toIso8601String(),
              ),
            )
            .toList(growable: false),
      );
      await _local.writeUnreadCount(0);
      return Result.success(envelope.data.updated);
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  @override
  Future<Result<void>> deleteNotification(String id) async {
    try {
      // 204, no body.
      await _remote.deleteNotification(id);
      await _local.writeNotifications(
        _local
            .readNotifications()
            .where((model) => model.id != id)
            .toList(growable: false),
      );
      return const Result.success(null);
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  @override
  Future<Result<int>> deleteReadNotifications() async {
    try {
      // 200 with `{ deleted }` — not a 204.
      final envelope = await _remote.deleteRead();
      await _local.writeNotifications(
        _local
            .readNotifications()
            .where((model) => !model.isRead)
            .toList(growable: false),
      );
      return Result.success(envelope.data.deleted);
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }
}
