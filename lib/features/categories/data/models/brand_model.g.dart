// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrandModel _$BrandModelFromJson(Map<String, dynamic> json) => BrandModel(
  id: json['_id'] as String,
  name: json['name'] as String,
  slug: json['slug'] as String,
  description: json['description'] as String? ?? '',
  logo: json['logo'] == null
      ? null
      : ImageRefModel.fromJson(json['logo'] as Map<String, dynamic>),
  website: json['website'] as String? ?? '',
  country: json['country'] as String? ?? '',
  isActive: json['isActive'] as bool? ?? true,
  isFeatured: json['isFeatured'] as bool? ?? false,
  displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$BrandModelToJson(BrandModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'logo': instance.logo,
      'website': instance.website,
      'country': instance.country,
      'isActive': instance.isActive,
      'isFeatured': instance.isFeatured,
      'displayOrder': instance.displayOrder,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
