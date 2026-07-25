import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

/// Navigation shorthands that encode this app's two stack rules.
///
/// 1. Anything reached by tapping *into* content is pushed, so the shell (and
///    with it the bottom bar's state) stays underneath and back returns to it.
/// 2. Anything that ends a flow — signing in, placing an order — replaces,
///    because the screen behind it is no longer somewhere the user can go.
///
/// The one case that needs a helper is a screen that can be arrived at both
/// ways: a pushed screen pops, a deep-linked one has nothing to pop to.
extension NavigationContext on BuildContext {
  /// Pops if there is something below, otherwise lands on [fallback].
  ///
  /// Without the fallback a deep link straight into, say, checkout leaves its
  /// "back to basket" button inert — `pop` on the only route in the stack is a
  /// no-op in release and an assertion in debug.
  void popOrGo(String fallback) {
    if (canPop()) {
      pop();
    } else {
      go(fallback);
    }
  }

  /// Leaves the current screen for the shell, discarding the stack above it.
  ///
  /// For the exits that must not be undoable — the sign-in screen a guest
  /// dismisses, the confirmation of a placed order.
  void goHome() => go(AppRoutes.home);
}
