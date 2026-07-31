import '../../../../core/domain/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/home_product.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasource/home_local_datasource.dart';
import '../datasource/home_remote_datasource.dart';
import '../models/home_product_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({
    required HomeRemoteDataSource remote,
    required HomeLocalDataSource local,
    required NetworkInfo networkInfo,
  })  : _remote = remote,
        _local = local,
        _networkInfo = networkInfo;

  final HomeRemoteDataSource _remote;
  final HomeLocalDataSource _local;
  final NetworkInfo _networkInfo;

  @override
  Future<Result<List<HomeProduct>>> getCollection(
    HomeCollection collection, {
    int limit = 10,
  }) async {
    if (!await _networkInfo.isConnected) {
      final cached = _local.read(collection);
      return cached.isEmpty
          ? const Result.failure(EmptyCacheFailure())
          : Result.success(_toEntities(cached));
    }

    try {
      final envelope = await _request(collection, limit);
      await _local.write(collection, envelope.data);
      return Result.success(_toEntities(envelope.data));
    } on Object catch (error) {
      final failure = ErrorMapper.toFailure(error);
      if (_isTransient(failure)) {
        final cached = _local.read(collection);
        if (cached.isNotEmpty) return Result.success(_toEntities(cached));
      }
      return Result.failure(failure);
    }
  }

  @override
  List<HomeProduct> cachedCollection(HomeCollection collection) =>
      _toEntities(_local.read(collection));

  @override
  bool isCollectionStale(HomeCollection collection) =>
      _local.isStale(collection);

  Future<ApiEnvelope<List<HomeProductModel>>> _request(
    HomeCollection collection,
    int limit,
  ) =>
      switch (collection) {
        HomeCollection.featured => _remote.getFeatured(limit: limit),
        HomeCollection.trending => _remote.getTrending(limit: limit),
        HomeCollection.bestSellers => _remote.getBestSellers(limit: limit),
        HomeCollection.newArrivals => _remote.getNewArrivals(limit: limit),
      };

  static bool _isTransient(Failure failure) =>
      failure is NetworkFailure ||
      failure is TimeoutFailure ||
      failure is ServerFailure;

  static List<HomeProduct> _toEntities(List<HomeProductModel> models) => models
      .where((model) => model.isRenderable)
      .map((model) => model.toEntity())
      .toList(growable: false);
}
