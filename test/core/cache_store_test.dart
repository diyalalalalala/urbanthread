import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:urbanthread/core/storage/cache_store.dart';

/// The offline-first requirement rests entirely on this class, and its most
/// important behaviours are the failure paths: a payload written by an older
/// build must not crash the screen it is read on, and a partially unreadable
/// list must not discard the whole page.
void main() {
  late Directory tempDir;
  late Box<dynamic> box;
  late CacheStore store;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('urbanthread_cache_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<dynamic>('test_cache');
    store = CacheStore(box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  Map<String, dynamic> asMap(Object? json) => json! as Map<String, dynamic>;

  group('write and read', () {
    test('round-trips a JSON object', () async {
      await store.write('product', {'_id': 'abc', 'name': 'Cotton Tee'});

      final result = store.read('product', asMap);

      expect(result?['_id'], 'abc');
      expect(result?['name'], 'Cotton Tee');
    });

    test('returns null for a key that was never written', () {
      expect(store.read('missing', asMap), isNull);
    });

    test('overwrites rather than merging', () async {
      await store.write('k', {'a': 1});
      await store.write('k', {'b': 2});

      final result = store.read('k', asMap);

      expect(result, {'b': 2});
    });
  });

  group('readList', () {
    test('decodes every element', () async {
      await store.write('products', [
        {'_id': '1'},
        {'_id': '2'},
      ]);

      final result = store.readList('products', asMap);

      expect(result.map((item) => item['_id']), ['1', '2']);
    });

    test('skips an unreadable element instead of dropping the page', () async {
      // One malformed row — a shape change on a single record — should cost
      // that row, not the whole cached catalogue page.
      await store.write('products', [
        {'_id': '1'},
        'not-an-object',
        {'_id': '3'},
      ]);

      final result = store.readList('products', asMap);

      expect(result, hasLength(2));
      expect(result.map((item) => item['_id']), ['1', '3']);
    });

    test('returns empty when nothing is cached', () {
      expect(store.readList('missing', asMap), isEmpty);
    });
  });

  group('corrupt entries', () {
    test('a payload that no longer parses reads as null and self-heals',
        () async {
      await store.write('k', {'a': 1});

      final result = store.read<String>('k', (json) {
        throw const FormatException('shape changed');
      });

      // Null tells the repository to re-fetch; clearing the entry stops the
      // same failure repeating on every subsequent read.
      expect(result, isNull);
      expect(store.has('k'), isFalse);
    });
  });

  group('staleness', () {
    test('a missing key is stale', () {
      expect(store.isStale('missing', const Duration(minutes: 5)), isTrue);
    });

    test('a fresh write is not stale', () async {
      await store.write('k', {'a': 1});

      expect(store.isStale('k', const Duration(minutes: 5)), isFalse);
    });

    test('a zero TTL makes anything stale', () async {
      await store.write('k', {'a': 1});

      // Staleness is advisory — the value is still readable, which is what
      // lets a screen show stale data while it refreshes behind.
      expect(store.isStale('k', Duration.zero), isTrue);
      expect(store.read('k', asMap), isNotNull);
    });

    test('records the write time', () async {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      await store.write('k', {'a': 1});

      expect(store.savedAt('k')?.isAfter(before), isTrue);
      expect(store.savedAt('missing'), isNull);
    });
  });

  group('invalidation', () {
    test('deletes one family of keys by prefix', () async {
      await store.write('products:page1', [<String, dynamic>{}]);
      await store.write('products:page2', [<String, dynamic>{}]);
      await store.write('categories:tree', [<String, dynamic>{}]);

      await store.deleteWhereKeyStartsWith('products:');

      expect(store.has('products:page1'), isFalse);
      expect(store.has('products:page2'), isFalse);
      expect(store.has('categories:tree'), isTrue);
    });

    test('clear empties the box', () async {
      await store.write('a', {'x': 1});
      await store.write('b', {'x': 2});

      await store.clear();

      expect(store.has('a'), isFalse);
      expect(store.has('b'), isFalse);
    });
  });
}
