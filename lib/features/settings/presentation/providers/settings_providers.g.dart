// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SettingsRepository,
          SettingsRepository,
          SettingsRepository
        >
    with $Provider<SettingsRepository> {
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'b14576998e81372769d6b14ebac66c8abb5d9b65';

@ProviderFor(setThemePreferenceUseCase)
final setThemePreferenceUseCaseProvider = SetThemePreferenceUseCaseProvider._();

final class SetThemePreferenceUseCaseProvider
    extends
        $FunctionalProvider<
          SetThemePreferenceUseCase,
          SetThemePreferenceUseCase,
          SetThemePreferenceUseCase
        >
    with $Provider<SetThemePreferenceUseCase> {
  SetThemePreferenceUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setThemePreferenceUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setThemePreferenceUseCaseHash();

  @$internal
  @override
  $ProviderElement<SetThemePreferenceUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SetThemePreferenceUseCase create(Ref ref) {
    return setThemePreferenceUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SetThemePreferenceUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SetThemePreferenceUseCase>(value),
    );
  }
}

String _$setThemePreferenceUseCaseHash() =>
    r'5d9da1b591de2062fc87a06a7ae13f08c8e51e7e';

@ProviderFor(clearCatalogueCacheUseCase)
final clearCatalogueCacheUseCaseProvider =
    ClearCatalogueCacheUseCaseProvider._();

final class ClearCatalogueCacheUseCaseProvider
    extends
        $FunctionalProvider<
          ClearCatalogueCacheUseCase,
          ClearCatalogueCacheUseCase,
          ClearCatalogueCacheUseCase
        >
    with $Provider<ClearCatalogueCacheUseCase> {
  ClearCatalogueCacheUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clearCatalogueCacheUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clearCatalogueCacheUseCaseHash();

  @$internal
  @override
  $ProviderElement<ClearCatalogueCacheUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClearCatalogueCacheUseCase create(Ref ref) {
    return clearCatalogueCacheUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClearCatalogueCacheUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClearCatalogueCacheUseCase>(value),
    );
  }
}

String _$clearCatalogueCacheUseCaseHash() =>
    r'14e517e2b632691bb291f89d0e477759b28185b3';

@ProviderFor(clearSearchHistoryUseCase)
final clearSearchHistoryUseCaseProvider = ClearSearchHistoryUseCaseProvider._();

final class ClearSearchHistoryUseCaseProvider
    extends
        $FunctionalProvider<
          ClearSearchHistoryUseCase,
          ClearSearchHistoryUseCase,
          ClearSearchHistoryUseCase
        >
    with $Provider<ClearSearchHistoryUseCase> {
  ClearSearchHistoryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clearSearchHistoryUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clearSearchHistoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<ClearSearchHistoryUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClearSearchHistoryUseCase create(Ref ref) {
    return clearSearchHistoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClearSearchHistoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClearSearchHistoryUseCase>(value),
    );
  }
}

String _$clearSearchHistoryUseCaseHash() =>
    r'f0329c9214dd9b774903ea95051ef35898854e97';

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

@ProviderFor(ThemeModeNotifier)
final themeModeProvider = ThemeModeNotifierProvider._();

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
final class ThemeModeNotifierProvider
    extends $NotifierProvider<ThemeModeNotifier, ThemeMode> {
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
  ThemeModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeNotifierHash();

  @$internal
  @override
  ThemeModeNotifier create() => ThemeModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeModeNotifierHash() => r'122cbaa52b1f9a04fde5dd7c5374df9727649e2e';

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

abstract class _$ThemeModeNotifier extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The saved search terms, so the settings screen can show a count and hide
/// the clear action when there is nothing to clear.

@ProviderFor(SearchHistoryCount)
final searchHistoryCountProvider = SearchHistoryCountProvider._();

/// The saved search terms, so the settings screen can show a count and hide
/// the clear action when there is nothing to clear.
final class SearchHistoryCountProvider
    extends $NotifierProvider<SearchHistoryCount, int> {
  /// The saved search terms, so the settings screen can show a count and hide
  /// the clear action when there is nothing to clear.
  SearchHistoryCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchHistoryCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchHistoryCountHash();

  @$internal
  @override
  SearchHistoryCount create() => SearchHistoryCount();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$searchHistoryCountHash() =>
    r'311702a3055e5dee9877a0bdea1861a5117e4630';

/// The saved search terms, so the settings screen can show a count and hide
/// the clear action when there is nothing to clear.

abstract class _$SearchHistoryCount extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
