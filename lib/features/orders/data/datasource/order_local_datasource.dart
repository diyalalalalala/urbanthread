import '../../../../core/network/api_envelope.dart';
import '../../../../core/storage/cache_store.dart';
import '../models/order_model.dart';

/// Read-only offline copy of the order history.
///
/// Orders live in the `account` box rather than `catalogue`: they are the
/// user's own data, they are wiped on sign-out, and they must not be dropped
/// when the catalogue cache is cleared to reclaim space.
///
/// Note the asymmetry with the rest of the app's caching — **nothing here
/// writes to the server**. Placing, cancelling and returning all require a
/// live connection and are never queued, because every one of them moves
/// stock or money inside a server-side transaction whose outcome cannot be
/// predicted offline. A queued "place order" would be a promise the app has
/// no way to keep.
class OrderLocalDataSource {
  OrderLocalDataSource(this._cache);

  static const _listPrefix = 'orders:list:';
  static const _detailPrefix = 'orders:detail:';
  static const _trackingPrefix = 'orders:tracking:';

  final CacheStore _cache;

  // ── List ─────────────────────────────────────────────────────────────

  /// Caches one page together with its pagination meta.
  ///
  /// The meta is stored alongside the rows so an offline list can still say
  /// "page 2 of 5" and know whether to offer a "load more" — reconstructing
  /// that from a row count alone would be a guess.
  Future<void> writeOrderPage(
    String filterKey,
    List<OrderModel> orders,
    PaginationMeta meta,
  ) =>
      _cache.write('$_listPrefix$filterKey', {
        'items': orders.map((order) => order.toJson()).toList(growable: false),
        'meta': meta.toJson(),
      });

  /// The cached page, or null when this filter has never been fetched.
  ({List<OrderModel> orders, PaginationMeta meta})? readOrderPage(
    String filterKey,
  ) =>
      // The type argument is spelled nullable so the decoder may answer "this
      // entry is unusable" without CacheStore treating it as a parse crash.
      _cache.read<({List<OrderModel> orders, PaginationMeta meta})?>(
          '$_listPrefix$filterKey', (json) {
        if (json is! Map) return null;

        final rawItems = json['items'];
        final rawMeta = json['meta'];
        if (rawItems is! List || rawMeta is! Map) return null;

        final orders = <OrderModel>[];
        for (final entry in rawItems) {
          // One unreadable row — written by an older build — should not cost
          // the whole page. Skip it and show the rest.
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

  // ── Detail ───────────────────────────────────────────────────────────

  Future<void> writeOrder(OrderModel order) =>
      _cache.write('$_detailPrefix${order.id}', order.toJson());

  OrderModel? readOrder(String id) => _cache.read<OrderModel?>(
        '$_detailPrefix$id',
        (json) => json is Map
            ? OrderModel.fromJson(Map<String, dynamic>.from(json))
            : null,
      );

  // ── Tracking ─────────────────────────────────────────────────────────

  Future<void> writeTracking(String orderId, OrderTrackingModel tracking) =>
      _cache.write('$_trackingPrefix$orderId', tracking.toJson());

  OrderTrackingModel? readTracking(String orderId) =>
      _cache.read<OrderTrackingModel?>(
        '$_trackingPrefix$orderId',
        (json) => json is Map
            ? OrderTrackingModel.fromJson(Map<String, dynamic>.from(json))
            : null,
      );

  // ── Invalidation ─────────────────────────────────────────────────────

  /// Drops every cached page after a mutation.
  ///
  /// Cancelling or returning changes which status buckets an order belongs
  /// to, and there is no way to know from here which cached filters that
  /// affects — so all of them go. The detail entries are left alone; they are
  /// keyed by id and the caller rewrites the one it just changed.
  Future<void> clearOrderPages() =>
      _cache.deleteWhereKeyStartsWith(_listPrefix);
}
