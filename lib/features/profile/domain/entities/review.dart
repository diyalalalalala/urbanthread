import 'package:equatable/equatable.dart';

import 'product_ref.dart';

enum ReviewStatus {
  pending,
  approved,
  rejected;

  static ReviewStatus parse(String? raw) => switch (raw?.toLowerCase()) {
        'pending' => ReviewStatus.pending,
        'rejected' => ReviewStatus.rejected,
        _ => ReviewStatus.approved,
      };

  String get label => switch (this) {
        ReviewStatus.pending => 'Awaiting moderation',
        ReviewStatus.approved => 'Published',
        ReviewStatus.rejected => 'Removed by moderator',
      };

  bool get isVisibleToOthers => this == ReviewStatus.approved;
}

class Review extends Equatable {
  const Review({
    required this.id,
    required this.productId,
    required this.rating,
    required this.comment,
    this.product,
    this.userName = '',
    this.userAvatarUrl,
    this.title = '',
    this.isVerifiedPurchase = false,
    this.status = ReviewStatus.approved,
    this.moderationNote = '',
    this.helpfulCount = 0,
    this.isEdited = false,
    this.editedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;

  final String productId;

  final ProductRef? product;

  final String userName;

  final String? userAvatarUrl;

  final int rating;

  final String title;

  final String comment;

  final bool isVerifiedPurchase;
  final ReviewStatus status;

  final String moderationNote;

  final int helpfulCount;
  final bool isEdited;
  final DateTime? editedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DateTime? get displayedAt => isEdited ? (editedAt ?? createdAt) : createdAt;

  Review copyWith({
    int? rating,
    String? title,
    String? comment,
    ReviewStatus? status,
    String? moderationNote,
    int? helpfulCount,
    bool? isEdited,
    DateTime? editedAt,
    DateTime? updatedAt,
  }) =>
      Review(
        id: id,
        productId: productId,
        product: product,
        userName: userName,
        userAvatarUrl: userAvatarUrl,
        rating: rating ?? this.rating,
        title: title ?? this.title,
        comment: comment ?? this.comment,
        isVerifiedPurchase: isVerifiedPurchase,
        status: status ?? this.status,
        moderationNote: moderationNote ?? this.moderationNote,
        helpfulCount: helpfulCount ?? this.helpfulCount,
        isEdited: isEdited ?? this.isEdited,
        editedAt: editedAt ?? this.editedAt,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [
        id,
        productId,
        product,
        userName,
        userAvatarUrl,
        rating,
        title,
        comment,
        isVerifiedPurchase,
        status,
        moderationNote,
        helpfulCount,
        isEdited,
        editedAt,
        createdAt,
        updatedAt,
      ];
}
