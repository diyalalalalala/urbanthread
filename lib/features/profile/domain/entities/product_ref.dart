import 'package:equatable/equatable.dart';

/// The slice of a product that the account screens actually render.
///
/// Deliberately *not* the catalogue's full `Product`: recently-viewed and
/// review responses populate a hand-picked projection (`name, slug, images,
/// price`), so modelling them against the full entity would mean a wall of
/// nullable fields that are only ever populated on `/products`. This carries
/// exactly what a compact row needs, and `slug` so a tap can open the real
/// detail screen — which is slug-only.
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

  /// Null when the projection carried no usable image.
  final String? imageUrl;

  final num? price;

  /// Post-discount price. Present on recently-viewed, absent on the review
  /// projection — fall back to [price] through [displayPrice].
  final num? effectivePrice;

  final num discountPercentage;
  final num ratingAverage;
  final int ratingCount;

  /// Only recently-viewed carries stock. Null means "not reported", which is
  /// different from zero.
  final int? totalStock;

  final bool isActive;

  /// What to show as the current price.
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
