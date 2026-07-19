import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../entities/product.dart';
import '../entities/product_filters.dart';
import '../entities/product_query.dart';

/// The four curated home-page collections.
///
/// Grouped into one enum because they are the same request shape — a bare
/// array, `limit` its only parameter — and the home screen renders them
/// through one widget. Splitting them into four repository methods would
/// duplicate the caching and fallback logic four times.
enum ProductCollection {
  featured('featured'),
  trending('trending'),
  bestSellers('best-sellers'),
  newArrivals('new-arrivals');

  const ProductCollection(this.key);

  /// Used as the cache-key segment; matches the endpoint's last path element.
  final String key;

  String get label => switch (this) {
        ProductCollection.featured => 'Featured',
        ProductCollection.trending => 'Trending now',
        ProductCollection.bestSellers => 'Best sellers',
        ProductCollection.newArrivals => 'New arrivals',
      };
}

/// The catalogue contract.
///
/// Every method returns a [Result] and never throws. Reads that have a cache
/// behind them fall back to it on a transport failure only — a 404 or a 422
/// is a real answer and must not be papered over with stale data.
abstract interface class ProductRepository {
  /// A page of the catalogue. Cached per query *and* page.
  Future<Result<Paginated<Product>>> getProducts(ProductQuery query);

  /// Full-text search. Identical to [getProducts] but the backend rejects an
  /// empty term with a 400, so callers must not send one.
  ///
  /// Not cached: a result set keyed by an arbitrary term would fill the box
  /// with entries that are never read twice.
  Future<Result<Paginated<Product>>> searchProducts(ProductQuery query);

  /// The facet lists that drive the filter sheet.
  Future<Result<ProductFilters>> getFilters();

  /// One of the curated collections. `limit` is clamped to 1–50 by the API.
  Future<Result<List<Product>>> getCollection(
    ProductCollection collection, {
    int limit = 10,
  });

  /// Product detail. **Slug-only** — there is no `GET /products/:id`, so the
  /// slug has to be carried through from whichever list the user tapped.
  Future<Result<Product>> getProductBySlug(String slug);

  /// Similar products. Takes a real ObjectId, unlike detail — the asymmetry
  /// is the API's, not ours.
  Future<Result<List<Product>>> getRelatedProducts(String productId,
      {int limit = 8});

  /// Market-basket companions, with their co-purchase counts.
  Future<Result<List<FrequentlyBoughtTogether>>> getFrequentlyBoughtTogether(
    String productId, {
    int limit = 6,
  });

  /// Drops every cached catalogue list so the next read hits the network.
  /// Called on pull-to-refresh.
  Future<void> invalidateListCache();
}
