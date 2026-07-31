import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/media_url.dart';
import '../../domain/entities/review.dart';
import 'product_model.dart';

part 'review_model.g.dart';

@JsonSerializable(createToJson: true)
class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.product,
    required this.rating,
    this.userName = '',
    this.userAvatar = '',
    this.title = '',
    this.comment = '',
    this.isVerifiedPurchase = false,
    this.helpfulCount = 0,
    this.isEdited = false,
    this.editedAt,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);

  @JsonKey(name: '_id')
  final String id;

  @ProductIdConverter()
  final String product;

  final String userName;

  final String userAvatar;

  final int rating;
  final String title;
  final String comment;
  final bool isVerifiedPurchase;
  final int helpfulCount;
  final bool isEdited;
  final String? editedAt;
  final String? createdAt;

  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);

  Review toEntity() => Review(
        id: id,
        productId: product,
        userName: userName,
        userAvatarUrl: MediaUrl.resolve(userAvatar),
        rating: rating,
        title: title,
        comment: comment,
        isVerifiedPurchase: isVerifiedPurchase,
        helpfulCount: helpfulCount,
        isEdited: isEdited,
        editedAt: parseApiDate(editedAt),
        createdAt: parseApiDate(createdAt),
      );
}

@JsonSerializable(createToJson: true)
class ReviewStatsModel {
  const ReviewStatsModel({
    this.average = 0,
    this.count = 0,
    this.distribution = const {},
  });

  factory ReviewStatsModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewStatsModelFromJson(json);

  final double average;
  final int count;

  final Map<String, int> distribution;

  Map<String, dynamic> toJson() => _$ReviewStatsModelToJson(this);

  ReviewStats toEntity() => ReviewStats(
        average: average,
        count: count,
        distribution: parseStarDistribution(distribution),
      );
}

class ProductIdConverter implements JsonConverter<String, Object?> {
  const ProductIdConverter();

  @override
  String fromJson(Object? json) => switch (json) {
        final String id => id,
        final Map<String, dynamic> map => map['_id'] as String? ?? '',
        _ => '',
      };

  @override
  Object? toJson(String value) => value;
}
