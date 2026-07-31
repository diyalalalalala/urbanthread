import '../../../../core/network/api_envelope.dart';
import '../../../../core/storage/cache_store.dart';
import '../models/product_filters_model.dart';
import '../models/product_model.dart';

class CachedProductPage {
  const CachedProductPage({required this.items, this.meta});

  final List<ProductModel> items;
  final PaginationMeta? meta;

  bool get isEmpty => items.isEmpty;
}

class ProductLocalDataSource {
  ProductLocalDataSource(this._store);

  static const _listPrefix = 'products:list:';
  static const _detailPrefix = 'products:detail:';
  static const _collectionPrefix = 'products:collection:';
  static const _filtersKey = 'products:filters';

  static const _itemsField = 'items';
  static const _metaField = 'meta';

  final CacheStore _store;

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

  Future<void> clearLists() => _store.deleteWhereKeyStartsWith(_listPrefix);

  Future<void> writeProduct(ProductModel product) =>
      _store.write('$_detailPrefix${product.slug}', product.toJson());

  ProductModel? readProduct(String slug) =>
      _store.read('$_detailPrefix$slug', (json) {
        if (json is! Map<String, dynamic>) {
          throw const FormatException('Expected an object');
        }
        return ProductModel.fromJson(json);
      });

  Future<void> writeCollection(String name, List<ProductModel> items) =>
      _store.write(
        '$_collectionPrefix$name',
        items.map((item) => item.toJson()).toList(growable: false),
      );

  List<ProductModel> readCollection(String name) => _store.readList(
        '$_collectionPrefix$name',
        (json) => ProductModel.fromJson(json! as Map<String, dynamic>),
      );

  Future<void> writeFilters(ProductFiltersModel filters) =>
      _store.write(_filtersKey, filters.toJson());

  ProductFiltersModel? readFilters() => _store.read(_filtersKey, (json) {
        if (json is! Map<String, dynamic>) {
          throw const FormatException('Expected an object');
        }
        return ProductFiltersModel.fromJson(json);
      });
}
