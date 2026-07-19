import '../../../../core/domain/result.dart';
import '../entities/theme_preference.dart';

/// Device-local settings.
///
/// Nothing here touches the network — these are preferences and caches that
/// belong to the handset, not to the account, which is why they survive a
/// sign-out.
abstract interface class SettingsRepository {
  /// Read synchronously: the theme has to be known before the first frame,
  /// and an async read would flash the wrong scheme.
  ThemePreference get themePreference;

  Future<void> saveThemePreference(ThemePreference preference);

  /// Clears the catalogue Hive box — products, categories, brands, home
  /// sections. Safe at any time; it is public data that will be re-fetched.
  Future<Result<void>> clearCatalogueCache();

  /// The saved search terms, most recent first.
  List<String> get searchHistory;

  Future<Result<void>> clearSearchHistory();
}
