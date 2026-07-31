import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../categories/presentation/providers/categories_providers.dart';
import '../../data/datasource/home_local_datasource.dart';
import '../../data/datasource/home_remote_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/usecases/get_home_feed_usecase.dart';
import '../../domain/usecases/get_product_collection_usecase.dart';
import '../../domain/usecases/read_cached_home_feed_usecase.dart';

part 'home_providers.g.dart';

@Riverpod(keepAlive: true)
HomeRemoteDataSource homeRemoteDataSource(Ref ref) =>
    HomeRemoteDataSource(ref.watch(dioProvider));

@Riverpod(keepAlive: true)
HomeLocalDataSource homeLocalDataSource(Ref ref) =>
    HomeLocalDataSource(ref.watch(catalogueCacheProvider));

@Riverpod(keepAlive: true)
HomeRepository homeRepository(Ref ref) => HomeRepositoryImpl(
      remote: ref.watch(homeRemoteDataSourceProvider),
      local: ref.watch(homeLocalDataSourceProvider),
      networkInfo: ref.watch(networkInfoProvider),
    );

@riverpod
GetProductCollectionUseCase getProductCollectionUseCase(Ref ref) =>
    GetProductCollectionUseCase(ref.watch(homeRepositoryProvider));

@riverpod
GetHomeFeedUseCase getHomeFeedUseCase(Ref ref) => GetHomeFeedUseCase(
      home: ref.watch(homeRepositoryProvider),
      categories: ref.watch(categoriesRepositoryProvider),
    );

@riverpod
ReadCachedHomeFeedUseCase readCachedHomeFeedUseCase(Ref ref) =>
    ReadCachedHomeFeedUseCase(
      home: ref.watch(homeRepositoryProvider),
      categories: ref.watch(categoriesRepositoryProvider),
    );
