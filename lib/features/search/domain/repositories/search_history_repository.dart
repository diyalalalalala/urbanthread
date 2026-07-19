import '../../../../core/domain/result.dart';

/// The shopper's recent searches.
///
/// Device-local by design: the API has no search-history endpoint, and the
/// terms are stored in `SharedPreferences` alongside the other per-user
/// preferences so they are cleared on logout with the rest of the session.
///
/// Every mutation returns the resulting list, so a caller never has to
/// re-read to find out what changed.
abstract interface class SearchHistoryRepository {
  /// Most-recent first, de-duplicated, capped by the preference store.
  List<String> get terms;

  /// Records a term after a search is actually run — not on every keystroke,
  /// or the history fills with the prefixes of one word.
  Future<Result<List<String>>> add(String term);

  Future<Result<List<String>>> remove(String term);

  Future<Result<List<String>>> clear();
}
