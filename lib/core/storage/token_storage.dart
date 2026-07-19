import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Custody of the access token.
///
/// The API issues a single 7-day JWT and has **no refresh endpoint** —
/// revocation works by bumping `tokenVersion` server-side, which invalidates
/// every outstanding token at once. So this is the only session credential
/// there is, and losing it means a full re-login. It lives in the platform
/// keystore/keychain rather than SharedPreferences because it is a bearer
/// credential: anything holding it can act as the user until it expires.
///
/// The token is mirrored into [_cached] so the auth interceptor can attach it
/// synchronously. Secure storage reads hit platform channels and are far too
/// slow to sit in the path of every request.
class TokenStorage {
  TokenStorage(this._storage);

  static const _key = 'urbanthread.accessToken';

  final FlutterSecureStorage _storage;
  String? _cached;
  bool _primed = false;

  /// Warms the in-memory copy. Call once during bootstrap, before any request
  /// is issued, so the first call out is already authenticated.
  Future<void> prime() async {
    if (_primed) return;
    _cached = await _read();
    _primed = true;
  }

  Future<String?> _read() async {
    try {
      return await _storage.read(key: _key);
    } on Exception {
      // A corrupt keystore entry (seen after a restore-from-backup on
      // Android) throws rather than returning null. Treat it as "no session"
      // — the user logs in again and the bad entry is overwritten.
      return null;
    }
  }

  /// The token, or null when signed out. Valid only after [prime].
  String? get token => _cached;

  bool get hasToken => (_cached?.isNotEmpty ?? false);

  Future<void> save(String token) async {
    _cached = token;
    _primed = true;
    await _storage.write(key: _key, value: token);
  }

  Future<void> clear() async {
    _cached = null;
    _primed = true;
    try {
      await _storage.delete(key: _key);
    } on Exception {
      // Best-effort: the in-memory copy is already gone, so the session is
      // over regardless of whether the platform delete succeeded.
    }
  }
}
