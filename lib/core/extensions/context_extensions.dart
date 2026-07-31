import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get text => Theme.of(this).textTheme;

  ColorScheme get colors => Theme.of(this).colorScheme;

  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

extension MediaQueryContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);

  double get screenWidth => MediaQuery.sizeOf(this).width;

  double get screenHeight => MediaQuery.sizeOf(this).height;

  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);

  double get keyboardInset => MediaQuery.viewInsetsOf(this).bottom;

  bool get isKeyboardVisible => MediaQuery.viewInsetsOf(this).bottom > 0;

  bool get isCompact => MediaQuery.sizeOf(this).width < 600;

  int get productGridColumns {
    final width = MediaQuery.sizeOf(this).width;
    if (width >= 1000) return 4;
    if (width >= 600) return 3;
    return 2;
  }
}

extension MessengerContext on BuildContext {
  void showSnack(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(this)..hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? palette.danger : palette.ink,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
