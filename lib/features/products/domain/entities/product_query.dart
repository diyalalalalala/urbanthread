import 'package:equatable/equatable.dart';

/// Sort orders the catalogue endpoint accepts.
///
/// The wire values are a closed set — the backend validates against
/// `PRODUCT_SORT_VALUES` and answers anything else with a 422 rather than
/// falling back to a default, so a stringly-typed sort must never reach the
/// query builder.
enum ProductSort {
  latest('latest', 'Newest first'),
  oldest('oldest', 'Oldest first'),
  priceAsc('price_asc', 'Price: low to high'),
  priceDesc('price_desc', 'Price: high to low'),
  popularity('popularity', 'Most viewed'),
  rating('rating', 'Top rated'),
  bestSelling('best_selling', 'Best selling'),
  nameAsc('name_asc', 'Name: A to Z');

  const ProductSort(this.wireValue, this.label);

  /// The exact string the API expects.
  final String wireValue;

  /// Human label for the sort sheet.
  final String label;

  static ProductSort parse(String? raw) {
    for (final value in ProductSort.values) {
      if (value.wireValue == raw) return value;
    }
    return ProductSort.latest;
  }
}

/// Every parameter `GET /products` and `GET /products/search` understand.
///
/// Modelled as a value object rather than a bag of arguments for two reasons:
/// the filter sheet needs to hold a *draft* query it can discard, and the
/// offline cache needs a stable key per query, which [cacheKey] derives.
///
/// A parameter the validator does not list is silently dropped and the
/// request fails *open* — returning the unfiltered catalogue rather than an
/// error. So [toQueryParameters] is the only place these names are spelled,
/// and nothing else should build them.
class ProductQuery extends Equatable {
  const ProductQuery({
    this.page = 1,
    this.limit = defaultLimit,
    this.search,
    this.category,
    this.brands = const [],
    this.sizes = const [],
    this.colors = const [],
    this.tags = const [],
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.inStock,
    this.hasDiscount,
    this.minDiscount,
    this.isFeatured,
    this.isNewArrival,
    this.sort = ProductSort.latest,
  });

  static const defaultLimit = 20;

  final int page;
  final int limit;

  /// Full-text term. Below 3 characters the backend falls back to a name
  /// prefix match and omits the relevance score.
  final String? search;

  /// Single-valued, unlike the other facets: a slug or an id. Descendant
  /// categories are included server-side.
  final String? category;

  /// Multi-valued facets. Sent comma-separated, which is the form the
  /// validator's `csvToArray` sanitiser expects.
  final List<String> brands;
  final List<String> sizes;
  final List<String> colors;
  final List<String> tags;

  /// Bound `effectivePrice`, i.e. the post-discount price the customer pays.
  final double? minPrice;
  final double? maxPrice;

  final double? minRating;
  final bool? inStock;
  final bool? hasDiscount;
  final double? minDiscount;
  final bool? isFeatured;
  final bool? isNewArrival;
  final ProductSort sort;

  /// Query parameters for Dio, with absent values omitted entirely.
  ///
  /// Omission matters: sending `inStock=null` would serialise as an empty
  /// string, which `isBoolean()` rejects with a 422. Booleans go over as
  /// `'true'`/`'false'` strings because express-validator's `isBoolean` reads
  /// the raw query text.
  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{'page': page, 'limit': limit};

    void putString(String key, String? value) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) params[key] = trimmed;
    }

    void putList(String key, List<String> values) {
      final cleaned = values
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false);
      if (cleaned.isNotEmpty) params[key] = cleaned.join(',');
    }

    void putNum(String key, num? value) {
      if (value != null) params[key] = value;
    }

    void putBool(String key, bool? value) {
      if (value != null) params[key] = value ? 'true' : 'false';
    }

    putString('search', search);
    putString('category', category);
    putList('brand', brands);
    putList('size', sizes);
    putList('color', colors);
    putList('tags', tags);
    putNum('minPrice', minPrice);
    putNum('maxPrice', maxPrice);
    putNum('minRating', minRating);
    putBool('inStock', inStock);
    putBool('hasDiscount', hasDiscount);
    putNum('minDiscount', minDiscount);
    putBool('isFeatured', isFeatured);
    putBool('isNewArrival', isNewArrival);
    params['sort'] = sort.wireValue;

    return params;
  }

  /// A stable cache key for this query *including* its page, so consecutive
  /// scroll pages do not overwrite one another in Hive.
  ///
  /// Built from the serialised parameters with sorted keys so two queries
  /// that differ only in construction order share a cache entry.
  String get cacheKey {
    final params = toQueryParameters();
    final keys = params.keys.toList()..sort();
    final encoded = keys.map((key) => '$key=${params[key]}').join('&');
    return 'products:list:$encoded';
  }

  /// True when anything beyond paging and sorting narrows the result set.
  /// Drives the "filters active" dot on the toolbar.
  bool get hasActiveFilters => activeFilterCount > 0;

  /// How many distinct filters are applied, for the badge on the filter
  /// button. Each facet counts once however many values it holds — the user
  /// thinks in terms of "colour is filtered", not "three colours".
  int get activeFilterCount {
    var count = 0;
    if (category != null && category!.isNotEmpty) count++;
    if (brands.isNotEmpty) count++;
    if (sizes.isNotEmpty) count++;
    if (colors.isNotEmpty) count++;
    if (tags.isNotEmpty) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (minRating != null) count++;
    if (inStock == true) count++;
    if (hasDiscount == true || minDiscount != null) count++;
    if (isFeatured == true) count++;
    if (isNewArrival == true) count++;
    return count;
  }

  /// Back to page one, keeping every filter. Used whenever a facet or the
  /// sort changes — asking for page 4 of a freshly narrowed list would show
  /// an empty screen.
  ProductQuery reset() => copyWith(page: 1);

  ProductQuery nextPage() => copyWith(page: page + 1);

  /// Drops every facet but keeps the search term, category context and sort —
  /// "clear filters" should not also navigate the user out of the category
  /// they are browsing.
  ProductQuery clearFilters() => ProductQuery(
        page: 1,
        limit: limit,
        search: search,
        category: category,
        sort: sort,
      );

  ProductQuery copyWith({
    int? page,
    int? limit,
    String? search,
    bool clearSearch = false,
    String? category,
    bool clearCategory = false,
    List<String>? brands,
    List<String>? sizes,
    List<String>? colors,
    List<String>? tags,
    double? minPrice,
    double? maxPrice,
    bool clearPriceRange = false,
    double? minRating,
    bool clearMinRating = false,
    bool? inStock,
    bool clearInStock = false,
    bool? hasDiscount,
    bool clearHasDiscount = false,
    double? minDiscount,
    bool clearMinDiscount = false,
    bool? isFeatured,
    bool? isNewArrival,
    ProductSort? sort,
  }) =>
      ProductQuery(
        page: page ?? this.page,
        limit: limit ?? this.limit,
        search: clearSearch ? null : (search ?? this.search),
        category: clearCategory ? null : (category ?? this.category),
        brands: brands ?? this.brands,
        sizes: sizes ?? this.sizes,
        colors: colors ?? this.colors,
        tags: tags ?? this.tags,
        minPrice: clearPriceRange ? null : (minPrice ?? this.minPrice),
        maxPrice: clearPriceRange ? null : (maxPrice ?? this.maxPrice),
        minRating: clearMinRating ? null : (minRating ?? this.minRating),
        inStock: clearInStock ? null : (inStock ?? this.inStock),
        hasDiscount:
            clearHasDiscount ? null : (hasDiscount ?? this.hasDiscount),
        minDiscount:
            clearMinDiscount ? null : (minDiscount ?? this.minDiscount),
        isFeatured: isFeatured ?? this.isFeatured,
        isNewArrival: isNewArrival ?? this.isNewArrival,
        sort: sort ?? this.sort,
      );

  @override
  List<Object?> get props => [
        page,
        limit,
        search,
        category,
        brands,
        sizes,
        colors,
        tags,
        minPrice,
        maxPrice,
        minRating,
        inStock,
        hasDiscount,
        minDiscount,
        isFeatured,
        isNewArrival,
        sort,
      ];
}
