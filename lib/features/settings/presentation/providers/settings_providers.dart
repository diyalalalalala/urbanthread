import 'package:flutter/material.dart' show ThemeMode;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/theme_preference.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/settings_usecases.dart';

part 'settings_providers.g.dart';

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) => SettingsRepositoryImpl(
      preferences: ref.watch(preferencesServiceProvider),
      catalogueCache: ref.watch(catalogueCacheProvider),
    );

@riverpod
SetThemePreferenceUseCase setThemePreferenceUseCase(Ref ref) =>
    SetThemePreferenceUseCase(ref.watch(settingsRepositoryProvider));

@riverpod
ClearCatalogueCacheUseCase clearCatalogueCacheUseCase(Ref ref) =>
    ClearCatalogueCacheUseCase(ref.watch(settingsRepositoryProvider));

@riverpod
ClearSearchHistoryUseCase clearSearchHistoryUseCase(Ref ref) =>
    ClearSearchHistoryUseCase(ref.watch(settingsRepositoryProvider));

/// The app's colour scheme, for `MaterialApp.themeMode`.
///
/// Synchronous by design. `PreferencesService` is already loaded by the time
/// the widget tree exists, so the very first frame can be painted in the right
/// scheme — an `AsyncValue` here would flash the light theme at a dark-mode
/// user on every cold start.
///
/// Kept alive because `MaterialApp` is the only listener; if it ever stopped
/// watching, disposing and re-reading would be a needless round trip through
/// storage. The class carries no `Notifier` suffix so the generator emits
/// exactly `themeModeProvider`.
@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() => _toThemeMode(
        ref.watch(settingsRepositoryProvider).themePreference,
      );

  /// The stored preference behind the current [ThemeMode], for the settings
  /// screen's radio list.
  ThemePreference get preference => switch (state) {
        ThemeMode.light => ThemePreference.light,
        ThemeMode.dark => ThemePreference.dark,
        ThemeMode.system => ThemePreference.system,
      };

  /// Applies [preference] immediately, then persists it. The optimistic order
  /// matters: a theme switch that waited on a disk write would feel laggy.
  Future<void> select(ThemePreference preference) async {
    state = _toThemeMode(preference);
    await ref.read(setThemePreferenceUseCaseProvider)(preference);
  }

  static ThemeMode _toThemeMode(ThemePreference preference) =>
      switch (preference) {
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark => ThemeMode.dark,
        ThemePreference.system => ThemeMode.system,
      };
}

/// The saved search terms, so the settings screen can show a count and hide
/// the clear action when there is nothing to clear.
@riverpod
class SearchHistoryCount extends _$SearchHistoryCount {
  @override
  int build() => ref.watch(settingsRepositoryProvider).searchHistory.length;

  /// Clears the history and drops the count to zero. Returns the failure, or
  /// null on success.
  Future<Failure?> clear() async {
    final result = await ref.read(clearSearchHistoryUseCaseProvider)(
      const NoParams(),
    );
    return result.fold(
      onSuccess: (_) {
        state = 0;
        return null;
      },
      onFailure: (failure) => failure,
    );
  }
}
