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

/// The catalogue, offline-first.
///
/// Every cached read follows the same three-branch policy:
///
/// * **Offline** — serve the cache, or fail with [EmptyCacheFailure] if this
///   query was never downloaded.
/// * **Online, request succeeded** — refresh the cache and return.
/// * **Online, request failed** — fall back to the cache *only* for a
///   transport failure. A 404 or 422 is a real answer from the server and
///   must not be masked with stale data, or a deleted product would keep
///   rendering as if it were still on sale.
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
    // Deliberately uncached. Search terms are near-unique per user, so their
    // result sets would fill the box with entries that are never read a
    // second time and would push out the list pages that are.
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
    // The API clamps `limit` to 1–50 and answers anything else with a 422,
    // so it is clamped here rather than sent and rejected.
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
        // The cached copy is a hydrated detail response, so it still carries
        // the virtuals the entity's fallbacks would otherwise have to derive.
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
    // Not cached: it is a market-basket aggregate that changes with every
    // order, and an empty result is the common case for a new product — there
    // is little to gain from persisting it.
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

  // ── Internals ──────────────────────────────────────────────────────────

  /// Shared body for the bare-array endpoints: the collections and related
  /// products. They differ only in which request they make and where they are
  /// cached, so the offline policy lives here once.
  Future<Result<List<Product>>> _cachedList({
    required String cacheName,
    required Future<ApiEnvelope<List<ProductModel>>> Function() request,
  }) async {
    List<Product> cached() => _local
        .readCollection(cacheName)
        .map((model) => model.toEntity())
        .toList(growable: false);

    if (!await _networkInfo.isConnected) {
      final offline = cached();
      return offline.isEmpty
          ? const Result.failure(EmptyCacheFailure())
          : Result.success(offline);
    }

    try {
      final envelope = await request();
      await _local.writeCollection(cacheName, envelope.data);
      return Result.success(
        envelope.data.map((model) => model.toEntity()).toList(growable: false),
      );
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

  /// Builds the domain page. A missing `meta` — which is what the bare-array
  /// routes and an older cache entry both look like — is treated as a single
  /// complete page rather than as page 1 of an unknown number, so the
  /// infinite scroll stops instead of requesting page 2 forever.
  Paginated<Product> _toPage(List<ProductModel> items, PaginationMeta? meta) {
    final products =
        items.map((model) => model.toEntity()).toList(growable: false);
    if (meta == null) return Paginated<Product>.single(products);

    return Paginated<Product>(
      items: products,
      page: meta.page,
      totalPages: meta.totalPages,
      total: meta.total,
      hasNextPage: meta.hasNextPage,
    );
  }

  /// Only a transport problem justifies serving stale data. Everything else
  /// is the server's considered answer.
  bool _isTransient(Failure failure) =>
      failure is NetworkFailure || failure is TimeoutFailure;
}
