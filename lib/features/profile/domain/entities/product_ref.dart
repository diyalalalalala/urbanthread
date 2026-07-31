import 'package:equatable/equatable.dart';

class ProductRef extends Equatable {
  const ProductRef({
    required this.id,
    required this.name,
    required this.slug,
    this.imageUrl,
    this.price,
    this.effectivePrice,
    this.discountPercentage = 0,
    this.ratingAverage = 0,
    this.ratingCount = 0,
    this.totalStock,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String slug;

  final String? imageUrl;

  final num? price;

  final num? effectivePrice;

  final num discountPercentage;
  final num ratingAverage;
  final int ratingCount;

  final int? totalStock;

  final bool isActive;

  num get displayPrice => effectivePrice ?? price ?? 0;

  bool get hasDiscount => discountPercentage > 0 && effectivePrice != null;

  bool get isOutOfStock => totalStock != null && totalStock! <= 0;

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        imageUrl,
        price,
        effectivePrice,
        discountPercentage,
        ratingAverage,
        ratingCount,
        totalStock,
        isActive,
      ];
}
