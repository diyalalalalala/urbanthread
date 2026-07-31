import '../../../../core/domain/result.dart';
import '../entities/theme_preference.dart';

abstract interface class SettingsRepository {
  ThemePreference get themePreference;

  Future<void> saveThemePreference(ThemePreference preference);

  Future<Result<void>> clearCatalogueCache();

  List<String> get searchHistory;

  Future<Result<void>> clearSearchHistory();
}
