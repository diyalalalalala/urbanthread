import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasource/order_local_datasource.dart';
import '../datasource/order_remote_datasource.dart';
import '../models/order_model.dart';

/// The order history, with a read-only offline mirror.
class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({
    required OrderRemoteDataSource remote,
    required OrderLocalDataSource local,
    required NetworkInfo networkInfo,
  })  : _remote = remote,
        _local = local,
        _networkInfo = networkInfo;

  final OrderRemoteDataSource _remote;
  final OrderLocalDataSource _local;
  final NetworkInfo _networkInfo;

  /// Refused when the device is offline, in the caller's own words.
  static const _offlineWrite = NetworkFailure(
    'You need to be online to do this. Reconnect and try again.',
  );

  @override
  Future<Result<Order>> placeOrder(PlaceOrderDraft draft) async {
    // Checkout is never queued. The server re-reads live prices, reserves
    // stock atomically and settles payment inside one transaction; none of
    // that can be simulated on the device, and replaying the request later
    // could take stock the customer no longer wants at a price they never
    // saw. Better to refuse up front and say why.
    if (!await _networkInfo.isConnected) {
      return const Result.failure(
        NetworkFailure(
          'Placing an order needs a live connection — prices and stock are '
          'confirmed at the moment you pay. Reconnect and try again.',
        ),
      );
    }

    try {
      final envelope = await _remote.placeOrder(
        PlaceOrderRequest(
          shippingAddressId: draft.shippingAddressId,
          billingAddressId: draft.billingAddressId,
          paymentMethod: draft.paymentMethod.wireValue,
          couponCode: draft.couponCode,
          customerNote: draft.customerNote,
          // Sent only when set, so a normal checkout carries no trace of the
          // demo flag.
          simulateFailure: draft.simulateFailure ? true : null,
        ),
      );

      final order = envelope.data;
      await _local.writeOrder(order);
      // The new order belongs at the top of every list, and none of the
      // cached pages know about it.
      await _local.clearOrderPages();

      return Result.success(order.toEntity());
    } on Object catch (error) {
      // A declined mock payment arrives here as a 422. It means the server
      // rolled the whole transaction back — there is no order to look up, no
      // partial state to reconcile, and stock has already been released.
      // Callers must not treat this as "order created, payment pending".
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  @override
  Future<Result<Paginated<Order>>> getMyOrders(OrderFilter filter) async {
    final key = filter.cacheKey;

    if (!await _networkInfo.isConnected) return _cachedPage(key);

    try {
      final envelope = await _remote.getMyOrders(_queryOf(filter));
      final orders = envelope.data;
      final meta = envelope.meta ?? PaginationMeta.single(orders.length);

      await _local.writeOrderPage(key, orders, meta);

      return Result.success(_toPaginated(orders, meta));
    } on Object catch (error) {
      final failure = ErrorMapper.toFailure(error);

      // A dropped connection falls back to what is on disk; a 4xx does not —
      // an unauthorised or malformed request is not fixed by showing stale
      // rows as though they were current.
      if (failure is NetworkFailure || failure is TimeoutFailure) {
        final cached = _cachedPage(key);
        if (cached.isSuccess) return cached;
      }
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<Order>> getOrderById(String id) async {
    if (!await _networkInfo.isConnected) return _cachedOrder(id);

    try {
      final envelope = await _remote.getOrderById(id);
      await _local.writeOrder(envelope.data);
      return Result.success(envelope.data.toEntity());
    } on Object catch (error) {
      final failure = ErrorMapper.toFailure(error);
      if (failure is NetworkFailure || failure is TimeoutFailure) {
        final cached = _cachedOrder(id);
        if (cached.isSuccess) return cached;
      }
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<Order>> getOrderByNumber(String orderNumber) async {
    if (!await _networkInfo.isConnected) {
      return const Result.failure(
        EmptyCacheFailure(
          'Looking an order up by its number needs a connection. Your recent '
          'orders are available offline from the orders list.',
        ),
      );
    }

    try {
      final envelope = await _remote.getOrderByNumber(orderNumber.trim());
      await _local.writeOrder(envelope.data);
      return Result.success(envelope.data.toEntity());
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  @override
  Future<Result<OrderTracking>> trackOrder(String id) async {
    if (!await _networkInfo.isConnected) return _cachedTracking(id);

    try {
      final envelope = await _remote.trackOrder(id);
      await _local.writeTracking(id, envelope.data);
      return Result.success(envelope.data.toEntity());
    } on Object catch (error) {
      final failure = ErrorMapper.toFailure(error);
      if (failure is NetworkFailure || failure is TimeoutFailure) {
        final cached = _cachedTracking(id);
        if (cached.isSuccess) return cached;
      }
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<Order>> cancelOrder({
    required String id,
    String? reason,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Result.failure(_offlineWrite);
    }

    try {
      final trimmed = reason?.trim();
      final envelope = await _remote.cancelOrder(
        id,
        // An empty reason is omitted, not sent as '' — the validator treats a
        // falsy value as absent, but an explicit empty string would still be
        // stored as the cancellation reason.
        CancelOrderRequest(
          reason: (trimmed == null || trimmed.isEmpty) ? null : trimmed,
        ),
      );

      await _local.writeOrder(envelope.data);
      await _local.clearOrderPages();

      return Result.success(envelope.data.toEntity());
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  @override
  Future<Result<Order>> requestReturn(ReturnRequest request) async {
    if (!await _networkInfo.isConnected) {
      return const Result.failure(_offlineWrite);
    }

    try {
      final envelope = await _remote.requestReturn(
        request.orderId,
        ReturnRequestBody(
          itemIds: request.itemIds,
          reason: request.reason.trim(),
        ),
      );

      await _local.writeOrder(envelope.data);
      await _local.clearOrderPages();

      return Result.success(envelope.data.toEntity());
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  /// Builds the query map, omitting every unset filter.
  ///
  /// Omission matters: the backend's validator only knows these keys, and a
  /// key it does not recognise is dropped silently rather than rejected. A
  /// null slipping through as the string "null" would therefore not error —
  /// it would quietly return the wrong page.
  Map<String, dynamic> _queryOf(OrderFilter filter) => {
        'page': filter.page,
        'limit': filter.limit,
        if (filter.status != null) 'status': filter.status!.wireValue,
        if (filter.paymentStatus != null)
          'paymentStatus': filter.paymentStatus!.name,
        if (filter.paymentMethod != null)
          'paymentMethod': filter.paymentMethod!.wireValue,
        if (filter.from != null)
          'from': filter.from!.toUtc().toIso8601String(),
        if (filter.to != null) 'to': filter.to!.toUtc().toIso8601String(),
      };

  Paginated<Order> _toPaginated(List<OrderModel> orders, PaginationMeta meta) =>
      Paginated(
        items: orders.map((order) => order.toEntity()).toList(growable: false),
        page: meta.page,
        totalPages: meta.totalPages,
        total: meta.total,
        hasNextPage: meta.hasNextPage,
      );

  Result<Paginated<Order>> _cachedPage(String key) {
    final cached = _local.readOrderPage(key);
    if (cached == null) return const Result.failure(EmptyCacheFailure());
    return Result.success(_toPaginated(cached.orders, cached.meta));
  }

  Result<Order> _cachedOrder(String id) {
    final cached = _local.readOrder(id);
    return cached == null
        ? const Result.failure(EmptyCacheFailure())
        : Result.success(cached.toEntity());
  }

  Result<OrderTracking> _cachedTracking(String id) {
    final cached = _local.readTracking(id);
    if (cached != null) return Result.success(cached.toEntity());

    // Nothing tracked, but the order itself may be cached — its status and
    // timeline are the same data the tracking route projects, so rebuild the
    // view from it rather than showing an empty screen.
    final order = _local.readOrder(id);
    if (order == null) return const Result.failure(EmptyCacheFailure());

    final entity = order.toEntity();
    return Result.success(
      OrderTracking(
        orderNumber: entity.orderNumber,
        status: entity.status,
        timeline: entity.timeline,
        trackingNumber: entity.trackingNumber,
        estimatedDeliveryDate: entity.estimatedDeliveryDate,
        deliveredAt: entity.deliveredAt,
        cancelledAt: entity.cancelledAt,
        totalItems: entity.totalItems,
        isCancellable: entity.isCancellable,
        placedAt: entity.createdAt,
      ),
    );
  }
}
