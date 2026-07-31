import '../../../../core/network/api_envelope.dart';
import '../../../../core/storage/cache_store.dart';
import '../models/order_model.dart';

class OrderLocalDataSource {
  OrderLocalDataSource(this._cache);

  static const _listPrefix = 'orders:list:';
  static const _detailPrefix = 'orders:detail:';
  static const _trackingPrefix = 'orders:tracking:';

  final CacheStore _cache;

  Future<void> writeOrderPage(
    String filterKey,
    List<OrderModel> orders,
    PaginationMeta meta,
  ) =>
      _cache.write('$_listPrefix$filterKey', {
        'items': orders.map((order) => order.toJson()).toList(growable: false),
        'meta': meta.toJson(),
      });

  ({List<OrderModel> orders, PaginationMeta meta})? readOrderPage(
    String filterKey,
  ) =>
      _cache.read<({List<OrderModel> orders, PaginationMeta meta})?>(
          '$_listPrefix$filterKey', (json) {
        if (json is! Map) return null;

        final rawItems = json['items'];
        final rawMeta = json['meta'];
        if (rawItems is! List || rawMeta is! Map) return null;

        final orders = <OrderModel>[];
        for (final entry in rawItems) {
          if (entry is! Map) continue;
          try {
            orders.add(OrderModel.fromJson(Map<String, dynamic>.from(entry)));
          } on Object {
            continue;
          }
        }

        return (
          orders: orders,
          meta: PaginationMeta.fromJson(Map<String, dynamic>.from(rawMeta)),
        );
      });

  Future<void> writeOrder(OrderModel order) =>
      _cache.write('$_detailPrefix${order.id}', order.toJson());

  OrderModel? readOrder(String id) => _cache.read<OrderModel?>(
        '$_detailPrefix$id',
        (json) => json is Map
            ? OrderModel.fromJson(Map<String, dynamic>.from(json))
            : null,
      );

  Future<void> writeTracking(String orderId, OrderTrackingModel tracking) =>
      _cache.write('$_trackingPrefix$orderId', tracking.toJson());

  OrderTrackingModel? readTracking(String orderId) =>
      _cache.read<OrderTrackingModel?>(
        '$_trackingPrefix$orderId',
        (json) => json is Map
            ? OrderTrackingModel.fromJson(Map<String, dynamic>.from(json))
            : null,
      );

  Future<void> clearOrderPages() =>
      _cache.deleteWhereKeyStartsWith(_listPrefix);
}
