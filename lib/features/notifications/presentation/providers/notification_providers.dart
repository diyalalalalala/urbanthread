import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasource/notification_local_datasource.dart';
import '../../data/datasource/notification_remote_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/notification_usecases.dart';

part 'notification_providers.g.dart';

@Riverpod(keepAlive: true)
NotificationRemoteDataSource notificationRemoteDataSource(Ref ref) =>
    NotificationRemoteDataSource(ref.watch(dioProvider));

@Riverpod(keepAlive: true)
NotificationLocalDataSource notificationLocalDataSource(Ref ref) =>
    NotificationLocalDataSource(ref.watch(accountCacheProvider));

@Riverpod(keepAlive: true)
NotificationRepository notificationRepository(Ref ref) =>
    NotificationRepositoryImpl(
      remote: ref.watch(notificationRemoteDataSourceProvider),
      local: ref.watch(notificationLocalDataSourceProvider),
      networkInfo: ref.watch(networkInfoProvider),
    );

/// Kept alive alongside the badge that consumes it — a use case rebuilt on
/// every app-bar frame would churn for no benefit.
@Riverpod(keepAlive: true)
GetUnreadCountUseCase getUnreadCountUseCase(Ref ref) =>
    GetUnreadCountUseCase(ref.watch(notificationRepositoryProvider));

@riverpod
GetNotificationsUseCase getNotificationsUseCase(Ref ref) =>
    GetNotificationsUseCase(ref.watch(notificationRepositoryProvider));

@riverpod
MarkNotificationReadUseCase markNotificationReadUseCase(Ref ref) =>
    MarkNotificationReadUseCase(ref.watch(notificationRepositoryProvider));

@riverpod
MarkAllNotificationsReadUseCase markAllNotificationsReadUseCase(Ref ref) =>
    MarkAllNotificationsReadUseCase(ref.watch(notificationRepositoryProvider));

@riverpod
DeleteNotificationUseCase deleteNotificationUseCase(Ref ref) =>
    DeleteNotificationUseCase(ref.watch(notificationRepositoryProvider));

@riverpod
DeleteReadNotificationsUseCase deleteReadNotificationsUseCase(Ref ref) =>
    DeleteReadNotificationsUseCase(ref.watch(notificationRepositoryProvider));
