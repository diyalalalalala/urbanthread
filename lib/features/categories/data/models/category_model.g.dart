// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    CategoryModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String? ?? '',
      image: json['image'] == null
          ? null
          : ImageRefModel.fromJson(json['image'] as Map<String, dynamic>),
      parent: _parentId(json['parent']),
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
      productCount: (json['productCount'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$CategoryModelToJson(CategoryModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'image': instance.image,
      'parent': instance.parent,
      'displayOrder': instance.displayOrder,
      'isActive': instance.isActive,
      'isFeatured': instance.isFeatured,
      'productCount': instance.productCount,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

ImageRefModel _$ImageRefModelFromJson(Map<String, dynamic> json) =>
    ImageRefModel(
      url: json['url'] as String? ?? '',
      publicId: json['publicId'] as String? ?? '',
    );

Map<String, dynamic> _$ImageRefModelToJson(ImageRefModel instance) =>
    <String, dynamic>{'url': instance.url, 'publicId': instance.publicId};
