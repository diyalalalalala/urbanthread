import '../../../../core/network/api_envelope.dart';
import '../../../../core/storage/cache_store.dart';
import '../models/brand_model.dart';
import '../models/category_model.dart';

/// A page of models recovered from disk, with the paging metadata it was
/// stored alongside.
///
/// The metadata has to be cached too: without it an offline "load more" could
/// not know whether another page exists, and the list would either stop early
/// or spin forever on a page that will never arrive.
class CachedPage<M> {
  const CachedPage({required this.items, required this.meta});

  final List<M> items;
  final PaginationMeta meta;
}

/// The taxonomy's slice of the `catalogue` Hive box.
///
/// Everything here is public, disposable data — the box can be cleared at any
/// time and simply re-downloads, which is why categories and brands live in
/// `catalogue` rather than the account box that survives a logout.
///
/// Keys are namespaced with a `categories:` / `brands:` prefix so one family
/// can be invalidated wholesale via
/// [CacheStore.deleteWhereKeyStartsWith] without disturbing cached products.
class CategoriesLocalDataSource {
  const CategoriesLocalDataSource(this._cache);

  static const treeKey = 'categories:tree';
  static const featuredCategoriesKey = 'categories:featured';
  static const featuredBrandsKey = 'brands:featured';
  static const categoriesPrefix = 'categories:';
  static const brandsPrefix = 'brands:';

  /// How long a cached taxonomy is considered current.
  ///
  /// Generous on purpose: categories and brands change on a merchandising
  /// cadence measured in weeks, not minutes. The TTL only decides whether a
  /// *background* refresh fires — [CacheStore.read] hands back stale data
  /// either way, so a long TTL costs freshness, never availability.
  static const ttl = Duration(hours: 6);

  final CacheStore _cache;

  // ── Tree ─────────────────────────────────────────────────────────────────

  List<CategoryNodeModel> readTree() => _cache.readList(
        treeKey,
        (json) => CategoryNodeModel.fromJson(json! as Map<String, dynamic>),
      );

  Future<void> writeTree(List<CategoryNodeModel> nodes) => _cache.write(
        treeKey,
        nodes.map((node) => node.toJson()).toList(growable: false),
      );

  bool get isTreeStale => _cache.isStale(treeKey, ttl);

  // ── Single category / brand ──────────────────────────────────────────────

  static String categoryKey(String slugOrId) => 'categories:item:$slugOrId';

  static String brandKey(String slugOrId) => 'brands:item:$slugOrId';

  CategoryNodeModel? readCategory(String slugOrId) => _cache.read(
        categoryKey(slugOrId),
        (json) => CategoryNodeModel.fromJson(json! as Map<String, dynamic>),
      );

  Future<void> writeCategory(String slugOrId, CategoryNodeModel node) =>
      _cache.write(categoryKey(slugOrId), node.toJson());

  BrandModel? readBrand(String slugOrId) => _cache.read(
        brandKey(slugOrId),
        (json) => BrandModel.fromJson(json! as Map<String, dynamic>),
      );

  Future<void> writeBrand(String slugOrId, BrandModel brand) =>
      _cache.write(brandKey(slugOrId), brand.toJson());

  // ── Featured strips ──────────────────────────────────────────────────────

  List<CategoryModel> readFeaturedCategories() => _cache.readList(
        featuredCategoriesKey,
        (json) => CategoryModel.fromJson(json! as Map<String, dynamic>),
      );

  Future<void> writeFeaturedCategories(List<CategoryModel> categories) =>
      _cache.write(
        featuredCategoriesKey,
        categories.map((category) => category.toJson()).toList(growable: false),
      );

  List<BrandModel> readFeaturedBrands() => _cache.readList(
        featuredBrandsKey,
        (json) => BrandModel.fromJson(json! as Map<String, dynamic>),
      );

  Future<void> writeFeaturedBrands(List<BrandModel> brands) => _cache.write(
        featuredBrandsKey,
        brands.map((brand) => brand.toJson()).toList(growable: false),
      );

  // ── Paginated lists ──────────────────────────────────────────────────────

  /// A cache key that encodes every parameter that changes the result.
  ///
  /// Omitting one would make two different queries collide and serve each
  /// other's rows — the classic way a "filtered" list quietly shows the
  /// unfiltered catalogue from cache.
  static String categoriesPageKey({
    required int page,
    required int limit,
    String? search,
    String? parent,
    bool? isFeatured,
  }) =>
      'categories:list:$page:$limit:${search ?? ''}:${parent ?? ''}:'
      '${isFeatured ?? ''}';

  static String brandsPageKey({
    required int page,
    required int limit,
    String? search,
    bool? isFeatured,
  }) =>
      'brands:list:$page:$limit:${search ?? ''}:${isFeatured ?? ''}';

  CachedPage<CategoryModel>? readCategoryPage(String key) =>
      _readPage(key, CategoryModel.fromJson);

  Future<void> writeCategoryPage(
    String key,
    List<CategoryModel> items,
    PaginationMeta meta,
  ) =>
      _writePage(
        key,
        items.map((item) => item.toJson()).toList(growable: false),
        meta,
      );

  CachedPage<BrandModel>? readBrandPage(String key) =>
      _readPage(key, BrandModel.fromJson);

  Future<void> writeBrandPage(
    String key,
    List<BrandModel> items,
    PaginationMeta meta,
  ) =>
      _writePage(
        key,
        items.map((item) => item.toJson()).toList(growable: false),
        meta,
      );

  /// The first page of brands, whatever filters it was stored under, so the
  /// browse screen has something to paint before its own request returns.
  List<BrandModel> readFirstBrandPage() =>
      readBrandPage(brandsPageKey(page: 1, limit: _browseLimit))?.items ??
      const [];

  /// Matches the page size the categories screen asks for; the key has to
  /// agree with the request or the read misses.
  static const _browseLimit = 50;

  static int get browseLimit => _browseLimit;

  Future<void> clear() async {
    await _cache.deleteWhereKeyStartsWith(categoriesPrefix);
    await _cache.deleteWhereKeyStartsWith(brandsPrefix);
  }

  CachedPage<M>? _readPage<M>(
    String key,
    M Function(Map<String, dynamic> json) fromJson,
  ) =>
      _cache.read(key, (json) {
        if (json is! Map<String, dynamic>) {
          throw const FormatException('Expected a cached page object');
        }
        final items = (json['items'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(fromJson)
            .toList(growable: false);
        final rawMeta = json['meta'];
        return CachedPage<M>(
          items: items,
          meta: rawMeta is Map<String, dynamic>
              ? PaginationMeta.fromJson(rawMeta)
              : PaginationMeta.single(items.length),
        );
      });

  Future<void> _writePage(
    String key,
    List<Map<String, dynamic>> items,
    PaginationMeta meta,
  ) =>
      _cache.write(key, {'items': items, 'meta': meta.toJson()});
}
