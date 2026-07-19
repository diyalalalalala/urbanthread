import '../../../../core/storage/cache_store.dart';
import '../../domain/entities/home_product.dart';
import '../models/home_product_model.dart';

/// The storefront's slice of the `catalogue` Hive box.
///
/// Each rail is cached under its own key rather than the feed as a whole, so
/// a partial refresh — three rails succeeded, one timed out — writes only
/// what it actually got instead of overwriting three good rails with a
/// half-empty feed.
class HomeLocalDataSource {
  const HomeLocalDataSource(this._cache);

  static const prefix = 'home:';

  /// How long a rail stays "fresh".
  ///
  /// Short compared to the taxonomy's six hours, because these lists are
  /// merchandising output that moves daily and a stale "new arrivals" is the
  /// most obviously wrong thing on the screen. As with every TTL here it only
  /// gates the *background* refresh — cached rails are served regardless, so
  /// the cost of being wrong is a slightly old price, never a blank screen.
  static const ttl = Duration(minutes: 30);

  final CacheStore _cache;

  static String keyFor(HomeCollection collection) =>
      '$prefix${collection.name}';

  List<HomeProductModel> read(HomeCollection collection) => _cache.readList(
        keyFor(collection),
        (json) => HomeProductModel.fromJson(json! as Map<String, dynamic>),
      );

  Future<void> write(
    HomeCollection collection,
    List<HomeProductModel> products,
  ) =>
      _cache.write(
        keyFor(collection),
        products.map((product) => product.toJson()).toList(growable: false),
      );

  bool isStale(HomeCollection collection) =>
      _cache.isStale(keyFor(collection), ttl);

  DateTime? savedAt(HomeCollection collection) =>
      _cache.savedAt(keyFor(collection));

  Future<void> clear() => _cache.deleteWhereKeyStartsWith(prefix);
}
