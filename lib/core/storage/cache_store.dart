import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../errors/exceptions.dart';

/// Typed access to a Hive box, with staleness tracking.
///
/// Values are stored as JSON strings wrapped in a small envelope carrying the
/// write time. Storing the encoded payload rather than an adapter-backed
/// object is a deliberate trade: it costs an encode/decode per access, and in
/// exchange a DTO can gain or drop a field without invalidating what is
/// already on disk. For a catalogue that changes shape as the API evolves,
/// that resilience is worth more than the microseconds.
///
/// Staleness is advisory. [read] returns data past its TTL anyway, because
/// stale prices beat an empty screen when the user is on a train — the caller
/// decides whether to also kick off a refresh.
class CacheStore {
  CacheStore(this._box);

  static const _payloadKey = 'v';
  static const _savedAtKey = 't';

  final Box<dynamic> _box;

  /// Writes [value], which must be JSON-encodable.
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

  /// Decodes the entry at [key] with [fromJson], or null if absent.
  ///
  /// A decode failure clears the entry and returns null rather than throwing:
  /// the payload was written by an older build whose shape no longer parses,
  /// and the right recovery is to re-fetch, not to crash the screen.
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

  /// Decodes a cached JSON array, or an empty list when nothing is stored.
  List<T> readList<T>(String key, T Function(Object? json) fromJson) {
    final decoded = read<List<Object?>>(key, (json) {
      if (json is! List) throw const FormatException('Expected a JSON array');
      return json;
    });
    if (decoded == null) return const [];

    // Tolerate a single unreadable element instead of discarding the page.
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

  /// When [key] was last written, or null if never.
  DateTime? savedAt(String key) {
    final raw = _box.get(key);
    if (raw is! Map) return null;
    final millis = raw[_savedAtKey];
    if (millis is! int) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  /// True when [key] is missing or older than [ttl].
  bool isStale(String key, Duration ttl) {
    final written = savedAt(key);
    if (written == null) return true;
    return DateTime.now().difference(written) > ttl;
  }

  bool has(String key) => _box.containsKey(key);

  Future<void> delete(String key) => _box.delete(key);

  /// Removes every entry whose key starts with [prefix] — used to invalidate
  /// one family of cached queries (`products:*`) without touching the rest.
  Future<void> deleteWhereKeyStartsWith(String prefix) async {
    final doomed =
        _box.keys.whereType<String>().where((key) => key.startsWith(prefix));
    await _box.deleteAll(doomed.toList(growable: false));
  }

  Future<void> clear() => _box.clear();
}
