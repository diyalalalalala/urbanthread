// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_filters_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductFiltersModel _$ProductFiltersModelFromJson(
  Map<String, dynamic> json,
) => ProductFiltersModel(
  colors:
      (json['colors'] as List<dynamic>?)
          ?.map((e) => ColorFacetModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  sizes:
      (json['sizes'] as List<dynamic>?)
          ?.map((e) => FacetValueModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  brands:
      (json['brands'] as List<dynamic>?)
          ?.map((e) => ReferenceFacetModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => ReferenceFacetModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  tags:
      (json['tags'] as List<dynamic>?)
          ?.map((e) => FacetValueModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  priceRange: json['priceRange'] == null
      ? const PriceRangeModel()
      : PriceRangeModel.fromJson(json['priceRange'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProductFiltersModelToJson(
  ProductFiltersModel instance,
) => <String, dynamic>{
  'colors': instance.colors,
  'sizes': instance.sizes,
  'brands': instance.brands,
  'categories': instance.categories,
  'tags': instance.tags,
  'priceRange': instance.priceRange,
};

FacetValueModel _$FacetValueModelFromJson(Map<String, dynamic> json) =>
    FacetValueModel(
      name: json['name'] as String,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$FacetValueModelToJson(FacetValueModel instance) =>
    <String, dynamic>{'name': instance.name, 'count': instance.count};

ColorFacetModel _$ColorFacetModelFromJson(Map<String, dynamic> json) =>
    ColorFacetModel(
      name: json['name'] as String,
      hex: json['hex'] as String? ?? '#000000',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ColorFacetModelToJson(ColorFacetModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'hex': instance.hex,
      'count': instance.count,
    };

ReferenceFacetModel _$ReferenceFacetModelFromJson(Map<String, dynamic> json) =>
    ReferenceFacetModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ReferenceFacetModelToJson(
  ReferenceFacetModel instance,
) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'slug': instance.slug,
  'count': instance.count,
};

PriceRangeModel _$PriceRangeModelFromJson(Map<String, dynamic> json) =>
    PriceRangeModel(
      min: (json['min'] as num?)?.toDouble() ?? 0,
      max: (json['max'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$PriceRangeModelToJson(PriceRangeModel instance) =>
    <String, dynamic>{'min': instance.min, 'max': instance.max};
