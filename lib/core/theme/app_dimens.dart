import 'package:flutter/material.dart';

abstract final class AppDimens {
  const AppDimens._();

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

  static const pageGutter = 20.0;

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

  static const controlHeightSm = 36.0;
  static const controlHeight = 44.0;
  static const controlHeightLg = 52.0;

  static const productAspectRatio = 3 / 4;

  static const minTapTarget = 44.0;

  static const easeOutExpo = Cubic(0.16, 1, 0.3, 1);

  static const durationFast = Duration(milliseconds: 150);
  static const durationMedium = Duration(milliseconds: 250);
  static const durationSlow = Duration(milliseconds: 400);
}
