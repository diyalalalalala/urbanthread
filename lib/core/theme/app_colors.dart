import 'package:flutter/material.dart';

/// Brand palette, ported 1:1 from the web client's design tokens
/// (`client/src/index.css`).
///
/// The web app authors these in oklch and exposes them as CSS variables; the
/// values below are their sRGB equivalents so the two clients stay visually
/// identical. Names are kept verbatim — `ink`, `canvas`, `line` — so a token
/// can be traced across both codebases without a translation table.
///
/// Only the handful of roles that map cleanly onto Material's [ColorScheme]
/// are wired into it; everything else is surfaced through [AppPalette], a
/// [ThemeExtension], because Material has no slot for "sunken surface" or
/// "eyebrow subtle" and forcing them into `surfaceContainerHighest`-style
/// slots loses the meaning.
abstract final class AppColors {
  const AppColors._();

  // ── Light ──────────────────────────────────────────────────────────────
  static const canvasLight = Color(0xFFFDFCF9);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceRaisedLight = Color(0xFFFBFAF7);
  static const surfaceSunkenLight = Color(0xFFF5F3F0);

  static const inkLight = Color(0xFF171310);
  static const inkMutedLight = Color(0xFF5C5754);
  static const inkSubtleLight = Color(0xFF898582);

  static const lineLight = Color(0xFFE0DDDA);
  static const lineStrongLight = Color(0xFFC7C3C0);

  static const accentLight = Color(0xFF993C25);
  static const accentHoverLight = Color(0xFF852A12);
  static const accentInkLight = Color(0xFFFDFCF9);
  static const accentSubtleLight = Color(0xFFFCEAE6);

  static const successLight = Color(0xFF187C49);
  static const successSubtleLight = Color(0xFFE0F5E6);
  static const warningLight = Color(0xFFC0851F);
  static const warningSubtleLight = Color(0xFFFFEFD5);
  static const dangerLight = Color(0xFFC22826);
  static const dangerSubtleLight = Color(0xFFFFE7E4);
  static const infoLight = Color(0xFF2579AB);
  static const infoSubtleLight = Color(0xFFDDF2FF);

  // ── Dark ───────────────────────────────────────────────────────────────
  static const canvasDark = Color(0xFF0F0D0B);
  static const surfaceDark = Color(0xFF161311);
  static const surfaceRaisedDark = Color(0xFF1F1C1A);
  static const surfaceSunkenDark = Color(0xFF0B0907);

  static const inkDark = Color(0xFFF0EEEB);
  static const inkMutedDark = Color(0xFFA7A4A0);
  static const inkSubtleDark = Color(0xFF777471);

  static const lineDark = Color(0xFF2E2B28);
  static const lineStrongDark = Color(0xFF46413E);

  static const accentDark = Color(0xFFD77C60);
  static const accentHoverDark = Color(0xFFEB8F72);
  static const accentInkDark = Color(0xFF0F0D0B);
  static const accentSubtleDark = Color(0xFF3E1F16);

  static const successDark = Color(0xFF51B67A);
  static const successSubtleDark = Color(0xFF0C2B19);
  static const warningDark = Color(0xFFE8AA4E);
  static const warningSubtleDark = Color(0xFF372508);
  static const dangerDark = Color(0xFFEA6B60);
  static const dangerSubtleDark = Color(0xFF421C18);
  static const infoDark = Color(0xFF58A7DC);
  static const infoSubtleDark = Color(0xFF08273A);
}

/// The brand tokens Material's [ColorScheme] has no room for.
///
/// Read it through [BuildContext.palette] rather than
/// `Theme.of(context).extension<AppPalette>()!` — the extension is registered
/// on both themes in `AppTheme`, so the bang is safe but noisy at call sites.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.canvas,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.ink,
    required this.inkMuted,
    required this.inkSubtle,
    required this.line,
    required this.lineStrong,
    required this.accent,
    required this.accentHover,
    required this.accentInk,
    required this.accentSubtle,
    required this.success,
    required this.successSubtle,
    required this.warning,
    required this.warningSubtle,
    required this.danger,
    required this.dangerSubtle,
    required this.info,
    required this.infoSubtle,
  });

  final Color canvas;
  final Color surface;
  final Color surfaceRaised;
  final Color surfaceSunken;

  final Color ink;
  final Color inkMuted;
  final Color inkSubtle;

  final Color line;
  final Color lineStrong;

  final Color accent;
  final Color accentHover;
  final Color accentInk;
  final Color accentSubtle;

  final Color success;
  final Color successSubtle;
  final Color warning;
  final Color warningSubtle;
  final Color danger;
  final Color dangerSubtle;
  final Color info;
  final Color infoSubtle;

  static const light = AppPalette(
    canvas: AppColors.canvasLight,
    surface: AppColors.surfaceLight,
    surfaceRaised: AppColors.surfaceRaisedLight,
    surfaceSunken: AppColors.surfaceSunkenLight,
    ink: AppColors.inkLight,
    inkMuted: AppColors.inkMutedLight,
    inkSubtle: AppColors.inkSubtleLight,
    line: AppColors.lineLight,
    lineStrong: AppColors.lineStrongLight,
    accent: AppColors.accentLight,
    accentHover: AppColors.accentHoverLight,
    accentInk: AppColors.accentInkLight,
    accentSubtle: AppColors.accentSubtleLight,
    success: AppColors.successLight,
    successSubtle: AppColors.successSubtleLight,
    warning: AppColors.warningLight,
    warningSubtle: AppColors.warningSubtleLight,
    danger: AppColors.dangerLight,
    dangerSubtle: AppColors.dangerSubtleLight,
    info: AppColors.infoLight,
    infoSubtle: AppColors.infoSubtleLight,
  );

  static const dark = AppPalette(
    canvas: AppColors.canvasDark,
    surface: AppColors.surfaceDark,
    surfaceRaised: AppColors.surfaceRaisedDark,
    surfaceSunken: AppColors.surfaceSunkenDark,
    ink: AppColors.inkDark,
    inkMuted: AppColors.inkMutedDark,
    inkSubtle: AppColors.inkSubtleDark,
    line: AppColors.lineDark,
    lineStrong: AppColors.lineStrongDark,
    accent: AppColors.accentDark,
    accentHover: AppColors.accentHoverDark,
    accentInk: AppColors.accentInkDark,
    accentSubtle: AppColors.accentSubtleDark,
    success: AppColors.successDark,
    successSubtle: AppColors.successSubtleDark,
    warning: AppColors.warningDark,
    warningSubtle: AppColors.warningSubtleDark,
    danger: AppColors.dangerDark,
    dangerSubtle: AppColors.dangerSubtleDark,
    info: AppColors.infoDark,
    infoSubtle: AppColors.infoSubtleDark,
  );

  @override
  AppPalette copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceRaised,
    Color? surfaceSunken,
    Color? ink,
    Color? inkMuted,
    Color? inkSubtle,
    Color? line,
    Color? lineStrong,
    Color? accent,
    Color? accentHover,
    Color? accentInk,
    Color? accentSubtle,
    Color? success,
    Color? successSubtle,
    Color? warning,
    Color? warningSubtle,
    Color? danger,
    Color? dangerSubtle,
    Color? info,
    Color? infoSubtle,
  }) {
    return AppPalette(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      inkSubtle: inkSubtle ?? this.inkSubtle,
      line: line ?? this.line,
      lineStrong: lineStrong ?? this.lineStrong,
      accent: accent ?? this.accent,
      accentHover: accentHover ?? this.accentHover,
      accentInk: accentInk ?? this.accentInk,
      accentSubtle: accentSubtle ?? this.accentSubtle,
      success: success ?? this.success,
      successSubtle: successSubtle ?? this.successSubtle,
      warning: warning ?? this.warning,
      warningSubtle: warningSubtle ?? this.warningSubtle,
      danger: danger ?? this.danger,
      dangerSubtle: dangerSubtle ?? this.dangerSubtle,
      info: info ?? this.info,
      infoSubtle: infoSubtle ?? this.infoSubtle,
    );
  }

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      canvas: mix(canvas, other.canvas),
      surface: mix(surface, other.surface),
      surfaceRaised: mix(surfaceRaised, other.surfaceRaised),
      surfaceSunken: mix(surfaceSunken, other.surfaceSunken),
      ink: mix(ink, other.ink),
      inkMuted: mix(inkMuted, other.inkMuted),
      inkSubtle: mix(inkSubtle, other.inkSubtle),
      line: mix(line, other.line),
      lineStrong: mix(lineStrong, other.lineStrong),
      accent: mix(accent, other.accent),
      accentHover: mix(accentHover, other.accentHover),
      accentInk: mix(accentInk, other.accentInk),
      accentSubtle: mix(accentSubtle, other.accentSubtle),
      success: mix(success, other.success),
      successSubtle: mix(successSubtle, other.successSubtle),
      warning: mix(warning, other.warning),
      warningSubtle: mix(warningSubtle, other.warningSubtle),
      danger: mix(danger, other.danger),
      dangerSubtle: mix(dangerSubtle, other.dangerSubtle),
      info: mix(info, other.info),
      infoSubtle: mix(infoSubtle, other.infoSubtle),
    );
  }
}
