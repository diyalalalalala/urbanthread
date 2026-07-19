// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_ref_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductRefModel _$ProductRefModelFromJson(Map<String, dynamic> json) =>
    ProductRefModel(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      images: json['images'] == null ? const [] : _imageUrls(json['images']),
      price: json['price'] as num?,
      effectivePrice: json['effectivePrice'] as num?,
      discountPercentage: json['discountPercentage'] as num? ?? 0,
      rating: json['rating'] == null
          ? null
          : RatingRefModel.fromJson(json['rating'] as Map<String, dynamic>),
      totalStock: (json['totalStock'] as num?)?.toInt(),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$ProductRefModelToJson(ProductRefModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'images': _imageUrlsToJson(instance.images),
      'price': instance.price,
      'effectivePrice': instance.effectivePrice,
      'discountPercentage': instance.discountPercentage,
      'rating': instance.rating,
      'totalStock': instance.totalStock,
      'isActive': instance.isActive,
    };

RatingRefModel _$RatingRefModelFromJson(Map<String, dynamic> json) =>
    RatingRefModel(
      average: json['average'] as num? ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$RatingRefModelToJson(RatingRefModel instance) =>
    <String, dynamic>{'average': instance.average, 'count': instance.count};
