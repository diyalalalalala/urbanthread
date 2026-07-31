import '../../../../core/storage/cache_store.dart';
import '../../domain/entities/home_product.dart';
import '../models/home_product_model.dart';

class HomeLocalDataSource {
  const HomeLocalDataSource(this._cache);

  static const prefix = 'home:';

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
