// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeProductModel _$HomeProductModelFromJson(Map<String, dynamic> json) =>
    HomeProductModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      price: json['price'] as num,
      discountPercentage: json['discountPercentage'] as num? ?? 0,
      effectivePrice: json['effectivePrice'] as num?,
      images:
          (json['images'] as List<dynamic>?)
              ?.map(
                (e) => ProductImageModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      rating: json['rating'] == null
          ? null
          : RatingModel.fromJson(json['rating'] as Map<String, dynamic>),
      totalStock: (json['totalStock'] as num?)?.toInt() ?? 0,
      category: _refFromJson(json['category']),
      brand: _refFromJson(json['brand']),
      isFeatured: json['isFeatured'] as bool? ?? false,
      isNewArrival: json['isNewArrival'] as bool? ?? false,
    );

Map<String, dynamic> _$HomeProductModelToJson(HomeProductModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'price': instance.price,
      'discountPercentage': instance.discountPercentage,
      'effectivePrice': instance.effectivePrice,
      'images': instance.images,
      'rating': instance.rating,
      'totalStock': instance.totalStock,
      'category': instance.category,
      'brand': instance.brand,
      'isFeatured': instance.isFeatured,
      'isNewArrival': instance.isNewArrival,
    };

ProductImageModel _$ProductImageModelFromJson(Map<String, dynamic> json) =>
    ProductImageModel(
      id: json['_id'] as String?,
      url: json['url'] as String? ?? '',
      publicId: json['publicId'] as String? ?? '',
      alt: json['alt'] as String? ?? '',
      isPrimary: json['isPrimary'] as bool? ?? false,
    );

Map<String, dynamic> _$ProductImageModelToJson(ProductImageModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'url': instance.url,
      'publicId': instance.publicId,
      'alt': instance.alt,
      'isPrimary': instance.isPrimary,
    };

RatingModel _$RatingModelFromJson(Map<String, dynamic> json) => RatingModel(
  average: json['average'] as num? ?? 0,
  count: (json['count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$RatingModelToJson(RatingModel instance) =>
    <String, dynamic>{'average': instance.average, 'count': instance.count};

ProductRefModel _$ProductRefModelFromJson(Map<String, dynamic> json) =>
    ProductRefModel(
      id: json['_id'] as String,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );

Map<String, dynamic> _$ProductRefModelToJson(ProductRefModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
    };
