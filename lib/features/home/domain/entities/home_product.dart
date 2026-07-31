import 'package:equatable/equatable.dart';

enum HomeCollection {
  newArrivals,
  trending,
  featured,
  bestSellers;

  String get title => switch (this) {
        HomeCollection.newArrivals => 'New Arrivals',
        HomeCollection.trending => 'Trending Now',
        HomeCollection.featured => 'Featured',
        HomeCollection.bestSellers => 'Best Sellers',
      };

  String get subtitle => switch (this) {
        HomeCollection.newArrivals => 'Just landed this season',
        HomeCollection.trending => 'What everyone is looking at',
        HomeCollection.featured => 'Picked by our stylists',
        HomeCollection.bestSellers => 'Our most-loved pieces',
      };

  String get seeAllPath => switch (this) {
        HomeCollection.newArrivals => '/products?isNewArrival=true',
        HomeCollection.trending => '/products?sort=popularity',
        HomeCollection.featured => '/products?isFeatured=true',
        HomeCollection.bestSellers => '/products?sort=best_selling',
      };
}

class HomeProduct extends Equatable {
  const HomeProduct({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    required this.effectivePrice,
    this.discountPercentage = 0,
    this.imageUrl,
    this.ratingAverage = 0,
    this.ratingCount = 0,
    this.totalStock = 0,
    this.categoryName,
    this.categorySlug,
    this.brandName,
    this.brandSlug,
    this.isFeatured = false,
    this.isNewArrival = false,
  });

  final String id;
  final String name;

  final String slug;

  final num price;

  final num effectivePrice;

  final num discountPercentage;

  final String? imageUrl;

  final num ratingAverage;
  final int ratingCount;
  final int totalStock;

  final String? categoryName;
  final String? categorySlug;
  final String? brandName;
  final String? brandSlug;

  final bool isFeatured;
  final bool isNewArrival;

  bool get inStock => totalStock > 0;

  bool get hasDiscount => discountPercentage > 0 && effectivePrice < price;

  bool get hasRating => ratingCount > 0;

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        price,
        effectivePrice,
        discountPercentage,
        imageUrl,
        ratingAverage,
        ratingCount,
        totalStock,
        categoryName,
        categorySlug,
        brandName,
        brandSlug,
        isFeatured,
        isNewArrival,
      ];
}
