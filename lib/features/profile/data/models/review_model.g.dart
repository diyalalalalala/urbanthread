// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewModel _$ReviewModelFromJson(Map<String, dynamic> json) => ReviewModel(
  id: json['_id'] as String? ?? '',
  product: json['product'],
  userName: json['userName'] as String? ?? '',
  userAvatar: json['userAvatar'] as String? ?? '',
  rating: (json['rating'] as num?)?.toInt() ?? 0,
  title: json['title'] as String? ?? '',
  comment: json['comment'] as String? ?? '',
  isVerifiedPurchase: json['isVerifiedPurchase'] as bool? ?? false,
  status: json['status'] as String? ?? 'approved',
  moderationNote: json['moderationNote'] as String? ?? '',
  helpfulCount: (json['helpfulCount'] as num?)?.toInt() ?? 0,
  isEdited: json['isEdited'] as bool? ?? false,
  editedAt: json['editedAt'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$ReviewModelToJson(ReviewModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'product': instance.product,
      'userName': instance.userName,
      'userAvatar': instance.userAvatar,
      'rating': instance.rating,
      'title': instance.title,
      'comment': instance.comment,
      'isVerifiedPurchase': instance.isVerifiedPurchase,
      'status': instance.status,
      'moderationNote': instance.moderationNote,
      'helpfulCount': instance.helpfulCount,
      'isEdited': instance.isEdited,
      'editedAt': instance.editedAt,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

ReviewableProductModel _$ReviewableProductModelFromJson(
  Map<String, dynamic> json,
) => ReviewableProductModel(
  product: json['product'] as String? ?? '',
  productName: json['productName'] as String? ?? '',
  slug: json['slug'] as String? ?? '',
  image: json['image'] as String? ?? '',
  brandName: json['brandName'] as String? ?? '',
  order: json['order'] as String? ?? '',
  orderNumber: json['orderNumber'] as String? ?? '',
  deliveredAt: json['deliveredAt'] as String?,
);

Map<String, dynamic> _$CreateReviewRequestToJson(
  CreateReviewRequest instance,
) => <String, dynamic>{
  'product': instance.product,
  'rating': instance.rating,
  'comment': instance.comment,
  'title': ?instance.title,
};

Map<String, dynamic> _$UpdateReviewRequestToJson(
  UpdateReviewRequest instance,
) => <String, dynamic>{
  'rating': ?instance.rating,
  'title': ?instance.title,
  'comment': ?instance.comment,
};
