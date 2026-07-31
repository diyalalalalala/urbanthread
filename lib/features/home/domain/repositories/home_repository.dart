import '../../../../core/domain/result.dart';
import '../entities/home_product.dart';

abstract interface class HomeRepository {
  Future<Result<List<HomeProduct>>> getCollection(
    HomeCollection collection, {
    int limit = 10,
  });

  List<HomeProduct> cachedCollection(HomeCollection collection);

  bool isCollectionStale(HomeCollection collection);
}
