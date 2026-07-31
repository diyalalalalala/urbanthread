import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/media_url.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/reviewable_product.dart';
import 'product_ref_model.dart';

part 'review_model.g.dart';

@JsonSerializable()
class ReviewModel {
  const ReviewModel({
    required this.id,
    this.product,
    this.userName = '',
    this.userAvatar = '',
    this.rating = 0,
    this.title = '',
    this.comment = '',
    this.isVerifiedPurchase = false,
    this.status = 'approved',
    this.moderationNote = '',
    this.helpfulCount = 0,
    this.isEdited = false,
    this.editedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);

  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  @JsonKey(name: 'product')
  final Object? product;

  final String userName;

  final String userAvatar;

  final int rating;
  final String title;
  final String comment;
  final bool isVerifiedPurchase;
  final String status;
  final String moderationNote;
  final int helpfulCount;
  final bool isEdited;
  final String? editedAt;
  final String? createdAt;
  final String? updatedAt;

  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);

  Review toEntity() {
    final raw = product;
    final populated = raw is Map
        ? ProductRefModel.fromJson(Map<String, dynamic>.from(raw))
        : null;

    return Review(
      id: id,
      productId: raw is String ? raw : (populated?.id ?? ''),
      product: populated?.toEntity(),
      userName: userName,
      userAvatarUrl: MediaUrl.resolve(userAvatar),
      rating: rating,
      title: title,
      comment: comment,
      isVerifiedPurchase: isVerifiedPurchase,
      status: ReviewStatus.parse(status),
      moderationNote: moderationNote,
      helpfulCount: helpfulCount,
      isEdited: isEdited,
      editedAt: _parseDate(editedAt),
      createdAt: _parseDate(createdAt),
      updatedAt: _parseDate(updatedAt),
    );
  }
}

@JsonSerializable(createToJson: false)
class ReviewableProductModel {
  const ReviewableProductModel({
    this.product = '',
    this.productName = '',
    this.slug = '',
    this.image = '',
    this.brandName = '',
    this.order = '',
    this.orderNumber = '',
    this.deliveredAt,
  });

  factory ReviewableProductModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewableProductModelFromJson(json);

  final String product;

  final String productName;
  final String slug;

  final String image;

  final String brandName;
  final String order;
  final String orderNumber;
  final String? deliveredAt;

  ReviewableProduct toEntity() => ReviewableProduct(
        productId: product,
        productName: productName,
        slug: slug,
        imageUrl: MediaUrl.resolve(image),
        brandName: brandName,
        orderId: order,
        orderNumber: orderNumber,
        deliveredAt: _parseDate(deliveredAt),
      );
}

@JsonSerializable(createFactory: false, includeIfNull: false)
class CreateReviewRequest {
  const CreateReviewRequest({
    required this.product,
    required this.rating,
    required this.comment,
    this.title,
  });

  final String product;
  final int rating;
  final String comment;

  final String? title;

  Map<String, dynamic> toJson() => _$CreateReviewRequestToJson(this);
}

@JsonSerializable(createFactory: false, includeIfNull: false)
class UpdateReviewRequest {
  const UpdateReviewRequest({this.rating, this.title, this.comment});

  final int? rating;
  final String? title;
  final String? comment;

  Map<String, dynamic> toJson() => _$UpdateReviewRequestToJson(this);
}

DateTime? _parseDate(String? raw) =>
    (raw == null || raw.isEmpty) ? null : DateTime.tryParse(raw);
