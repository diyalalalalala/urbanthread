import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage(this._storage);

  static const _key = 'urbanthread.accessToken';

  final FlutterSecureStorage _storage;
  String? _cached;
  bool _primed = false;

  Future<void> prime() async {
    if (_primed) return;
    _cached = await _read();
    _primed = true;
  }

  Future<String?> _read() async {
    try {
      return await _storage.read(key: _key);
    } on Exception {
      return null;
    }
  }

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
    } on Exception catch (_) {}
  }
}
