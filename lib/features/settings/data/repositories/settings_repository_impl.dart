import '../../../../core/domain/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/cache_store.dart';
import '../../../../core/storage/preferences_service.dart';
import '../../domain/entities/theme_preference.dart';
import '../../domain/repositories/settings_repository.dart';

/// Settings backed by [PreferencesService] and the catalogue Hive box.
///
/// There is no remote datasource: none of these values exist server-side, so
/// there is nothing to sync and no failure mode beyond storage itself
/// refusing to write.
class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl({
    required PreferencesService preferences,
    required CacheStore catalogueCache,
  })  : _preferences = preferences,
        _catalogueCache = catalogueCache;

  final PreferencesService _preferences;
  final CacheStore _catalogueCache;

  @override
  ThemePreference get themePreference =>
      ThemePreference.parse(_preferences.themeMode);

  @override
  Future<void> saveThemePreference(ThemePreference preference) =>
      _preferences.saveThemeMode(preference.wireValue);

  @override
  Future<Result<void>> clearCatalogueCache() async {
    try {
      // Only the catalogue box. The account and activity boxes hold the
      // user's own data and are cleared on sign-out, not by a "free up space"
      // action the user expects to be harmless.
      await _catalogueCache.clear();
      return const Result.success(null);
    } on Object catch (error) {
      return Result.failure(CacheFailure('Could not clear the cache: $error'));
    }
  }

  @override
  List<String> get searchHistory => _preferences.searchHistory;

  @override
  Future<Result<void>> clearSearchHistory() async {
    try {
      await _preferences.clearSearchHistory();
      return const Result.success(null);
    } on Object catch (error) {
      return Result.failure(
        CacheFailure('Could not clear your search history: $error'),
      );
    }
  }
}
