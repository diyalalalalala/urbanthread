import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

extension NavigationContext on BuildContext {
  void popOrGo(String fallback) {
    if (canPop()) {
      pop();
    } else {
      go(fallback);
    }
  }

  void goHome() => go(AppRoutes.home);
}
