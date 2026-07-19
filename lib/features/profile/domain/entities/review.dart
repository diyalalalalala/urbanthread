import 'package:equatable/equatable.dart';

import 'product_ref.dart';

/// Moderation state of a review.
///
/// The backend defaults new reviews to `approved`, so a review the customer
/// just wrote is live immediately — [pending] and [rejected] only appear when
/// an admin has intervened, and the UI should explain them rather than hide
/// them.
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

/// A review written by the signed-in customer.
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

  /// Always present. `product` on the wire is polymorphic — a bare ObjectId on
  /// some routes, a populated projection on `/reviews/my-reviews` — so the id
  /// is lifted out separately and [product] is whatever detail came with it.
  final String productId;

  final ProductRef? product;

  final String userName;

  /// A plain string URL, unlike `User.avatar`, which is an object. The review
  /// document denormalises the avatar at write time rather than referencing
  /// the user's, so the two fields genuinely have different shapes.
  final String? userAvatarUrl;

  /// 1..5, enforced by the backend validator.
  final int rating;

  final String title;

  /// 10..2000 characters.
  final String comment;

  final bool isVerifiedPurchase;
  final ReviewStatus status;

  /// Why a moderator rejected it. Empty unless [status] is rejected.
  final String moderationNote;

  final int helpfulCount;
  final bool isEdited;
  final DateTime? editedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// The timestamp worth showing: the edit if there was one, else the write.
  DateTime? get displayedAt => isEdited ? (editedAt ?? createdAt) : createdAt;

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
