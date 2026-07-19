import 'package:equatable/equatable.dart';

import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../entities/order.dart';

/// Filters for `GET /orders/my-orders`.
///
/// Only these keys exist on the backend's validator. A parameter it does not
/// recognise is dropped silently rather than rejected, so a typo would fail
/// open and return the unfiltered history — which is why the query map is
/// built here once instead of at each call site.
class OrderFilter extends Equatable {
  const OrderFilter({
    this.page = 1,
    this.limit = 10,
    this.status,
    this.paymentStatus,
    this.paymentMethod,
    this.from,
    this.to,
  });

  final int page;
  final int limit;
  final OrderStatus? status;
  final PaymentStatus? paymentStatus;
  final PaymentMethod? paymentMethod;
  final DateTime? from;
  final DateTime? to;

  OrderFilter copyWith({
    int? page,
    int? limit,
    OrderStatus? status,
    bool clearStatus = false,
    PaymentStatus? paymentStatus,
    bool clearPaymentStatus = false,
    PaymentMethod? paymentMethod,
    bool clearPaymentMethod = false,
    DateTime? from,
    bool clearFrom = false,
    DateTime? to,
    bool clearTo = false,
  }) =>
      OrderFilter(
        page: page ?? this.page,
        limit: limit ?? this.limit,
        status: clearStatus ? null : (status ?? this.status),
        paymentStatus:
            clearPaymentStatus ? null : (paymentStatus ?? this.paymentStatus),
        paymentMethod:
            clearPaymentMethod ? null : (paymentMethod ?? this.paymentMethod),
        from: clearFrom ? null : (from ?? this.from),
        to: clearTo ? null : (to ?? this.to),
      );

  /// A stable key for the cached page, so switching status filters does not
  /// serve the previous filter's rows from disk.
  String get cacheKey => [
        'orders',
        'p$page',
        'l$limit',
        status?.wireValue ?? 'all',
        paymentStatus?.name ?? 'any',
        paymentMethod?.wireValue ?? 'any',
        from?.toIso8601String() ?? '',
        to?.toIso8601String() ?? '',
      ].join(':');

  @override
  List<Object?> get props =>
      [page, limit, status, paymentStatus, paymentMethod, from, to];
}

/// Everything `POST /orders` accepts — and nothing else.
///
/// The absent fields are the point. Items come from the server-side cart and
/// every total is computed there, so sending `items`, `subtotal`, `total`,
/// `grandTotal`, `unitPrice`, `price`, `amount`, `pricing`, `status`,
/// `orderNumber`, `user` or `userId` is rejected with a 422 by an explicit
/// tamper guard. Modelling the request as a closed type is what stops one
/// being added by accident.
class PlaceOrderDraft extends Equatable {
  const PlaceOrderDraft({
    required this.shippingAddressId,
    required this.paymentMethod,
    this.billingAddressId,
    this.couponCode,
    this.customerNote,
    this.simulateFailure = false,
  });

  /// An `_id` from the user's address book — **not** a full address. The
  /// backend looks it up on the user document and snapshots it itself; a
  /// posted address body would be ignored at best.
  final String shippingAddressId;

  /// Null means "bill to the shipping address", which is the common case.
  final String? billingAddressId;

  final PaymentMethod paymentMethod;

  /// 3–24 characters when present.
  final String? couponCode;

  /// Up to 500 characters.
  final String? customerNote;

  /// Demo affordance that forces the mock gateway to decline, so the failure
  /// path can be shown without engineering a cart total ending in 7.
  final bool simulateFailure;

  @override
  List<Object?> get props => [
        shippingAddressId,
        billingAddressId,
        paymentMethod,
        couponCode,
        customerNote,
        simulateFailure,
      ];
}

/// Parameters for `POST /orders/{id}/return`.
class ReturnRequest extends Equatable {
  const ReturnRequest({required this.orderId, required this.itemIds, required this.reason});

  final String orderId;

  /// **Order-item** subdocument ids, not product ids.
  final List<String> itemIds;

  /// Required, 5–300 characters. Returns are settled by a human and an
  /// unexplained request cannot be judged.
  final String reason;

  @override
  List<Object?> get props => [orderId, itemIds, reason];
}

/// The order history and its actions.
abstract interface class OrderRepository {
  /// Converts the server-side cart into an order.
  ///
  /// Synchronous and final: the response *is* the settled state. A
  /// [PaymentMethod.cod] order comes back `pending`/`pending`; a
  /// [PaymentMethod.mockGateway] order comes back `confirmed`/`paid`.
  ///
  /// A declined mock payment throws inside the server's transaction, so the
  /// whole thing rolls back — no order row, stock restored. The failure is a
  /// [ValidationFailure] and **no order exists**; never assume otherwise.
  Future<Result<Order>> placeOrder(PlaceOrderDraft draft);

  /// The signed-in customer's orders, newest first. Sort is fixed server-side.
  Future<Result<Paginated<Order>>> getMyOrders(OrderFilter filter);

  Future<Result<Order>> getOrderById(String id);

  /// Lookup by the `UT-YYYYMMDD-NNNN` reference, for "find my order".
  Future<Result<Order>> getOrderByNumber(String orderNumber);

  Future<Result<OrderTracking>> trackOrder(String id);

  /// Allowed only from `pending` and `confirmed`; anything later is a 422.
  Future<Result<Order>> cancelOrder({required String id, String? reason});

  /// Requires a delivered order inside the 7-day window.
  Future<Result<Order>> requestReturn(ReturnRequest request);
}
