// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewModel _$ReviewModelFromJson(Map<String, dynamic> json) => ReviewModel(
  id: json['_id'] as String,
  product: const ProductIdConverter().fromJson(json['product']),
  rating: (json['rating'] as num).toInt(),
  userName: json['userName'] as String? ?? '',
  userAvatar: json['userAvatar'] as String? ?? '',
  title: json['title'] as String? ?? '',
  comment: json['comment'] as String? ?? '',
  isVerifiedPurchase: json['isVerifiedPurchase'] as bool? ?? false,
  helpfulCount: (json['helpfulCount'] as num?)?.toInt() ?? 0,
  isEdited: json['isEdited'] as bool? ?? false,
  editedAt: json['editedAt'] as String?,
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$ReviewModelToJson(ReviewModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'product': const ProductIdConverter().toJson(instance.product),
      'userName': instance.userName,
      'userAvatar': instance.userAvatar,
      'rating': instance.rating,
      'title': instance.title,
      'comment': instance.comment,
      'isVerifiedPurchase': instance.isVerifiedPurchase,
      'helpfulCount': instance.helpfulCount,
      'isEdited': instance.isEdited,
      'editedAt': instance.editedAt,
      'createdAt': instance.createdAt,
    };

ReviewStatsModel _$ReviewStatsModelFromJson(Map<String, dynamic> json) =>
    ReviewStatsModel(
      average: (json['average'] as num?)?.toDouble() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
      distribution:
          (json['distribution'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$ReviewStatsModelToJson(ReviewStatsModel instance) =>
    <String, dynamic>{
      'average': instance.average,
      'count': instance.count,
      'distribution': instance.distribution,
    };
