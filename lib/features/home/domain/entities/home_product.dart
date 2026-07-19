import 'package:equatable/equatable.dart';

/// The four merchandising rails the storefront is built from.
///
/// Each maps to its own endpoint rather than to a filter on `/products`,
/// because the ordering is computed server-side (sales counts, recency) and
/// is not expressible as a query parameter.
enum HomeCollection {
  newArrivals,
  trending,
  featured,
  bestSellers;

  /// The rail heading shown above the list.
  String get title => switch (this) {
        HomeCollection.newArrivals => 'New Arrivals',
        HomeCollection.trending => 'Trending Now',
        HomeCollection.featured => 'Featured',
        HomeCollection.bestSellers => 'Best Sellers',
      };

  /// A one-line justification for the rail, shown under the heading.
  String get subtitle => switch (this) {
        HomeCollection.newArrivals => 'Just landed this season',
        HomeCollection.trending => 'What everyone is looking at',
        HomeCollection.featured => 'Picked by our stylists',
        HomeCollection.bestSellers => 'Our most-loved pieces',
      };

  /// The catalogue query that reproduces this rail on the products screen,
  /// for the rail's "see all" affordance.
  ///
  /// Returned as a bare path string so this feature owns no routing — the app
  /// router resolves it, and nothing here has to import a router.
  /// `sort` must be one of the backend's eight allowed values — an unknown
  /// one is a 422, not a silent fallback to default ordering. `popularity`
  /// and `best_selling` are the closest catalogue equivalents to what the
  /// trending and best-seller endpoints rank by.
  String get seeAllPath => switch (this) {
        HomeCollection.newArrivals => '/products?isNewArrival=true',
        HomeCollection.trending => '/products?sort=popularity',
        HomeCollection.featured => '/products?isFeatured=true',
        HomeCollection.bestSellers => '/products?sort=best_selling',
      };
}

/// A product as a home rail needs it — deliberately smaller than the full
/// catalogue entity.
///
/// This is a separate, lighter type rather than a reuse of the products
/// feature's `Product` because a rail card needs eight fields and the detail
/// entity carries forty. Decoding variants, specifications and review
/// summaries for forty cards the user will scroll past is work with no
/// payoff, and it would couple the home screen's cache format to a type that
/// changes for reasons the home screen does not care about.
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

  /// Carried on every card because product detail is **slug-only** — there is
  /// no `GET /products/:id`, so a card holding only an id cannot navigate.
  final String slug;

  /// List price, before any discount.
  final num price;

  /// Post-discount price. The backend computes it; it is never derived here,
  /// because rounding rules for a percentage discount belong to whoever owns
  /// the pricing rules.
  final num effectivePrice;

  final num discountPercentage;

  /// Already resolved down from the `images` array by the model, which picks
  /// the primary image and falls back to the first — the `primaryImage`
  /// virtual is absent on these lean collection routes.
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

  /// Recomputed from `totalStock` rather than read from the API.
  ///
  /// The `inStock` virtual exists only on hydrated responses; the collection
  /// endpoints are `.lean()` reads and drop it entirely. Trusting a missing
  /// virtual would mark the whole catalogue out of stock.
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
