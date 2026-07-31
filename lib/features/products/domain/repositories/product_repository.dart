import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../entities/product.dart';
import '../entities/product_filters.dart';
import '../entities/product_query.dart';

enum ProductCollection {
  featured('featured'),
  trending('trending'),
  bestSellers('best-sellers'),
  newArrivals('new-arrivals');

  const ProductCollection(this.key);

  final String key;

  String get label => switch (this) {
        ProductCollection.featured => 'Featured',
        ProductCollection.trending => 'Trending now',
        ProductCollection.bestSellers => 'Best sellers',
        ProductCollection.newArrivals => 'New arrivals',
      };
}

abstract interface class ProductRepository {
  Future<Result<Paginated<Product>>> getProducts(ProductQuery query);

  Future<Result<Paginated<Product>>> searchProducts(ProductQuery query);

  Future<Result<ProductFilters>> getFilters();

  Future<Result<List<Product>>> getCollection(
    ProductCollection collection, {
    int limit = 10,
  });

  Future<Result<Product>> getProductBySlug(String slug);

  Future<Result<List<Product>>> getRelatedProducts(String productId,
      {int limit = 8});

  Future<Result<List<FrequentlyBoughtTogether>>> getFrequentlyBoughtTogether(
    String productId, {
    int limit = 6,
  });

  Future<void> invalidateListCache();
}
