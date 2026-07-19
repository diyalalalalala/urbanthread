import '../../../../core/network/api_envelope.dart';
import '../../../../core/storage/cache_store.dart';
import '../models/product_filters_model.dart';
import '../models/product_model.dart';

/// A cached page: the items plus the paging meta they came with.
///
/// The meta has to be stored alongside the items, otherwise a cached page
/// restored while offline would not know whether more pages exist and the
/// infinite scroll would either stop early or spin forever.
class CachedProductPage {
  const CachedProductPage({required this.items, this.meta});

  final List<ProductModel> items;
  final PaginationMeta? meta;

  bool get isEmpty => items.isEmpty;
}

/// The catalogue's Hive-backed offline copy.
///
/// Everything here lives in the `catalogue` box, which is public data and is
/// safe to clear wholesale — it is deliberately *not* wiped on logout, since
/// re-downloading a catalogue the next user will see anyway only costs them
/// bandwidth.
///
/// Keys are namespaced by concern (`products:list:…`, `products:detail:…`)
/// so one family can be invalidated without disturbing the others; see
/// [clearLists].
class ProductLocalDataSource {
  ProductLocalDataSource(this._store);

  static const _listPrefix = 'products:list:';
  static const _detailPrefix = 'products:detail:';
  static const _collectionPrefix = 'products:collection:';
  static const _filtersKey = 'products:filters';

  static const _itemsField = 'items';
  static const _metaField = 'meta';

  final CacheStore _store;

  // ── List pages ─────────────────────────────────────────────────────────

  /// [key] comes from `ProductQuery.cacheKey`, which already includes the
  /// page number — consecutive scroll pages must not overwrite each other.
  Future<void> writePage(
    String key,
    List<ProductModel> items,
    PaginationMeta? meta,
  ) =>
      _store.write(key, {
        _itemsField: items.map((item) => item.toJson()).toList(growable: false),
        _metaField: meta?.toJson(),
      });

  CachedProductPage? readPage(String key) => _store.read(key, (json) {
        if (json is! Map) throw const FormatException('Expected an object');
        final rawItems = json[_itemsField];
        if (rawItems is! List) throw const FormatException('Expected items');

        final items = <ProductModel>[];
        for (final entry in rawItems) {
          // Skip an element written by an older build rather than discarding
          // the whole page — a partial grid beats an empty one.
          if (entry is! Map<String, dynamic>) continue;
          try {
            items.add(ProductModel.fromJson(entry));
          } on Object {
            continue;
          }
        }

        final rawMeta = json[_metaField];
        return CachedProductPage(
          items: items,
          meta: rawMeta is Map<String, dynamic>
              ? PaginationMeta.fromJson(rawMeta)
              : null,
        );
      });

  /// Drops every cached list page. Called on pull-to-refresh, where the user
  /// has explicitly asked for fresh data.
  Future<void> clearLists() => _store.deleteWhereKeyStartsWith(_listPrefix);

  // ── Detail ─────────────────────────────────────────────────────────────

  Future<void> writeProduct(ProductModel product) =>
      _store.write('$_detailPrefix${product.slug}', product.toJson());

  ProductModel? readProduct(String slug) =>
      _store.read('$_detailPrefix$slug', (json) {
        if (json is! Map<String, dynamic>) {
          throw const FormatException('Expected an object');
        }
        return ProductModel.fromJson(json);
      });

  // ── Collections and recommendations ────────────────────────────────────

  /// [name] namespaces the list: a collection key (`featured`), or a
  /// recommendation key (`related:<id>`).
  Future<void> writeCollection(String name, List<ProductModel> items) =>
      _store.write(
        '$_collectionPrefix$name',
        items.map((item) => item.toJson()).toList(growable: false),
      );

  List<ProductModel> readCollection(String name) => _store.readList(
        '$_collectionPrefix$name',
        (json) => ProductModel.fromJson(json! as Map<String, dynamic>),
      );

  // ── Facets ─────────────────────────────────────────────────────────────

  /// The filter sheet is unusable without facets, and they change rarely, so
  /// they are worth keeping even when everything else is evicted.
  Future<void> writeFilters(ProductFiltersModel filters) =>
      _store.write(_filtersKey, filters.toJson());

  ProductFiltersModel? readFilters() => _store.read(_filtersKey, (json) {
        if (json is! Map<String, dynamic>) {
          throw const FormatException('Expected an object');
        }
        return ProductFiltersModel.fromJson(json);
      });
}
