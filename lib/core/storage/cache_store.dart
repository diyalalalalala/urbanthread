import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../errors/exceptions.dart';

class CacheStore {
  CacheStore(this._box);

  static const _payloadKey = 'v';
  static const _savedAtKey = 't';

  final Box<dynamic> _box;

  Future<void> write(String key, Object? value) async {
    try {
      await _box.put(key, {
        _payloadKey: jsonEncode(value),
        _savedAtKey: DateTime.now().millisecondsSinceEpoch,
      });
    } on Object catch (error) {
      throw CacheException('Could not save "$key": $error');
    }
  }

  T? read<T>(String key, T Function(Object? json) fromJson) {
    final raw = _box.get(key);
    if (raw is! Map) return null;

    final payload = raw[_payloadKey];
    if (payload is! String) return null;

    try {
      return fromJson(jsonDecode(payload));
    } on Object {
      _box.delete(key).ignore();
      return null;
    }
  }

  List<T> readList<T>(String key, T Function(Object? json) fromJson) {
    final decoded = read<List<Object?>>(key, (json) {
      if (json is! List) throw const FormatException('Expected a JSON array');
      return json;
    });
    if (decoded == null) return const [];

    final results = <T>[];
    for (final entry in decoded) {
      try {
        results.add(fromJson(entry));
      } on Object {
        continue;
      }
    }
    return results;
  }

  DateTime? savedAt(String key) {
    final raw = _box.get(key);
    if (raw is! Map) return null;
    final millis = raw[_savedAtKey];
    if (millis is! int) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  bool isStale(String key, Duration ttl) {
    final written = savedAt(key);
    if (written == null) return true;
    return DateTime.now().difference(written) > ttl;
  }

  bool has(String key) => _box.containsKey(key);

  Future<void> delete(String key) => _box.delete(key);

  Future<void> deleteWhereKeyStartsWith(String prefix) async {
    final doomed =
        _box.keys.whereType<String>().where((key) => key.startsWith(prefix));
    await _box.deleteAll(doomed.toList(growable: false));
  }

  Future<void> clear() => _box.clear();
}
