import '../../../../core/storage/cache_store.dart';

class OutboxQueue {
  OutboxQueue({required CacheStore store, required String namespace})
      : _store = store,
        _key = 'outbox:$namespace';

  final CacheStore _store;
  final String _key;

  static int _sequence = 0;

  List<OutboxEntry> pending() =>
      _store.readList<OutboxEntry>(_key, OutboxEntry.fromJson);

  int get length => pending().length;

  bool get isEmpty => pending().isEmpty;

  Future<OutboxEntry> enqueue(
    String kind,
    Map<String, dynamic> payload, {
    bool Function(OutboxEntry entry)? replaceMatching,
  }) async {
    final entry = OutboxEntry(
      id: '${DateTime.now().microsecondsSinceEpoch}-${_sequence++}',
      kind: kind,
      payload: payload,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    final entries = pending();
    final kept = replaceMatching == null
        ? entries
        : entries.where((existing) => !replaceMatching(existing));

    await _write([...kept, entry]);
    return entry;
  }

  Future<void> remove(String id) async {
    await _write(
      pending().where((entry) => entry.id != id).toList(growable: false),
    );
  }

  Future<void> removeWhere(bool Function(OutboxEntry entry) test) async {
    await _write(pending().where((entry) => !test(entry)).toList(
          growable: false,
        ));
  }

  Future<void> clear() => _store.delete(_key);

  Future<void> _write(List<OutboxEntry> entries) => _store.write(
        _key,
        entries.map((entry) => entry.toJson()).toList(growable: false),
      );
}

class OutboxEntry {
  const OutboxEntry({
    required this.id,
    required this.kind,
    required this.payload,
    required this.createdAt,
  });

  factory OutboxEntry.fromJson(Object? json) {
    if (json is! Map) throw const FormatException('Not an outbox entry');
    return OutboxEntry(
      id: json['id'] as String,
      kind: json['kind'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      createdAt: json['createdAt'] as int? ?? 0,
    );
  }

  final String id;

  final String kind;

  final Map<String, dynamic> payload;
  final int createdAt;

  String? get itemId => payload['itemId'] as String?;
  String? get productId => payload['productId'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind,
        'payload': payload,
        'createdAt': createdAt,
      };
}
