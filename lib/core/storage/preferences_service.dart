import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Small, non-sensitive state that must survive a restart.
///
/// The split from [TokenStorage] is intentional: the access token is a bearer
/// credential and belongs in the keystore, while everything here is either a
/// preference or a cached copy of public profile data. Keeping the cached
/// user out of secure storage also means the app can render a signed-in shell
/// instantly at launch, without waiting on a platform-channel decrypt.
class PreferencesService {
  PreferencesService(this._prefs);

  static const _keyUser = 'urbanthread.user';
  static const _keyThemeMode = 'urbanthread.themeMode';
  static const _keyOnboarded = 'urbanthread.onboardingComplete';
  static const _keySearchHistory = 'urbanthread.searchHistory';
  static const _keyLastSyncAt = 'urbanthread.lastSyncAt';

  static const searchHistoryLimit = 10;

  final SharedPreferences _prefs;

  /// Loads the backing store. Call during bootstrap.
  static Future<PreferencesService> create() async =>
      PreferencesService(await SharedPreferences.getInstance());

  // ── Session ────────────────────────────────────────────────────────────

  /// The signed-in user as raw JSON.
  ///
  /// Stored decoded-on-read rather than as a typed object so this core class
  /// stays independent of the auth feature's models — core must not depend on
  /// features, or the dependency rule inverts.
  Map<String, dynamic>? get cachedUser {
    final raw = _prefs.getString(_keyUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  Future<void> saveUser(Map<String, dynamic> user) =>
      _prefs.setString(_keyUser, jsonEncode(user));

  Future<void> clearUser() => _prefs.remove(_keyUser);

  /// Whether a session looked valid at last launch. Only a hint for choosing
  /// the first route — the token itself is the authority.
  bool get hasCachedSession => _prefs.containsKey(_keyUser);

  // ── Settings ───────────────────────────────────────────────────────────

  /// `system`, `light` or `dark`.
  String get themeMode => _prefs.getString(_keyThemeMode) ?? 'system';

  Future<void> saveThemeMode(String mode) =>
      _prefs.setString(_keyThemeMode, mode);

  bool get hasCompletedOnboarding => _prefs.getBool(_keyOnboarded) ?? false;

  Future<void> completeOnboarding() => _prefs.setBool(_keyOnboarded, true);

  // ── Search history ─────────────────────────────────────────────────────

  List<String> get searchHistory =>
      _prefs.getStringList(_keySearchHistory) ?? const [];

  /// Records [term], most-recent first, de-duplicated case-insensitively and
  /// capped at [searchHistoryLimit].
  Future<void> addSearchTerm(String term) async {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return;

    final existing = searchHistory;
    final deduped = [
      trimmed,
      ...existing.where(
        (entry) => entry.toLowerCase() != trimmed.toLowerCase(),
      ),
    ].take(searchHistoryLimit).toList(growable: false);

    await _prefs.setStringList(_keySearchHistory, deduped);
  }

  Future<void> removeSearchTerm(String term) async {
    final remaining = searchHistory
        .where((entry) => entry != term)
        .toList(growable: false);
    await _prefs.setStringList(_keySearchHistory, remaining);
  }

  Future<void> clearSearchHistory() => _prefs.remove(_keySearchHistory);

  // ── Sync ───────────────────────────────────────────────────────────────

  DateTime? get lastSyncAt {
    final millis = _prefs.getInt(_keyLastSyncAt);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> markSynced() =>
      _prefs.setInt(_keyLastSyncAt, DateTime.now().millisecondsSinceEpoch);

  /// Clears session and per-user state on logout, keeping device preferences
  /// (theme, onboarding) — those belong to the device, not the account.
  Future<void> clearSession() async {
    await Future.wait([
      _prefs.remove(_keyUser),
      _prefs.remove(_keySearchHistory),
      _prefs.remove(_keyLastSyncAt),
    ]);
  }
}
