// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationRemoteDataSource)
final notificationRemoteDataSourceProvider =
    NotificationRemoteDataSourceProvider._();

final class NotificationRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          NotificationRemoteDataSource,
          NotificationRemoteDataSource,
          NotificationRemoteDataSource
        >
    with $Provider<NotificationRemoteDataSource> {
  NotificationRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<NotificationRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationRemoteDataSource create(Ref ref) {
    return notificationRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationRemoteDataSource>(value),
    );
  }
}

String _$notificationRemoteDataSourceHash() =>
    r'e42561922f809955ad55d1fdbdcaee7479c78aca';

@ProviderFor(notificationLocalDataSource)
final notificationLocalDataSourceProvider =
    NotificationLocalDataSourceProvider._();

final class NotificationLocalDataSourceProvider
    extends
        $FunctionalProvider<
          NotificationLocalDataSource,
          NotificationLocalDataSource,
          NotificationLocalDataSource
        >
    with $Provider<NotificationLocalDataSource> {
  NotificationLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<NotificationLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationLocalDataSource create(Ref ref) {
    return notificationLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationLocalDataSource>(value),
    );
  }
}

String _$notificationLocalDataSourceHash() =>
    r'adffe51dec51e67a4b63a2dd8d6038f157fe2919';

@ProviderFor(notificationRepository)
final notificationRepositoryProvider = NotificationRepositoryProvider._();

final class NotificationRepositoryProvider
    extends
        $FunctionalProvider<
          NotificationRepository,
          NotificationRepository,
          NotificationRepository
        >
    with $Provider<NotificationRepository> {
  NotificationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotificationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationRepository create(Ref ref) {
    return notificationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationRepository>(value),
    );
  }
}

String _$notificationRepositoryHash() =>
    r'd4b0b415ecdd5fe26968dbf37f03a760a9239208';

/// Kept alive alongside the badge that consumes it — a use case rebuilt on
/// every app-bar frame would churn for no benefit.

@ProviderFor(getUnreadCountUseCase)
final getUnreadCountUseCaseProvider = GetUnreadCountUseCaseProvider._();

/// Kept alive alongside the badge that consumes it — a use case rebuilt on
/// every app-bar frame would churn for no benefit.

final class GetUnreadCountUseCaseProvider
    extends
        $FunctionalProvider<
          GetUnreadCountUseCase,
          GetUnreadCountUseCase,
          GetUnreadCountUseCase
        >
    with $Provider<GetUnreadCountUseCase> {
  /// Kept alive alongside the badge that consumes it — a use case rebuilt on
  /// every app-bar frame would churn for no benefit.
  GetUnreadCountUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getUnreadCountUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getUnreadCountUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetUnreadCountUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetUnreadCountUseCase create(Ref ref) {
    return getUnreadCountUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetUnreadCountUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetUnreadCountUseCase>(value),
    );
  }
}

String _$getUnreadCountUseCaseHash() =>
    r'c2dcf06c500e91de88775c7ff81dbdc5d2d7b1de';

@ProviderFor(getNotificationsUseCase)
final getNotificationsUseCaseProvider = GetNotificationsUseCaseProvider._();

final class GetNotificationsUseCaseProvider
    extends
        $FunctionalProvider<
          GetNotificationsUseCase,
          GetNotificationsUseCase,
          GetNotificationsUseCase
        >
    with $Provider<GetNotificationsUseCase> {
  GetNotificationsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getNotificationsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getNotificationsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetNotificationsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetNotificationsUseCase create(Ref ref) {
    return getNotificationsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetNotificationsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetNotificationsUseCase>(value),
    );
  }
}

String _$getNotificationsUseCaseHash() =>
    r'dbc70a32c8e6362c97096f3d003f6ac8fd549bb7';

@ProviderFor(markNotificationReadUseCase)
final markNotificationReadUseCaseProvider =
    MarkNotificationReadUseCaseProvider._();

final class MarkNotificationReadUseCaseProvider
    extends
        $FunctionalProvider<
          MarkNotificationReadUseCase,
          MarkNotificationReadUseCase,
          MarkNotificationReadUseCase
        >
    with $Provider<MarkNotificationReadUseCase> {
  MarkNotificationReadUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'markNotificationReadUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$markNotificationReadUseCaseHash();

  @$internal
  @override
  $ProviderElement<MarkNotificationReadUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MarkNotificationReadUseCase create(Ref ref) {
    return markNotificationReadUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MarkNotificationReadUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MarkNotificationReadUseCase>(value),
    );
  }
}

String _$markNotificationReadUseCaseHash() =>
    r'39d61a17efb0fc2d355073ce8a0e398ff35f5141';

@ProviderFor(markAllNotificationsReadUseCase)
final markAllNotificationsReadUseCaseProvider =
    MarkAllNotificationsReadUseCaseProvider._();

final class MarkAllNotificationsReadUseCaseProvider
    extends
        $FunctionalProvider<
          MarkAllNotificationsReadUseCase,
          MarkAllNotificationsReadUseCase,
          MarkAllNotificationsReadUseCase
        >
    with $Provider<MarkAllNotificationsReadUseCase> {
  MarkAllNotificationsReadUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'markAllNotificationsReadUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$markAllNotificationsReadUseCaseHash();

  @$internal
  @override
  $ProviderElement<MarkAllNotificationsReadUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MarkAllNotificationsReadUseCase create(Ref ref) {
    return markAllNotificationsReadUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MarkAllNotificationsReadUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MarkAllNotificationsReadUseCase>(
        value,
      ),
    );
  }
}

String _$markAllNotificationsReadUseCaseHash() =>
    r'05a2b7501229b8b235d47c76a064ab0d2e9b7dbc';

@ProviderFor(deleteNotificationUseCase)
final deleteNotificationUseCaseProvider = DeleteNotificationUseCaseProvider._();

final class DeleteNotificationUseCaseProvider
    extends
        $FunctionalProvider<
          DeleteNotificationUseCase,
          DeleteNotificationUseCase,
          DeleteNotificationUseCase
        >
    with $Provider<DeleteNotificationUseCase> {
  DeleteNotificationUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteNotificationUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteNotificationUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteNotificationUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteNotificationUseCase create(Ref ref) {
    return deleteNotificationUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteNotificationUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteNotificationUseCase>(value),
    );
  }
}

String _$deleteNotificationUseCaseHash() =>
    r'17c41db65f0705cb2f72b1a7965a5e9d4913ddfd';

@ProviderFor(deleteReadNotificationsUseCase)
final deleteReadNotificationsUseCaseProvider =
    DeleteReadNotificationsUseCaseProvider._();

final class DeleteReadNotificationsUseCaseProvider
    extends
        $FunctionalProvider<
          DeleteReadNotificationsUseCase,
          DeleteReadNotificationsUseCase,
          DeleteReadNotificationsUseCase
        >
    with $Provider<DeleteReadNotificationsUseCase> {
  DeleteReadNotificationsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteReadNotificationsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteReadNotificationsUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteReadNotificationsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteReadNotificationsUseCase create(Ref ref) {
    return deleteReadNotificationsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteReadNotificationsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteReadNotificationsUseCase>(
        value,
      ),
    );
  }
}

String _$deleteReadNotificationsUseCaseHash() =>
    r'3e3b765f535c51afcf0080c739598188bcd70ce1';
