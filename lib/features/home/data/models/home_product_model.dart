import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/home_product.dart';

part 'home_product_model.g.dart';

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

  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  @JsonKey(defaultValue: '')
  final String name;

  @JsonKey(defaultValue: '')
  final String slug;

  @JsonKey(defaultValue: 0)
  final num price;
  final num discountPercentage;

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

  bool get isRenderable =>
      id.isNotEmpty && name.isNotEmpty && slug.isNotEmpty;

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

@JsonSerializable()
class RatingModel {
  const RatingModel({this.average = 0, this.count = 0});

  factory RatingModel.fromJson(Map<String, dynamic> json) =>
      _$RatingModelFromJson(json);

  final num average;
  final int count;

  Map<String, dynamic> toJson() => _$RatingModelToJson(this);
}

@JsonSerializable()
class ProductRefModel {
  const ProductRefModel({required this.id, this.name = '', this.slug = ''});

  factory ProductRefModel.fromJson(Map<String, dynamic> json) =>
      _$ProductRefModelFromJson(json);

  @JsonKey(name: '_id', defaultValue: '')
  final String id;
  final String name;
  final String slug;

  Map<String, dynamic> toJson() => _$ProductRefModelToJson(this);
}

ProductRefModel? _refFromJson(Object? raw) => switch (raw) {
      Map<String, dynamic> value => ProductRefModel.fromJson(value),
      String value when value.isNotEmpty => ProductRefModel(id: value),
      _ => null,
    };
