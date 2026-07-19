import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/brand.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/categories_repository.dart';
import '../datasource/categories_local_datasource.dart';
import '../datasource/categories_remote_datasource.dart';
import '../models/brand_model.dart';
import '../models/category_model.dart';

/// Offline-first implementation of the taxonomy contract.
///
/// Every read follows the same three-branch policy:
///
/// * **Offline** — answer from cache, or [EmptyCacheFailure] if there is
///   nothing stored. No request is attempted; it would only burn a timeout.
/// * **Online and successful** — write through to cache, return fresh data.
/// * **Online and failed** — fall back to cache *only* for transport errors.
///   A 404 means the category genuinely no longer exists, and serving a
///   cached copy of a deleted category would be worse than an honest error.
class CategoriesRepositoryImpl implements CategoriesRepository {
  const CategoriesRepositoryImpl({
    required CategoriesRemoteDataSource remote,
    required CategoriesLocalDataSource local,
    required NetworkInfo networkInfo,
  })  : _remote = remote,
        _local = local,
        _networkInfo = networkInfo;

  final CategoriesRemoteDataSource _remote;
  final CategoriesLocalDataSource _local;
  final NetworkInfo _networkInfo;

  @override
  Future<Result<Paginated<Category>>> getCategories({
    int page = 1,
    int limit = 20,
    String? search,
    String? parent,
    bool? isFeatured,
  }) async {
    final key = CategoriesLocalDataSource.categoriesPageKey(
      page: page,
      limit: limit,
      search: search,
      parent: parent,
      isFeatured: isFeatured,
    );

    return _page<CategoryModel, Category>(
      cacheKey: key,
      readCache: _local.readCategoryPage,
      writeCache: _local.writeCategoryPage,
      request: () => _remote.getCategories(
        page: page,
        limit: limit,
        // An empty search string is not the same as no search: the validator
        // accepts it and the backend then matches an empty regex, so send
        // null rather than "".
        search: (search?.trim().isEmpty ?? true) ? null : search!.trim(),
        parent: parent,
        isFeatured: isFeatured,
      ),
      toEntity: (model) => model.toEntity(),
    );
  }

  @override
  Future<Result<List<CategoryNode>>> getCategoryTree() async {
    if (!await _networkInfo.isConnected) {
      final cached = _local.readTree();
      return cached.isEmpty
          ? const Result.failure(EmptyCacheFailure())
          : Result.success(_treeToEntities(cached));
    }

    try {
      final envelope = await _remote.getCategoryTree();
      await _local.writeTree(envelope.data);
      return Result.success(_treeToEntities(envelope.data));
    } on Object catch (error) {
      return _fallbackToCache(
        error,
        () => _local.readTree(),
        _treeToEntities,
      );
    }
  }

  @override
  Future<Result<CategoryNode>> getCategory(String slugOrId) async {
    if (!await _networkInfo.isConnected) {
      final cached = _local.readCategory(slugOrId);
      return cached == null
          ? const Result.failure(EmptyCacheFailure())
          : Result.success(cached.toEntity());
    }

    try {
      final envelope = await _remote.getCategory(slugOrId);
      await _local.writeCategory(slugOrId, envelope.data);
      return Result.success(envelope.data.toEntity());
    } on Object catch (error) {
      final failure = ErrorMapper.toFailure(error);
      if (_isTransient(failure)) {
        final cached = _local.readCategory(slugOrId);
        if (cached != null) return Result.success(cached.toEntity());
      }
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<List<Category>>> getFeaturedCategories({int limit = 12}) async {
    if (!await _networkInfo.isConnected) {
      final cached = _local.readFeaturedCategories();
      return cached.isEmpty
          ? const Result.failure(EmptyCacheFailure())
          : Result.success(_toEntities(cached));
    }

    try {
      // Featured categories come off the paginated list route with the
      // `isFeatured` filter; there is no dedicated `/categories/featured`.
      final envelope = await _remote.getCategories(
        page: 1,
        limit: limit,
        isFeatured: true,
      );
      await _local.writeFeaturedCategories(envelope.data);
      return Result.success(_toEntities(envelope.data));
    } on Object catch (error) {
      return _fallbackToCache(
        error,
        _local.readFeaturedCategories,
        _toEntities,
      );
    }
  }

  @override
  Future<Result<Paginated<Brand>>> getBrands({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isFeatured,
  }) async {
    final key = CategoriesLocalDataSource.brandsPageKey(
      page: page,
      limit: limit,
      search: search,
      isFeatured: isFeatured,
    );

    return _page<BrandModel, Brand>(
      cacheKey: key,
      readCache: _local.readBrandPage,
      writeCache: _local.writeBrandPage,
      request: () => _remote.getBrands(
        page: page,
        limit: limit,
        search: (search?.trim().isEmpty ?? true) ? null : search!.trim(),
        isFeatured: isFeatured,
      ),
      toEntity: (model) => model.toEntity(),
    );
  }

  @override
  Future<Result<List<Brand>>> getFeaturedBrands({int limit = 12}) async {
    if (!await _networkInfo.isConnected) {
      final cached = _local.readFeaturedBrands();
      return cached.isEmpty
          ? const Result.failure(EmptyCacheFailure())
          : Result.success(_toBrandEntities(cached));
    }

    try {
      final envelope = await _remote.getFeaturedBrands(limit: limit);
      await _local.writeFeaturedBrands(envelope.data);
      return Result.success(_toBrandEntities(envelope.data));
    } on Object catch (error) {
      return _fallbackToCache(
        error,
        _local.readFeaturedBrands,
        _toBrandEntities,
      );
    }
  }

  @override
  Future<Result<Brand>> getBrand(String slugOrId) async {
    if (!await _networkInfo.isConnected) {
      final cached = _local.readBrand(slugOrId);
      return cached == null
          ? const Result.failure(EmptyCacheFailure())
          : Result.success(cached.toEntity());
    }

    try {
      final envelope = await _remote.getBrand(slugOrId);
      await _local.writeBrand(slugOrId, envelope.data);
      return Result.success(envelope.data.toEntity());
    } on Object catch (error) {
      final failure = ErrorMapper.toFailure(error);
      if (_isTransient(failure)) {
        final cached = _local.readBrand(slugOrId);
        if (cached != null) return Result.success(cached.toEntity());
      }
      return Result.failure(failure);
    }
  }

  @override
  List<CategoryNode> cachedCategoryTree() => _treeToEntities(_local.readTree());

  @override
  List<Category> cachedFeaturedCategories() =>
      _toEntities(_local.readFeaturedCategories());

  @override
  List<Brand> cachedFeaturedBrands() =>
      _toBrandEntities(_local.readFeaturedBrands());

  @override
  List<Brand> cachedBrands() => _toBrandEntities(_local.readFirstBrandPage());

  // ── Shared plumbing ──────────────────────────────────────────────────────

  /// The offline-first policy for a paginated endpoint, in one place.
  ///
  /// Generic over both the wire model and the entity so categories and brands
  /// share it: the two differ only in which datasource methods they call.
  Future<Result<Paginated<E>>> _page<M, E>({
    required String cacheKey,
    required CachedPage<M>? Function(String key) readCache,
    required Future<void> Function(String key, List<M> items, PaginationMeta meta)
        writeCache,
    required Future<ApiEnvelope<List<M>>> Function() request,
    required E Function(M model) toEntity,
  }) async {
    Paginated<E> fromCache(CachedPage<M> cached) => Paginated<E>(
          items: cached.items.map(toEntity).toList(growable: false),
          page: cached.meta.page,
          totalPages: cached.meta.totalPages,
          total: cached.meta.total,
          hasNextPage: cached.meta.hasNextPage,
        );

    if (!await _networkInfo.isConnected) {
      final cached = readCache(cacheKey);
      return cached == null || cached.items.isEmpty
          ? const Result.failure(EmptyCacheFailure())
          : Result.success(fromCache(cached));
    }

    try {
      final envelope = await request();
      // `meta` is only sent by the paginated routes. Falling back to a
      // synthesised single page keeps one code path for both shapes.
      final meta = envelope.meta ?? PaginationMeta.single(envelope.data.length);
      await writeCache(cacheKey, envelope.data, meta);
      return Result.success(
        Paginated<E>(
          items: envelope.data.map(toEntity).toList(growable: false),
          page: meta.page,
          totalPages: meta.totalPages,
          total: meta.total,
          hasNextPage: meta.hasNextPage,
        ),
      );
    } on Object catch (error) {
      final failure = ErrorMapper.toFailure(error);
      if (_isTransient(failure)) {
        final cached = readCache(cacheKey);
        if (cached != null && cached.items.isNotEmpty) {
          return Result.success(fromCache(cached));
        }
      }
      return Result.failure(failure);
    }
  }

  /// Turns a failed request into cached data when the failure was transport,
  /// and into a [Failure] otherwise.
  Result<List<E>> _fallbackToCache<M, E>(
    Object error,
    List<M> Function() readCache,
    List<E> Function(List<M> models) toEntities,
  ) {
    final failure = ErrorMapper.toFailure(error);
    if (_isTransient(failure)) {
      final cached = readCache();
      if (cached.isNotEmpty) return Result.success(toEntities(cached));
    }
    return Result.failure(failure);
  }

  /// Transport trouble, as opposed to the server telling us something true.
  ///
  /// `ServerFailure` is included: a 5xx or an unparseable body says the
  /// backend is unwell, not that the taxonomy changed, so last-known-good is
  /// the better answer.
  static bool _isTransient(Failure failure) =>
      failure is NetworkFailure ||
      failure is TimeoutFailure ||
      failure is ServerFailure;

  static List<Category> _toEntities(List<CategoryModel> models) =>
      models.map((model) => model.toEntity()).toList(growable: false);

  static List<Brand> _toBrandEntities(List<BrandModel> models) =>
      models.map((model) => model.toEntity()).toList(growable: false);

  static List<CategoryNode> _treeToEntities(List<CategoryNodeModel> nodes) =>
      nodes.map((node) => node.toEntity()).toList(growable: false);
}
