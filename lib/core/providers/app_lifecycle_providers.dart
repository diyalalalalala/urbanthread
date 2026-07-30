import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_lifecycle_providers.g.dart';

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
@Riverpod(keepAlive: true)
class IsAppForeground extends _$IsAppForeground {
  @override
  bool build() {
    final listener = AppLifecycleListener(
      onStateChange: (lifecycle) =>
          state = lifecycle == AppLifecycleState.resumed,
    );
    ref.onDispose(listener.dispose);

    // Null until the platform sends its first lifecycle message, which is the
    // normal state during launch. Assume foreground — the alternative is a
    // first frame that behaves as though the app were hidden.
    final current = WidgetsBinding.instance.lifecycleState;
    return current == null || current == AppLifecycleState.resumed;
  }
}
