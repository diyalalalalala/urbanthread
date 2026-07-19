// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recently_viewed_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecentlyViewedModel _$RecentlyViewedModelFromJson(Map<String, dynamic> json) =>
    RecentlyViewedModel(
      id: json['_id'] as String? ?? '',
      product: ProductRefModel.fromJson(
        json['product'] as Map<String, dynamic>,
      ),
      viewedAt: json['viewedAt'] as String?,
    );

Map<String, dynamic> _$RecentlyViewedModelToJson(
  RecentlyViewedModel instance,
) => <String, dynamic>{
  '_id': instance.id,
  'product': instance.product,
  'viewedAt': instance.viewedAt,
};
