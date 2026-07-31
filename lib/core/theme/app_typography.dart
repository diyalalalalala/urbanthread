import 'package:flutter/material.dart';

abstract final class AppTypography {
  const AppTypography._();

  static const sans = 'Inter';
  static const display = 'PlayfairDisplay';

  static const TextStyle eyebrow = TextStyle(
    fontFamily: sans,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.32,
    height: 1,
  );

  static const TextStyle wordmark = TextStyle(
    fontFamily: display,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: 6,
  );

  static const TextStyle button = TextStyle(
    fontFamily: sans,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.04,
  );

  static const TextStyle price = TextStyle(
    fontFamily: display,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static TextTheme textTheme(Color ink, Color inkMuted) => TextTheme(
        displayLarge: TextStyle(
          fontFamily: display,
          fontSize: 44,
          fontWeight: FontWeight.w500,
          height: 1.05,
          color: ink,
        ),
        displayMedium: TextStyle(
          fontFamily: display,
          fontSize: 36,
          fontWeight: FontWeight.w500,
          height: 1.08,
          color: ink,
        ),
        displaySmall: TextStyle(
          fontFamily: display,
          fontSize: 30,
          fontWeight: FontWeight.w500,
          height: 1.1,
          color: ink,
        ),
        headlineLarge: TextStyle(
          fontFamily: display,
          fontSize: 26,
          fontWeight: FontWeight.w500,
          height: 1.15,
          color: ink,
        ),
        headlineMedium: TextStyle(
          fontFamily: display,
          fontSize: 22,
          fontWeight: FontWeight.w500,
          height: 1.2,
          color: ink,
        ),
        headlineSmall: TextStyle(
          fontFamily: display,
          fontSize: 19,
          fontWeight: FontWeight.w500,
          height: 1.25,
          color: ink,
        ),

        titleLarge: TextStyle(
          fontFamily: sans,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: ink,
        ),
        titleMedium: TextStyle(
          fontFamily: sans,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          height: 1.35,
          color: ink,
        ),
        titleSmall: TextStyle(
          fontFamily: sans,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: ink,
        ),
        bodyLarge: TextStyle(
          fontFamily: sans,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.55,
          color: ink,
        ),
        bodyMedium: TextStyle(
          fontFamily: sans,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.55,
          color: ink,
        ),
        bodySmall: TextStyle(
          fontFamily: sans,
          fontSize: 12.5,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: inkMuted,
        ),
        labelLarge: button.copyWith(color: ink),
        labelMedium: TextStyle(
          fontFamily: sans,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: inkMuted,
        ),
        labelSmall: eyebrow.copyWith(color: inkMuted),
      );
}
