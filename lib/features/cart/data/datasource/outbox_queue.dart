import '../../../../core/storage/cache_store.dart';

/// A durable, ordered queue of writes made while the device was offline.
///
/// Core owns the `outbox` Hive box but nothing that structures it, so this
/// lives in the feature. It is deliberately generic — [namespace] keys each
/// consumer's entries apart inside the one box — because both the cart and
/// the wishlist need exactly this, and the wishlist already depends on the
/// cart (its move-to-cart response embeds a cart snapshot).
///
/// Ordering is the whole point. "Set quantity to 3" followed by "remove the
/// line" must not replay the other way round, so entries are appended and
/// drained oldest-first, and coalescing is opt-in per call site rather than
/// something the queue decides on its own.
class OutboxQueue {
  OutboxQueue({required CacheStore store, required String namespace})
      : _store = store,
        _key = 'outbox:$namespace';

  final CacheStore _store;
  final String _key;

  /// Disambiguates two entries enqueued inside the same microsecond.
  static int _sequence = 0;

  List<OutboxEntry> pending() =>
      _store.readList<OutboxEntry>(_key, OutboxEntry.fromJson);

  int get length => pending().length;

  bool get isEmpty => pending().isEmpty;

  /// Appends a write.
  ///
  /// When [replaceMatching] is given, any existing entry it accepts is dropped
  /// first. That is how a stepper tapped five times leaves one entry rather
  /// than five, and how a removal supersedes the quantity edits that preceded
  /// it — replaying a superseded write would either waste a round trip or, in
  /// the removal case, resurrect a line the customer deleted.
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

  /// Drops every entry the predicate accepts. Used when a write turns out to
  /// be permanently unacceptable to the server and so are its dependants.
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

/// One queued write: what to do, and the arguments to do it with.
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

  /// A dotted verb — `cart.updateQuantity`, `wishlist.remove`. Matched against
  /// a switch when replaying, and unknown kinds are discarded rather than
  /// retried: they were written by a build that no longer exists.
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
