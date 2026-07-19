// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unread_notification_count.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The number behind the app-bar bell badge.
///
/// Kept alive because it is read from the persistent app shell: letting it
/// dispose would re-fetch the count every time the last screen showing a badge
/// was popped. The class is named without a `Notifier` suffix on purpose —
/// the generator strips that suffix, and `unreadNotificationCountProvider` is
/// the name the shell expects.
///
/// Anything that changes read state must call [refresh] (or [setCount] when
/// the server already told it the new value), because there is no push
/// channel — the count only moves when the app asks.

@ProviderFor(UnreadNotificationCount)
final unreadNotificationCountProvider = UnreadNotificationCountProvider._();

/// The number behind the app-bar bell badge.
///
/// Kept alive because it is read from the persistent app shell: letting it
/// dispose would re-fetch the count every time the last screen showing a badge
/// was popped. The class is named without a `Notifier` suffix on purpose —
/// the generator strips that suffix, and `unreadNotificationCountProvider` is
/// the name the shell expects.
///
/// Anything that changes read state must call [refresh] (or [setCount] when
/// the server already told it the new value), because there is no push
/// channel — the count only moves when the app asks.
final class UnreadNotificationCountProvider
    extends $AsyncNotifierProvider<UnreadNotificationCount, int> {
  /// The number behind the app-bar bell badge.
  ///
  /// Kept alive because it is read from the persistent app shell: letting it
  /// dispose would re-fetch the count every time the last screen showing a badge
  /// was popped. The class is named without a `Notifier` suffix on purpose —
  /// the generator strips that suffix, and `unreadNotificationCountProvider` is
  /// the name the shell expects.
  ///
  /// Anything that changes read state must call [refresh] (or [setCount] when
  /// the server already told it the new value), because there is no push
  /// channel — the count only moves when the app asks.
  UnreadNotificationCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadNotificationCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadNotificationCountHash();

  @$internal
  @override
  UnreadNotificationCount create() => UnreadNotificationCount();
}

String _$unreadNotificationCountHash() =>
    r'4c40231344b04feada83d793732b5a1bc091d97d';

/// The number behind the app-bar bell badge.
///
/// Kept alive because it is read from the persistent app shell: letting it
/// dispose would re-fetch the count every time the last screen showing a badge
/// was popped. The class is named without a `Notifier` suffix on purpose —
/// the generator strips that suffix, and `unreadNotificationCountProvider` is
/// the name the shell expects.
///
/// Anything that changes read state must call [refresh] (or [setCount] when
/// the server already told it the new value), because there is no push
/// channel — the count only moves when the app asks.

abstract class _$UnreadNotificationCount extends $AsyncNotifier<int> {
  FutureOr<int> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
