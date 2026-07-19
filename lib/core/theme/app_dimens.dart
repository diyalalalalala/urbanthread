import 'package:flutter/material.dart';

/// Spacing and radius scale.
///
/// The brand is deliberately square — the web tokens set `--radius: 0.25rem`,
/// so 4px is the default and anything rounder is a conscious exception
/// (avatars, chips). Resisting Material's default 12–28px corners is most of
/// what makes the Flutter app look like the same product as the website.
abstract final class AppDimens {
  const AppDimens._();

  // Spacing — a 4px base scale.
  static const space2 = 2.0;
  static const space4 = 4.0;
  static const space8 = 8.0;
  static const space12 = 12.0;
  static const space16 = 16.0;
  static const space20 = 20.0;
  static const space24 = 24.0;
  static const space32 = 32.0;
  static const space40 = 40.0;
  static const space48 = 48.0;
  static const space64 = 64.0;

  /// Horizontal page gutter, matching the web's `container-page`.
  static const pageGutter = 20.0;

  // Radius.
  static const radiusSm = 2.0;
  static const radius = 4.0;
  static const radiusLg = 8.0;
  static const radiusXl = 12.0;
  static const radiusPill = 999.0;

  static const BorderRadius borderRadiusSm =
      BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadius =
      BorderRadius.all(Radius.circular(radius));
  static const BorderRadius borderRadiusLg =
      BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusXl =
      BorderRadius.all(Radius.circular(radiusXl));

  // Control heights, mirroring the web button sizes (h-9 / h-11 / h-13).
  static const controlHeightSm = 36.0;
  static const controlHeight = 44.0;
  static const controlHeightLg = 52.0;

  /// Product imagery is shot 3:4 portrait throughout the catalogue.
  static const productAspectRatio = 3 / 4;

  /// Minimum tap target. Below this, controls fail accessibility guidance.
  static const minTapTarget = 44.0;

  /// The web's signature easing (`--ease-out-expo`).
  static const easeOutExpo = Cubic(0.16, 1, 0.3, 1);

  static const durationFast = Duration(milliseconds: 150);
  static const durationMedium = Duration(milliseconds: 250);
  static const durationSlow = Duration(milliseconds: 400);
}
