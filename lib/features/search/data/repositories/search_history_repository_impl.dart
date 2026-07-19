import '../../../../core/domain/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/preferences_service.dart';
import '../../domain/repositories/search_history_repository.dart';

/// Search history backed by [PreferencesService].
///
/// The de-duplication and the ten-entry cap live in the preference store
/// rather than here, because they are storage concerns and the same rules
/// must hold however the list is written.
class SearchHistoryRepositoryImpl implements SearchHistoryRepository {
  SearchHistoryRepositoryImpl(this._preferences);

  final PreferencesService _preferences;

  @override
  List<String> get terms => _preferences.searchHistory;

  @override
  Future<Result<List<String>>> add(String term) =>
      _mutate(() => _preferences.addSearchTerm(term));

  @override
  Future<Result<List<String>>> remove(String term) =>
      _mutate(() => _preferences.removeSearchTerm(term));

  @override
  Future<Result<List<String>>> clear() =>
      _mutate(_preferences.clearSearchHistory);

  /// Runs a write and reports the resulting list.
  ///
  /// A storage failure is surfaced rather than swallowed, but it is not
  /// fatal: the caller shows the term it already has and carries on.
  Future<Result<List<String>>> _mutate(Future<void> Function() write) async {
    try {
      await write();
      return Result.success(terms);
    } on Object catch (error) {
      return Result.failure(CacheFailure('Could not update search history: $error'));
    }
  }
}
