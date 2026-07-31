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

@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() => _toThemeMode(
        ref.watch(settingsRepositoryProvider).themePreference,
      );

  ThemePreference get preference => switch (state) {
        ThemeMode.light => ThemePreference.light,
        ThemeMode.dark => ThemePreference.dark,
        ThemeMode.system => ThemePreference.system,
      };

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

@riverpod
class SearchHistoryCount extends _$SearchHistoryCount {
  @override
  int build() => ref.watch(settingsRepositoryProvider).searchHistory.length;

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
