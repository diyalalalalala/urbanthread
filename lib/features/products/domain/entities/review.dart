import 'package:equatable/equatable.dart';

/// Sort orders `GET /reviews/product/{id}` accepts. As with product sorting,
/// the set is closed and an unknown value is a 422.
enum ReviewSort {
  newest('newest', 'Newest'),
  oldest('oldest', 'Oldest'),
  highest('highest', 'Highest rated'),
  lowest('lowest', 'Lowest rated'),
  mostHelpful('most_helpful', 'Most helpful');

  const ReviewSort(this.wireValue, this.label);

  final String wireValue;
  final String label;

  static ReviewSort parse(String? raw) {
    for (final value in ReviewSort.values) {
      if (value.wireValue == raw) return value;
    }
    return ReviewSort.newest;
  }
}

/// A customer review on a product page.
///
/// The author's name and avatar are *snapshots* taken when the review was
/// written, not a populated user reference — a deleted account keeps its
/// reviews readable. So there is no user object to follow here.
class Review extends Equatable {
  const Review({
    required this.id,
    required this.productId,
    required this.userName,
    required this.rating,
    required this.comment,
    this.title = '',
    this.userAvatarUrl,
    this.isVerifiedPurchase = false,
    this.helpfulCount = 0,
    this.isEdited = false,
    this.editedAt,
    this.createdAt,
  });

  final String id;
  final String productId;
  final String userName;

  /// Null when the reviewer had no avatar — the API stores that as `""`.
  final String? userAvatarUrl;

  final int rating;
  final String title;
  final String comment;

  /// Set when the reviewer has a delivered order containing this product.
  /// Renders the "Verified Purchase" badge, the page's strongest trust cue.
  final bool isVerifiedPurchase;

  final int helpfulCount;
  final bool isEdited;
  final DateTime? editedAt;
  final DateTime? createdAt;

  bool get hasTitle => title.isNotEmpty;

  /// Up to two letters for the avatar fallback.
  String get initials {
    final parts = userName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        userName,
        userAvatarUrl,
        rating,
        title,
        comment,
        isVerifiedPurchase,
        helpfulCount,
        isEdited,
        editedAt,
        createdAt,
      ];
}

/// The rating summary from `GET /reviews/product/{id}/stats`.
///
/// Computed from approved reviews only, so it can legitimately disagree with
/// a product document whose denormalised `rating` has not been recomputed
/// yet — the stats endpoint is the more current of the two.
class ReviewStats extends Equatable {
  const ReviewStats({
    this.average = 0,
    this.count = 0,
    this.distribution = const {},
  });

  final double average;
  final int count;

  /// Keyed by star value. The wire format uses string keys ("1".."5"); they
  /// are converted at the model boundary.
  final Map<int, int> distribution;

  bool get hasReviews => count > 0;

  int countFor(int stars) => distribution[stars] ?? 0;

  double fractionFor(int stars) => count == 0 ? 0 : countFor(stars) / count;

  @override
  List<Object?> get props => [average, count, distribution];
}

/// Query parameters for the product review list.
class ReviewQuery extends Equatable {
  const ReviewQuery({
    this.page = 1,
    this.limit = 10,
    this.rating,
    this.verified,
    this.sort = ReviewSort.newest,
  });

  final int page;
  final int limit;

  /// Show only reviews at this star rating, 1–5.
  final int? rating;

  /// Show only verified purchases.
  final bool? verified;

  final ReviewSort sort;

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
      'sort': sort.wireValue,
    };
    if (rating != null) params['rating'] = rating;
    // Booleans travel as strings; the validator reads the raw query text.
    if (verified != null) params['verified'] = verified! ? 'true' : 'false';
    return params;
  }

  String cacheKeyFor(String productId) =>
      'reviews:$productId:${rating ?? 'all'}:${verified ?? 'any'}:'
      '${sort.wireValue}:$page';

  bool get hasActiveFilters => rating != null || verified == true;

  ReviewQuery copyWith({
    int? page,
    int? limit,
    int? rating,
    bool clearRating = false,
    bool? verified,
    bool clearVerified = false,
    ReviewSort? sort,
  }) =>
      ReviewQuery(
        page: page ?? this.page,
        limit: limit ?? this.limit,
        rating: clearRating ? null : (rating ?? this.rating),
        verified: clearVerified ? null : (verified ?? this.verified),
        sort: sort ?? this.sort,
      );

  @override
  List<Object?> get props => [page, limit, rating, verified, sort];
}
