import 'package:equatable/equatable.dart';

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
