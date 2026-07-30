// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_lifecycle_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the app is in front of the user right now.
///
/// This exists so that anything expensive to keep running — a sensor
/// subscription, a poll — can be expressed as `if (!foreground) return`
/// inside a provider, and released declaratively when the app is backgrounded
/// instead of every consumer having to observe the lifecycle itself.
///
/// Kept alive: it is a property of the process, and re-attaching an
/// [AppLifecycleListener] whenever the last watcher went away would risk
/// missing the transition it exists to report.
///
/// The class carries no `Notifier` suffix, so the generator emits exactly
/// `isAppForegroundProvider`.

@ProviderFor(IsAppForeground)
final isAppForegroundProvider = IsAppForegroundProvider._();

/// Whether the app is in front of the user right now.
///
/// This exists so that anything expensive to keep running — a sensor
/// subscription, a poll — can be expressed as `if (!foreground) return`
/// inside a provider, and released declaratively when the app is backgrounded
/// instead of every consumer having to observe the lifecycle itself.
///
/// Kept alive: it is a property of the process, and re-attaching an
/// [AppLifecycleListener] whenever the last watcher went away would risk
/// missing the transition it exists to report.
///
/// The class carries no `Notifier` suffix, so the generator emits exactly
/// `isAppForegroundProvider`.
final class IsAppForegroundProvider
    extends $NotifierProvider<IsAppForeground, bool> {
  /// Whether the app is in front of the user right now.
  ///
  /// This exists so that anything expensive to keep running — a sensor
  /// subscription, a poll — can be expressed as `if (!foreground) return`
  /// inside a provider, and released declaratively when the app is backgrounded
  /// instead of every consumer having to observe the lifecycle itself.
  ///
  /// Kept alive: it is a property of the process, and re-attaching an
  /// [AppLifecycleListener] whenever the last watcher went away would risk
  /// missing the transition it exists to report.
  ///
  /// The class carries no `Notifier` suffix, so the generator emits exactly
  /// `isAppForegroundProvider`.
  IsAppForegroundProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAppForegroundProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAppForegroundHash();

  @$internal
  @override
  IsAppForeground create() => IsAppForeground();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAppForegroundHash() => r'fcf5dc918b4ed62b0ea8af6cc75899991d772199';

/// Whether the app is in front of the user right now.
///
/// This exists so that anything expensive to keep running — a sensor
/// subscription, a poll — can be expressed as `if (!foreground) return`
/// inside a provider, and released declaratively when the app is backgrounded
/// instead of every consumer having to observe the lifecycle itself.
///
/// Kept alive: it is a property of the process, and re-attaching an
/// [AppLifecycleListener] whenever the last watcher went away would risk
/// missing the transition it exists to report.
///
/// The class carries no `Notifier` suffix, so the generator emits exactly
/// `isAppForegroundProvider`.

abstract class _$IsAppForeground extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
