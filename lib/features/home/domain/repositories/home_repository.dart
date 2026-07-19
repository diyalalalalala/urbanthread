import '../../../../core/domain/result.dart';
import '../entities/home_product.dart';

/// The storefront's product-collection contract.
///
/// One method for four endpoints: `/products/featured`, `/trending`,
/// `/best-sellers` and `/new-arrivals` are identical in shape — a bare array,
/// no `meta`, one `limit` parameter — so modelling them as four methods would
/// be four copies of the same offline-first logic.
abstract interface class HomeRepository {
  /// One merchandising rail.
  ///
  /// [limit] is capped at 50 by the validator and defaults to 10 server-side.
  Future<Result<List<HomeProduct>>> getCollection(
    HomeCollection collection, {
    int limit = 10,
  });

  /// The last stored contents of [collection], read straight off disk.
  ///
  /// Synchronous because Hive is: it lets the home screen paint from cache on
  /// its first frame instead of showing a spinner over data it already has,
  /// which is the whole point of the offline-first requirement.
  List<HomeProduct> cachedCollection(HomeCollection collection);

  /// Whether [collection] is old enough to be worth re-fetching. Advisory —
  /// cached data is served regardless, this only decides whether a background
  /// refresh is worth the request.
  bool isCollectionStale(HomeCollection collection);
}
