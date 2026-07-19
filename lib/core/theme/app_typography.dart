import 'package:flutter/material.dart';

/// Type scale, ported from the web client.
///
/// Two families with a strict division of labour, which is what gives the
/// brand its editorial feel: Playfair Display sets headings and prices,
/// Inter does everything else. Both are bundled rather than fetched at
/// runtime — this app has to render correctly offline, and a font that
/// arrives on second launch would reflow the catalogue under the user.
abstract final class AppTypography {
  const AppTypography._();

  static const sans = 'Inter';
  static const display = 'PlayfairDisplay';

  /// The retail-nav signature: tiny, spaced, uppercase. Used for section
  /// eyebrows, badges and button labels.
  static const TextStyle eyebrow = TextStyle(
    fontFamily: sans,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.32, // 0.12em at 11px
    height: 1,
  );

  /// Wordmark treatment — heavy tracking, uppercase Playfair.
  static const TextStyle wordmark = TextStyle(
    fontFamily: display,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: 6, // 0.3em at 20px
  );

  /// Button labels: uppercase with 0.08em tracking, per the web `Button`.
  static const TextStyle button = TextStyle(
    fontFamily: sans,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.04,
  );

  /// Prices use display type with tabular figures so digits stay aligned
  /// down a column of cart rows.
  static const TextStyle price = TextStyle(
    fontFamily: display,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static TextTheme textTheme(Color ink, Color inkMuted) => TextTheme(
        // Display + headline are Playfair — headings only.
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

        // Title downwards is Inter — UI, not editorial.
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
