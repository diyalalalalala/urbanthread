import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/home_product.dart';

part 'home_product_model.g.dart';

/// Wire format for a product as the home rails receive it.
///
/// Scoped to the fields a card draws. The collection endpoints return plenty
/// more; decoding variants and specifications for a card that shows a name, a
/// price and a photo is work with no visible result.
///
/// Two API behaviours are handled here rather than in the widget:
///
/// * **The virtuals are gone.** `/products/featured`, `/trending`,
///   `/best-sellers` and `/new-arrivals` are `.lean()` reads, so
///   `primaryImage` and `inStock` are absent — not null, absent. The card
///   image is recomputed from `images` (primary first, then the first entry),
///   and stock from `totalStock`.
/// * **`category` and `brand` are polymorphic.** Populated objects on these
///   routes, bare ObjectId strings on others. The converters below tolerate
///   either so one model survives both.
@JsonSerializable()
class HomeProductModel {
  const HomeProductModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    this.discountPercentage = 0,
    this.effectivePrice,
    this.images = const [],
    this.rating,
    this.totalStock = 0,
    this.category,
    this.brand,
    this.isFeatured = false,
    this.isNewArrival = false,
  });

  factory HomeProductModel.fromJson(Map<String, dynamic> json) =>
      _$HomeProductModelFromJson(json);

  @JsonKey(name: '_id')
  final String id;
  final String name;

  /// Product detail is slug-only, so this is not optional on a card.
  final String slug;

  final num price;
  final num discountPercentage;

  /// Server-computed post-discount price. Nullable because the field is a
  /// Mongoose virtual on some responses; [toEntity] falls back to computing
  /// it from `price` and `discountPercentage`.
  final num? effectivePrice;

  final List<ProductImageModel> images;
  final RatingModel? rating;
  final int totalStock;

  @JsonKey(fromJson: _refFromJson)
  final ProductRefModel? category;

  @JsonKey(fromJson: _refFromJson)
  final ProductRefModel? brand;

  final bool isFeatured;
  final bool isNewArrival;

  Map<String, dynamic> toJson() => _$HomeProductModelToJson(this);

  /// The image a card should draw: the one flagged primary, else the first
  /// uploaded, else nothing.
  ///
  /// This ordering mirrors what the `primaryImage` virtual does server-side.
  /// Reimplementing it is not duplication for its own sake — the virtual is
  /// simply not in the payload on these routes, and a card with no image
  /// where one exists is a visible bug.
  String? get cardImageUrl {
    if (images.isEmpty) return null;
    for (final image in images) {
      if (image.isPrimary && image.url.trim().isNotEmpty) return image.url;
    }
    final first = images.first.url.trim();
    return first.isEmpty ? null : first;
  }

  HomeProduct toEntity() => HomeProduct(
        id: id,
        name: name,
        slug: slug,
        price: price,
        effectivePrice: effectivePrice ?? _discounted(),
        discountPercentage: discountPercentage,
        imageUrl: cardImageUrl,
        ratingAverage: rating?.average ?? 0,
        ratingCount: rating?.count ?? 0,
        totalStock: totalStock,
        categoryName: category?.name,
        categorySlug: category?.slug,
        brandName: brand?.name,
        brandSlug: brand?.slug,
        isFeatured: isFeatured,
        isNewArrival: isNewArrival,
      );

  /// Last-resort price when the server did not send `effectivePrice`.
  ///
  /// Kept identical to the backend's own formula so the two never disagree by
  /// a rupee on the same product.
  num _discounted() => discountPercentage <= 0
      ? price
      : price - (price * discountPercentage / 100);
}

@JsonSerializable()
class ProductImageModel {
  const ProductImageModel({
    this.id,
    this.url = '',
    this.publicId = '',
    this.alt = '',
    this.isPrimary = false,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) =>
      _$ProductImageModelFromJson(json);

  @JsonKey(name: '_id')
  final String? id;
  final String url;
  final String publicId;
  final String alt;
  final bool isPrimary;

  Map<String, dynamic> toJson() => _$ProductImageModelToJson(this);
}

/// `rating` is a nested object — `rating.average` / `rating.count` — not two
/// flat fields, and not a bare number.
@JsonSerializable()
class RatingModel {
  const RatingModel({this.average = 0, this.count = 0});

  factory RatingModel.fromJson(Map<String, dynamic> json) =>
      _$RatingModelFromJson(json);

  final num average;
  final int count;

  Map<String, dynamic> toJson() => _$RatingModelToJson(this);
}

/// The populated form of a `category` or `brand` reference.
@JsonSerializable()
class ProductRefModel {
  const ProductRefModel({required this.id, this.name = '', this.slug = ''});

  factory ProductRefModel.fromJson(Map<String, dynamic> json) =>
      _$ProductRefModelFromJson(json);

  @JsonKey(name: '_id')
  final String id;
  final String name;
  final String slug;

  Map<String, dynamic> toJson() => _$ProductRefModelToJson(this);
}

/// Accepts either a populated reference object or a bare ObjectId string.
///
/// A bare id yields a reference with an empty name and slug, which the card
/// renders as "no brand shown" rather than as a broken link — better than
/// crashing on a response shape the endpoint is entitled to return.
ProductRefModel? _refFromJson(Object? raw) => switch (raw) {
      Map<String, dynamic> value => ProductRefModel.fromJson(value),
      String value when value.isNotEmpty => ProductRefModel(id: value),
      _ => null,
    };
