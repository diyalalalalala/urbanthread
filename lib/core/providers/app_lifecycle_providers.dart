import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_lifecycle_providers.g.dart';

@Riverpod(keepAlive: true)
class IsAppForeground extends _$IsAppForeground {
  @override
  bool build() {
    final listener = AppLifecycleListener(
      onStateChange: (lifecycle) =>
          state = lifecycle == AppLifecycleState.resumed,
    );
    ref.onDispose(listener.dispose);

    final current = WidgetsBinding.instance.lifecycleState;
    return current == null || current == AppLifecycleState.resumed;
  }
}
