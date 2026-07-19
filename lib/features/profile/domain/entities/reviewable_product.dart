import 'package:equatable/equatable.dart';

/// A delivered line item the customer has not reviewed yet.
///
/// From `GET /reviews/reviewable`, which is an aggregate: it returns a bare
/// array (no pagination, capped at 50) and the projection **omits `_id`**
/// entirely. That makes [productId] the only identity available — it is what
/// list keys, deduplication and `POST /reviews` all have to key off.
class ReviewableProduct extends Equatable {
  const ReviewableProduct({
    required this.productId,
    required this.productName,
    required this.slug,
    this.imageUrl,
    this.brandName = '',
    this.orderId = '',
    this.orderNumber = '',
    this.deliveredAt,
  });

  final String productId;
  final String productName;
  final String slug;
  final String? imageUrl;
  final String brandName;

  /// The order that made this reviewable. Carried so the UI can say *which*
  /// purchase it is asking about when the same product was bought twice.
  final String orderId;
  final String orderNumber;
  final DateTime? deliveredAt;

  @override
  List<Object?> get props => [
        productId,
        productName,
        slug,
        imageUrl,
        brandName,
        orderId,
        orderNumber,
        deliveredAt,
      ];
}
