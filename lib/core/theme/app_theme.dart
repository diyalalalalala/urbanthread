import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_typography.dart';

/// Assembles the light and dark [ThemeData].
///
/// Material 3 is enabled but its defaults are overridden fairly aggressively:
/// the brand is flat, square and low-contrast-chrome, whereas M3 out of the
/// box is rounded, tinted and elevated. Rather than fight that per widget,
/// the component themes below neutralise it once — elevation to zero, radii
/// to 4px, surface tint off — so an un-styled widget already looks correct.
abstract final class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(AppPalette.light, Brightness.light);

  static ThemeData get dark => _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette palette, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      // `ink` is the brand's primary action colour — the web's primary button
      // is ink-on-canvas, with clay reserved as an accent.
      primary: palette.ink,
      onPrimary: palette.canvas,
      primaryContainer: palette.surfaceSunken,
      onPrimaryContainer: palette.ink,
      secondary: palette.accent,
      onSecondary: palette.accentInk,
      secondaryContainer: palette.accentSubtle,
      onSecondaryContainer: palette.accent,
      tertiary: palette.info,
      onTertiary: palette.canvas,
      error: palette.danger,
      onError: palette.canvas,
      errorContainer: palette.dangerSubtle,
      onErrorContainer: palette.danger,
      surface: palette.surface,
      onSurface: palette.ink,
      onSurfaceVariant: palette.inkMuted,
      surfaceContainerLowest: palette.canvas,
      surfaceContainerLow: palette.surfaceRaised,
      surfaceContainer: palette.surfaceRaised,
      surfaceContainerHigh: palette.surfaceSunken,
      surfaceContainerHighest: palette.surfaceSunken,
      outline: palette.line,
      outlineVariant: palette.lineStrong,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: palette.ink,
      onInverseSurface: palette.canvas,
      inversePrimary: palette.accent,
    );

    final textTheme = AppTypography.textTheme(palette.ink, palette.inkMuted);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.canvas,
      canvasColor: palette.canvas,
      fontFamily: AppTypography.sans,
      textTheme: textTheme,
      extensions: [palette],

      // M3 tints surfaces with the primary colour as they rise. The brand's
      // neutrals are warm and the tint muddies them, so it is disabled.
      applyElevationOverlayColor: false,

      splashFactory: InkSparkle.splashFactory,
      dividerColor: palette.line,
      dividerTheme: DividerThemeData(
        color: palette.line,
        thickness: 1,
        space: 1,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: palette.canvas,
        foregroundColor: palette.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: brightness == Brightness.light
            ? SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: palette.canvas,
                systemNavigationBarIconBrightness: Brightness.dark,
              )
            : SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: palette.canvas,
                systemNavigationBarIconBrightness: Brightness.light,
              ),
      ),

      cardTheme: CardThemeData(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimens.borderRadius,
          side: BorderSide(color: palette.line),
        ),
      ),

      // Primary = ink on canvas, uppercase, square. Matches the web `primary`
      // button variant, which shifts colour on press rather than lifting.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.ink,
          foregroundColor: palette.canvas,
          disabledBackgroundColor: palette.lineStrong,
          disabledForegroundColor: palette.canvas,
          elevation: 0,
          minimumSize: const Size.fromHeight(AppDimens.controlHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.space24,
          ),
          textStyle: AppTypography.button,
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimens.borderRadius,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.ink,
          minimumSize: const Size.fromHeight(AppDimens.controlHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.space24,
          ),
          textStyle: AppTypography.button,
          side: BorderSide(color: palette.lineStrong),
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimens.borderRadius,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.accent,
          textStyle: AppTypography.button,
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimens.borderRadius,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: AppDimens.space16,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: palette.inkSubtle),
        labelStyle: textTheme.bodyMedium?.copyWith(color: palette.inkMuted),
        floatingLabelStyle: textTheme.bodySmall?.copyWith(color: palette.ink),
        errorStyle: textTheme.bodySmall?.copyWith(color: palette.danger),
        border: _inputBorder(palette.line),
        enabledBorder: _inputBorder(palette.line),
        focusedBorder: _inputBorder(palette.ink, width: 1.5),
        errorBorder: _inputBorder(palette.danger),
        focusedErrorBorder: _inputBorder(palette.danger, width: 1.5),
        disabledBorder: _inputBorder(palette.line),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: palette.surface,
        selectedColor: palette.ink,
        disabledColor: palette.surfaceSunken,
        labelStyle: textTheme.labelMedium!,
        secondaryLabelStyle: textTheme.labelMedium!.copyWith(
          color: palette.canvas,
        ),
        side: BorderSide(color: palette.line),
        shape: const RoundedRectangleBorder(
          borderRadius: AppDimens.borderRadius,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space12,
          vertical: AppDimens.space8,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.canvas,
        selectedItemColor: palette.ink,
        unselectedItemColor: palette.inkSubtle,
        selectedLabelStyle: AppTypography.eyebrow,
        unselectedLabelStyle: AppTypography.eyebrow,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.canvas,
        indicatorColor: palette.accentSubtle,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorShape: const RoundedRectangleBorder(
          borderRadius: AppDimens.borderRadius,
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppTypography.eyebrow.copyWith(
            color: states.contains(WidgetState.selected)
                ? palette.ink
                : palette.inkSubtle,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? palette.ink
                : palette.inkSubtle,
          ),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: true,
        dragHandleColor: palette.lineStrong,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimens.radiusLg),
          ),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
        shape: const RoundedRectangleBorder(
          borderRadius: AppDimens.borderRadiusLg,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: palette.canvas),
        actionTextColor: palette.accent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: AppDimens.borderRadius,
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.accent,
        linearMinHeight: 2,
      ),

      listTileTheme: ListTileThemeData(
        iconColor: palette.inkMuted,
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle: textTheme.bodySmall,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.pageGutter,
          vertical: AppDimens.space4,
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.canvas
              : palette.surface,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.ink
              : palette.lineStrong,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: palette.ink,
        unselectedLabelColor: palette.inkSubtle,
        labelStyle: AppTypography.button,
        unselectedLabelStyle: AppTypography.button,
        indicatorColor: palette.ink,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: palette.line,
      ),

      iconTheme: IconThemeData(color: palette.ink, size: 22),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: AppDimens.borderRadius,
        borderSide: BorderSide(color: color, width: width),
      );
}
