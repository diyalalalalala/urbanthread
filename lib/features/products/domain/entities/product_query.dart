import 'package:equatable/equatable.dart';

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

  final String wireValue;

  final String label;

  static ProductSort parse(String? raw) {
    for (final value in ProductSort.values) {
      if (value.wireValue == raw) return value;
    }
    return ProductSort.latest;
  }
}

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

  factory ProductQuery.fromQueryParameters(Map<String, String> params) {
    List<String> list(String key) {
      final raw = params[key]?.trim() ?? '';
      if (raw.isEmpty) return const [];
      return raw
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false);
    }

    String? text(String key) {
      final value = params[key]?.trim();
      return (value == null || value.isEmpty) ? null : value;
    }

    bool? flag(String key) => switch (params[key]?.toLowerCase()) {
          'true' || '1' => true,
          'false' || '0' => false,
          _ => null,
        };

    return ProductQuery(
      page: int.tryParse(params['page'] ?? '') ?? 1,
      limit: int.tryParse(params['limit'] ?? '') ?? defaultLimit,
      search: text('search'),
      category: text('category'),
      brands: list('brand'),
      sizes: list('size'),
      colors: list('color'),
      tags: list('tags'),
      minPrice: double.tryParse(params['minPrice'] ?? ''),
      maxPrice: double.tryParse(params['maxPrice'] ?? ''),
      minRating: double.tryParse(params['minRating'] ?? ''),
      inStock: flag('inStock'),
      hasDiscount: flag('hasDiscount'),
      minDiscount: double.tryParse(params['minDiscount'] ?? ''),
      isFeatured: flag('isFeatured'),
      isNewArrival: flag('isNewArrival'),
      sort: ProductSort.parse(params['sort']),
    );
  }

  static const defaultLimit = 20;

  final int page;
  final int limit;

  final String? search;

  final String? category;

  final List<String> brands;
  final List<String> sizes;
  final List<String> colors;
  final List<String> tags;

  final double? minPrice;
  final double? maxPrice;

  final double? minRating;
  final bool? inStock;
  final bool? hasDiscount;
  final double? minDiscount;
  final bool? isFeatured;
  final bool? isNewArrival;
  final ProductSort sort;

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

  String get cacheKey {
    final params = toQueryParameters();
    final keys = params.keys.toList()..sort();
    final encoded = keys.map((key) => '$key=${params[key]}').join('&');
    return 'products:list:$encoded';
  }

  bool get hasActiveFilters => activeFilterCount > 0;

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

  ProductQuery reset() => copyWith(page: 1);

  ProductQuery nextPage() => copyWith(page: page + 1);

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
    bool clearIsFeatured = false,
    bool? isNewArrival,
    bool clearIsNewArrival = false,
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
        isFeatured: clearIsFeatured ? null : (isFeatured ?? this.isFeatured),
        isNewArrival:
            clearIsNewArrival ? null : (isNewArrival ?? this.isNewArrival),
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
