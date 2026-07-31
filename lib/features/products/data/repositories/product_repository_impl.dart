import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_filters.dart';
import '../../domain/entities/product_query.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasource/product_local_datasource.dart';
import '../datasource/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({
    required ProductRemoteDataSource remote,
    required ProductLocalDataSource local,
    required NetworkInfo networkInfo,
  })  : _remote = remote,
        _local = local,
        _networkInfo = networkInfo;

  final ProductRemoteDataSource _remote;
  final ProductLocalDataSource _local;
  final NetworkInfo _networkInfo;

  @override
  Future<Result<Paginated<Product>>> getProducts(ProductQuery query) async {
    final key = query.cacheKey;

    if (!await _networkInfo.isConnected) {
      return _cachedPage(key);
    }

    try {
      final envelope = await _remote.getProducts(query.toQueryParameters());
      await _local.writePage(key, envelope.data, envelope.meta);
      return Result.success(_toPage(envelope.data, envelope.meta));
    } on Object catch (error) {
      final failure = ErrorMapper.toFailure(error);
      if (_isTransient(failure)) {
        final cached = _local.readPage(key);
        if (cached != null && !cached.isEmpty) {
          return Result.success(_toPage(cached.items, cached.meta));
        }
      }
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<Paginated<Product>>> searchProducts(ProductQuery query) async {
    if (!await _networkInfo.isConnected) {
      return const Result.failure(
        NetworkFailure('Search needs a connection. Browse saved items instead.'),
      );
    }

    try {
      final envelope = await _remote.searchProducts(query.toQueryParameters());
      return Result.success(_toPage(envelope.data, envelope.meta));
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  @override
  Future<Result<ProductFilters>> getFilters() async {
    ProductFilters? cached() => _local.readFilters()?.toEntity();

    if (!await _networkInfo.isConnected) {
      final offline = cached();
      return offline == null
          ? const Result.failure(EmptyCacheFailure())
          : Result.success(offline);
    }

    try {
      final envelope = await _remote.getFilters();
      await _local.writeFilters(envelope.data);
      return Result.success(envelope.data.toEntity());
    } on Object catch (error) {
      final failure = ErrorMapper.toFailure(error);
      if (_isTransient(failure)) {
        final fallback = cached();
        if (fallback != null) return Result.success(fallback);
      }
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<List<Product>>> getCollection(
    ProductCollection collection, {
    int limit = 10,
  }) {
    final safeLimit = limit.clamp(1, 50);
    return _cachedList(
      cacheName: collection.key,
      request: () => switch (collection) {
        ProductCollection.featured => _remote.getFeatured(safeLimit),
        ProductCollection.trending => _remote.getTrending(safeLimit),
        ProductCollection.bestSellers => _remote.getBestSellers(safeLimit),
        ProductCollection.newArrivals => _remote.getNewArrivals(safeLimit),
      },
    );
  }

  @override
  Future<Result<Product>> getProductBySlug(String slug) async {
    ProductModel? cached() => _local.readProduct(slug);

    if (!await _networkInfo.isConnected) {
      final offline = cached();
      return offline == null
          ? const Result.failure(EmptyCacheFailure())
          : Result.success(offline.toEntity());
    }

    try {
      final envelope = await _remote.getProductBySlug(slug);
      await _local.writeProduct(envelope.data);
      return Result.success(envelope.data.toEntity());
    } on Object catch (error) {
      final failure = ErrorMapper.toFailure(error);
      if (_isTransient(failure)) {
        final fallback = cached();
        if (fallback != null) return Result.success(fallback.toEntity());
      }
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<List<Product>>> getRelatedProducts(
    String productId, {
    int limit = 8,
  }) =>
      _cachedList(
        cacheName: 'related:$productId',
        request: () => _remote.getRelated(productId, limit.clamp(1, 50)),
      );

  @override
  Future<Result<List<FrequentlyBoughtTogether>>> getFrequentlyBoughtTogether(
    String productId, {
    int limit = 6,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Result.success([]);
    }

    try {
      final envelope = await _remote.getFrequentlyBoughtTogether(
        productId,
        limit.clamp(1, 50),
      );
      return Result.success(
        envelope.data.map((entry) => entry.toEntity()).toList(growable: false),
      );
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  @override
  Future<void> invalidateListCache() => _local.clearLists();

  static List<Product> _toEntities(List<ProductModel> models) => models
      .where((model) => model.isRenderable)
      .map((model) => model.toEntity())
      .toList(growable: false);

  Future<Result<List<Product>>> _cachedList({
    required String cacheName,
    required Future<ApiEnvelope<List<ProductModel>>> Function() request,
  }) async {
    List<Product> cached() => _toEntities(_local.readCollection(cacheName));

    if (!await _networkInfo.isConnected) {
      final offline = cached();
      return offline.isEmpty
          ? const Result.failure(EmptyCacheFailure())
          : Result.success(offline);
    }

    try {
      final envelope = await request();
      await _local.writeCollection(cacheName, envelope.data);
      return Result.success(_toEntities(envelope.data));
    } on Object catch (error) {
      final failure = ErrorMapper.toFailure(error);
      if (_isTransient(failure)) {
        final fallback = cached();
        if (fallback.isNotEmpty) return Result.success(fallback);
      }
      return Result.failure(failure);
    }
  }

  Result<Paginated<Product>> _cachedPage(String key) {
    final cached = _local.readPage(key);
    if (cached == null || cached.isEmpty) {
      return const Result.failure(EmptyCacheFailure());
    }
    return Result.success(_toPage(cached.items, cached.meta));
  }

  Paginated<Product> _toPage(List<ProductModel> items, PaginationMeta? meta) {
    final products = _toEntities(items);
    if (meta == null) return Paginated<Product>.single(products);

    return Paginated<Product>(
      items: products,
      page: meta.page,
      totalPages: meta.totalPages,
      total: meta.total,
      hasNextPage: meta.hasNextPage,
    );
  }

  bool _isTransient(Failure failure) =>
      failure is NetworkFailure || failure is TimeoutFailure;
}
