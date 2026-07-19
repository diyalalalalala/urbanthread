import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/media_url.dart';
import '../../domain/entities/product.dart';

part 'product_model.g.dart';

/// Wire format for a catalogue product.
///
/// One model serves every product-bearing endpoint, which means it has to
/// tolerate three shapes of the same document:
///
/// 1. **Hydrated** (`GET /products/{slug}`) — carries the Mongoose virtuals
///    `primaryImage`, `inStock`, `isLowStock`, `availableColors`,
///    `availableSizes`.
/// 2. **Lean** (`/products`, `/products/search`, the collections) — the same
///    stored fields with every virtual stripped, plus a `score` on a search
///    with a term of three characters or more.
/// 3. **Aggregated** (`/products/{id}/frequently-bought-together`) — a raw
///    `$lookup` document in which `category` and `brand` are bare ObjectId
///    *strings* rather than populated objects.
///
/// Everything conditional is therefore nullable, and [toEntity] hands the
/// domain an object whose getters compute a fallback for each virtual. See
/// [Product] for those.
@JsonSerializable(createToJson: true)
class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    this.description = '',
    this.shortDescription = '',
    this.category,
    this.brand,
    this.discountPercentage = 0,
    this.effectivePrice,
    this.images = const [],
    this.variants = const [],
    this.totalStock = 0,
    this.specifications = const {},
    this.tags = const [],
    this.rating = const RatingModel(),
    this.soldCount = 0,
    this.viewCount = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.isNewArrival = false,
    this.createdAt,
    this.primaryImage,
    this.inStock,
    this.isLowStock,
    this.availableColors,
    this.availableSizes,
    this.score,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  @JsonKey(name: '_id')
  final String id;
  final String name;
  final String slug;
  final String description;
  final String shortDescription;

  @CategoryRefConverter()
  final CategoryRefModel? category;

  @BrandRefConverter()
  final BrandRefModel? brand;

  final double price;
  final double discountPercentage;
  final double? effectivePrice;
  final List<ProductImageModel> images;
  final List<ProductVariantModel> variants;
  final int totalStock;

  /// A Mongo `Map` of String, which lands as a plain JSON object.
  final Map<String, String> specifications;

  final List<String> tags;
  final RatingModel rating;
  final int soldCount;
  final int viewCount;
  final bool isActive;
  final bool isFeatured;
  final bool isNewArrival;
  final String? createdAt;

  /// Virtuals — present only on the hydrated detail response. Note
  /// `primaryImage` resolves to the image *URL*, not to the image object.
  final String? primaryImage;
  final bool? inStock;
  final bool? isLowStock;
  final List<ProductColorModel>? availableColors;
  final List<String>? availableSizes;

  /// Text-search relevance, projected by `$meta: 'textScore'`. Only present
  /// on `/products/search` with a term of at least three characters.
  final double? score;

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  Product toEntity() => Product(
        id: id,
        name: name,
        slug: slug,
        description: description,
        shortDescription: shortDescription,
        category: category?.toEntity(),
        brand: brand?.toEntity(),
        price: price,
        discountPercentage: discountPercentage,
        effectivePrice: effectivePrice,
        images: images.map((image) => image.toEntity()).toList(growable: false),
        variants:
            variants.map((variant) => variant.toEntity()).toList(growable: false),
        totalStock: totalStock,
        specifications: specifications,
        tags: tags,
        rating: rating.toEntity(),
        soldCount: soldCount,
        viewCount: viewCount,
        isActive: isActive,
        isFeatured: isFeatured,
        isNewArrival: isNewArrival,
        createdAt: parseApiDate(createdAt),
        primaryImage: MediaUrl.resolve(primaryImage),
        rawInStock: inStock,
        rawIsLowStock: isLowStock,
        rawAvailableColors: availableColors
            ?.map((color) => color.toEntity())
            .toList(growable: false),
        rawAvailableSizes: availableSizes,
        searchScore: score,
      );
}

@JsonSerializable()
class ProductImageModel {
  const ProductImageModel({
    this.id = '',
    this.url = '',
    this.publicId = '',
    this.alt = '',
    this.isPrimary = false,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) =>
      _$ProductImageModelFromJson(json);

  @JsonKey(name: '_id')
  final String id;

  /// Absolute, and built from the backend's own `SERVER_URL` — so it can say
  /// `localhost`. Re-based in [toEntity].
  final String url;
  final String publicId;
  final String alt;
  final bool isPrimary;

  Map<String, dynamic> toJson() => _$ProductImageModelToJson(this);

  ProductImage toEntity() => ProductImage(
        id: id,
        url: MediaUrl.resolve(url),
        alt: alt,
        isPrimary: isPrimary,
      );
}

@JsonSerializable()
class ProductColorModel {
  const ProductColorModel({required this.name, this.hex = '#000000'});

  factory ProductColorModel.fromJson(Map<String, dynamic> json) =>
      _$ProductColorModelFromJson(json);

  final String name;
  final String hex;

  Map<String, dynamic> toJson() => _$ProductColorModelToJson(this);

  ProductColor toEntity() => ProductColor(name: name, hex: hex);
}

@JsonSerializable()
class ProductVariantModel {
  const ProductVariantModel({
    required this.color,
    required this.size,
    this.id = '',
    this.sku = '',
    this.stock = 0,
    this.priceOverride,
    this.isActive = true,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) =>
      _$ProductVariantModelFromJson(json);

  @JsonKey(name: '_id')
  final String id;
  final ProductColorModel color;
  final String size;
  final String sku;
  final int stock;

  /// Null means "use the product price" — a real null in the schema, not the
  /// empty-string sentinel used elsewhere in this API.
  final double? priceOverride;

  final bool isActive;

  Map<String, dynamic> toJson() => _$ProductVariantModelToJson(this);

  ProductVariant toEntity() => ProductVariant(
        id: id,
        color: color.toEntity(),
        size: size,
        sku: sku,
        stock: stock,
        priceOverride: priceOverride,
        isActive: isActive,
      );
}

/// The denormalised rating block on a product.
@JsonSerializable()
class RatingModel {
  const RatingModel({
    this.average = 0,
    this.count = 0,
    this.distribution = const {},
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) =>
      _$RatingModelFromJson(json);

  final double average;
  final int count;

  /// Keys arrive as the **strings** "1".."5" — Mongo serialises the nested
  /// histogram as an object, and JSON object keys are always strings.
  final Map<String, int> distribution;

  Map<String, dynamic> toJson() => _$RatingModelToJson(this);

  ProductRating toEntity() => ProductRating(
        average: average,
        count: count,
        distribution: parseStarDistribution(distribution),
      );
}

/// Populated category reference.
@JsonSerializable()
class CategoryRefModel {
  const CategoryRefModel({required this.id, this.name = '', this.slug = ''});

  factory CategoryRefModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryRefModelFromJson(json);

  @JsonKey(name: '_id')
  final String id;
  final String name;
  final String slug;

  Map<String, dynamic> toJson() => _$CategoryRefModelToJson(this);

  CategoryRef toEntity() => CategoryRef(id: id, name: name, slug: slug);
}

/// Populated brand reference. `logo` is an object with an empty-string URL
/// when the brand has no mark.
@JsonSerializable()
class BrandRefModel {
  const BrandRefModel({
    required this.id,
    this.name = '',
    this.slug = '',
    this.logo,
  });

  factory BrandRefModel.fromJson(Map<String, dynamic> json) =>
      _$BrandRefModelFromJson(json);

  @JsonKey(name: '_id')
  final String id;
  final String name;
  final String slug;
  final BrandLogoModel? logo;

  Map<String, dynamic> toJson() => _$BrandRefModelToJson(this);

  BrandRef toEntity() => BrandRef(
        id: id,
        name: name,
        slug: slug,
        logoUrl: MediaUrl.resolve(logo?.url),
      );
}

@JsonSerializable()
class BrandLogoModel {
  const BrandLogoModel({this.url = '', this.publicId = ''});

  factory BrandLogoModel.fromJson(Map<String, dynamic> json) =>
      _$BrandLogoModelFromJson(json);

  final String url;
  final String publicId;

  Map<String, dynamic> toJson() => _$BrandLogoModelToJson(this);
}

/// One entry of `/products/{id}/frequently-bought-together`.
///
/// The wrapper is projected with `_id: 0`, so it has no id of its own — the
/// nested product is the only identity available.
@JsonSerializable(createToJson: true)
class FrequentlyBoughtTogetherModel {
  const FrequentlyBoughtTogetherModel({
    required this.product,
    this.coPurchaseCount = 0,
  });

  factory FrequentlyBoughtTogetherModel.fromJson(Map<String, dynamic> json) =>
      _$FrequentlyBoughtTogetherModelFromJson(json);

  final ProductModel product;
  final int coPurchaseCount;

  Map<String, dynamic> toJson() => _$FrequentlyBoughtTogetherModelToJson(this);

  FrequentlyBoughtTogether toEntity() => FrequentlyBoughtTogether(
        product: product.toEntity(),
        coPurchaseCount: coPurchaseCount,
      );
}

/// Reads `category`, which is a populated object on most routes and a bare
/// ObjectId string on the aggregated recommendation route.
///
/// A converter rather than a `dynamic` field so the polymorphism is handled
/// once, at the boundary, instead of at every read site.
class CategoryRefConverter
    implements JsonConverter<CategoryRefModel?, Object?> {
  const CategoryRefConverter();

  @override
  CategoryRefModel? fromJson(Object? json) => switch (json) {
        // Bare id: keep the identity, leave name/slug empty. `isResolved` on
        // the entity tells the UI not to render a label it does not have.
        final String id when id.isNotEmpty => CategoryRefModel(id: id),
        final Map<String, dynamic> map => CategoryRefModel.fromJson(map),
        _ => null,
      };

  @override
  Object? toJson(CategoryRefModel? value) => value?.toJson();
}

class BrandRefConverter implements JsonConverter<BrandRefModel?, Object?> {
  const BrandRefConverter();

  @override
  BrandRefModel? fromJson(Object? json) => switch (json) {
        final String id when id.isNotEmpty => BrandRefModel(id: id),
        final Map<String, dynamic> map => BrandRefModel.fromJson(map),
        _ => null,
      };

  @override
  Object? toJson(BrandRefModel? value) => value?.toJson();
}

/// Converts the string-keyed star histogram to int keys, dropping any key
/// that is not a number rather than throwing — a shape change in the API
/// should degrade the histogram, not break the product page.
Map<int, int> parseStarDistribution(Map<String, int> raw) {
  final result = <int, int>{};
  for (final entry in raw.entries) {
    final star = int.tryParse(entry.key);
    if (star != null) result[star] = entry.value;
  }
  return result;
}

/// ISO-8601 to [DateTime]. Empty is treated as absent, matching the API's
/// habit of using `""` where null would be expected.
DateTime? parseApiDate(String? raw) =>
    (raw == null || raw.isEmpty) ? null : DateTime.tryParse(raw);
