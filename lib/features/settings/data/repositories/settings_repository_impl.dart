import '../../../../core/domain/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/cache_store.dart';
import '../../../../core/storage/preferences_service.dart';
import '../../domain/entities/theme_preference.dart';
import '../../domain/repositories/settings_repository.dart';

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
