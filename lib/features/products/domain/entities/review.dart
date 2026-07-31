import 'package:equatable/equatable.dart';

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

  final String? userAvatarUrl;

  final int rating;
  final String title;
  final String comment;

  final bool isVerifiedPurchase;

  final int helpfulCount;
  final bool isEdited;
  final DateTime? editedAt;
  final DateTime? createdAt;

  bool get hasTitle => title.isNotEmpty;

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

class ReviewStats extends Equatable {
  const ReviewStats({
    this.average = 0,
    this.count = 0,
    this.distribution = const {},
  });

  final double average;
  final int count;

  final Map<int, int> distribution;

  bool get hasReviews => count > 0;

  int countFor(int stars) => distribution[stars] ?? 0;

  double fractionFor(int stars) => count == 0 ? 0 : countFor(stars) / count;

  @override
  List<Object?> get props => [average, count, distribution];
}

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

  final int? rating;

  final bool? verified;

  final ReviewSort sort;

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
      'sort': sort.wireValue,
    };
    if (rating != null) params['rating'] = rating;
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
