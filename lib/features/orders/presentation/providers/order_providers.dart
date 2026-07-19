import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasource/order_local_datasource.dart';
import '../../data/datasource/order_remote_datasource.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/cancel_order_usecase.dart';
import '../../domain/usecases/get_my_orders_usecase.dart';
import '../../domain/usecases/get_order_by_id_usecase.dart';
import '../../domain/usecases/get_order_by_number_usecase.dart';
import '../../domain/usecases/place_order_usecase.dart';
import '../../domain/usecases/request_return_usecase.dart';
import '../../domain/usecases/track_order_usecase.dart';

part 'order_providers.g.dart';

/// Wiring for the orders feature.
///
/// Separated from the notifiers so the object graph reads in one place, and
/// so a test can override [orderRepositoryProvider] alone.

@Riverpod(keepAlive: true)
OrderRemoteDataSource orderRemoteDataSource(Ref ref) =>
    OrderRemoteDataSource(ref.watch(dioProvider));

/// Orders cache into the `account` box — user data, cleared on sign-out,
/// spared when the catalogue cache is dropped to reclaim space.
@Riverpod(keepAlive: true)
OrderLocalDataSource orderLocalDataSource(Ref ref) =>
    OrderLocalDataSource(ref.watch(accountCacheProvider));

@Riverpod(keepAlive: true)
OrderRepository orderRepository(Ref ref) => OrderRepositoryImpl(
      remote: ref.watch(orderRemoteDataSourceProvider),
      local: ref.watch(orderLocalDataSourceProvider),
      networkInfo: ref.watch(networkInfoProvider),
    );

@riverpod
PlaceOrderUseCase placeOrderUseCase(Ref ref) =>
    PlaceOrderUseCase(ref.watch(orderRepositoryProvider));

@riverpod
GetMyOrdersUseCase getMyOrdersUseCase(Ref ref) =>
    GetMyOrdersUseCase(ref.watch(orderRepositoryProvider));

@riverpod
GetOrderByIdUseCase getOrderByIdUseCase(Ref ref) =>
    GetOrderByIdUseCase(ref.watch(orderRepositoryProvider));

@riverpod
GetOrderByNumberUseCase getOrderByNumberUseCase(Ref ref) =>
    GetOrderByNumberUseCase(ref.watch(orderRepositoryProvider));

@riverpod
TrackOrderUseCase trackOrderUseCase(Ref ref) =>
    TrackOrderUseCase(ref.watch(orderRepositoryProvider));

@riverpod
CancelOrderUseCase cancelOrderUseCase(Ref ref) =>
    CancelOrderUseCase(ref.watch(orderRepositoryProvider));

@riverpod
RequestReturnUseCase requestReturnUseCase(Ref ref) =>
    RequestReturnUseCase(ref.watch(orderRepositoryProvider));
