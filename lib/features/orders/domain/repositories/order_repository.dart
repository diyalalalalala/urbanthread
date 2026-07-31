import 'package:equatable/equatable.dart';

import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../entities/order.dart';

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

class PlaceOrderDraft extends Equatable {
  const PlaceOrderDraft({
    required this.shippingAddressId,
    required this.paymentMethod,
    this.billingAddressId,
    this.couponCode,
    this.customerNote,
    this.simulateFailure = false,
  });

  final String shippingAddressId;

  final String? billingAddressId;

  final PaymentMethod paymentMethod;

  final String? couponCode;

  final String? customerNote;

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

class ReturnRequest extends Equatable {
  const ReturnRequest({required this.orderId, required this.itemIds, required this.reason});

  final String orderId;

  final List<String> itemIds;

  final String reason;

  @override
  List<Object?> get props => [orderId, itemIds, reason];
}

abstract interface class OrderRepository {
  Future<Result<Order>> placeOrder(PlaceOrderDraft draft);

  Future<Result<Paginated<Order>>> getMyOrders(OrderFilter filter);

  Future<Result<Order>> getOrderById(String id);

  Future<Result<Order>> getOrderByNumber(String orderNumber);

  Future<Result<OrderTracking>> trackOrder(String id);

  Future<Result<Order>> cancelOrder({required String id, String? reason});

  Future<Result<Order>> requestReturn(ReturnRequest request);
}
