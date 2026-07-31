import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending,
  confirmed,
  packed,
  shipped,
  outForDelivery,
  delivered,
  cancelled,
  returned;

  static OrderStatus parse(String? raw) => switch (raw?.toLowerCase()) {
        'confirmed' => OrderStatus.confirmed,
        'packed' => OrderStatus.packed,
        'shipped' => OrderStatus.shipped,
        'out_for_delivery' => OrderStatus.outForDelivery,
        'delivered' => OrderStatus.delivered,
        'cancelled' => OrderStatus.cancelled,
        'returned' => OrderStatus.returned,
        _ => OrderStatus.pending,
      };

  String get wireValue =>
      this == OrderStatus.outForDelivery ? 'out_for_delivery' : name;

  String get label => switch (this) {
        OrderStatus.pending => 'Pending',
        OrderStatus.confirmed => 'Confirmed',
        OrderStatus.packed => 'Packed',
        OrderStatus.shipped => 'Shipped',
        OrderStatus.outForDelivery => 'Out for delivery',
        OrderStatus.delivered => 'Delivered',
        OrderStatus.cancelled => 'Cancelled',
        OrderStatus.returned => 'Returned',
      };

  String get description => switch (this) {
        OrderStatus.pending => 'We have received your order.',
        OrderStatus.confirmed => 'Your order is confirmed and being prepared.',
        OrderStatus.packed => 'Your parcel is packed and waiting for pickup.',
        OrderStatus.shipped => 'Your parcel is on its way.',
        OrderStatus.outForDelivery => 'Your parcel is out for delivery today.',
        OrderStatus.delivered => 'Delivered. We hope you love it.',
        OrderStatus.cancelled => 'This order was cancelled.',
        OrderStatus.returned => 'This order was returned.',
      };

  bool get isTerminal =>
      this == OrderStatus.cancelled || this == OrderStatus.returned;

  static const progression = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.packed,
    OrderStatus.shipped,
    OrderStatus.outForDelivery,
    OrderStatus.delivered,
  ];

  static const customerCancellable = [
    OrderStatus.pending,
    OrderStatus.confirmed,
  ];
}

enum PaymentMethod {
  cod,
  mockGateway;

  static PaymentMethod parse(String? raw) =>
      raw?.toLowerCase() == 'mock_gateway'
          ? PaymentMethod.mockGateway
          : PaymentMethod.cod;

  String get wireValue => this == PaymentMethod.mockGateway ? 'mock_gateway' : 'cod';

  String get label => switch (this) {
        PaymentMethod.cod => 'Cash on delivery',
        PaymentMethod.mockGateway => 'Pay now (demo card)',
      };

  String get description => switch (this) {
        PaymentMethod.cod =>
          'Pay the courier in cash when your parcel arrives.',
        PaymentMethod.mockGateway =>
          'Settled instantly at checkout. This is a demo gateway — no real '
              'money moves.',
      };
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded;

  static PaymentStatus parse(String? raw) => switch (raw?.toLowerCase()) {
        'paid' => PaymentStatus.paid,
        'failed' => PaymentStatus.failed,
        'refunded' => PaymentStatus.refunded,
        _ => PaymentStatus.pending,
      };

  String get label => switch (this) {
        PaymentStatus.pending => 'Payment pending',
        PaymentStatus.paid => 'Paid',
        PaymentStatus.failed => 'Payment failed',
        PaymentStatus.refunded => 'Refunded',
      };
}

enum ReturnStatus {
  requested,
  approved,
  rejected,
  refunded;

  static ReturnStatus? parse(String? raw) => switch (raw?.toLowerCase()) {
        'requested' => ReturnStatus.requested,
        'approved' => ReturnStatus.approved,
        'rejected' => ReturnStatus.rejected,
        'refunded' => ReturnStatus.refunded,
        _ => null,
      };

  String get label => switch (this) {
        ReturnStatus.requested => 'Return requested',
        ReturnStatus.approved => 'Return approved',
        ReturnStatus.rejected => 'Return rejected',
        ReturnStatus.refunded => 'Refunded',
      };
}

class OrderAddress extends Equatable {
  const OrderAddress({
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    this.state = '',
    this.postalCode = '',
    this.country = 'Nepal',
    this.landmark = '',
  });

  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String landmark;

  String get singleLine => [
        street,
        if (landmark.isNotEmpty) landmark,
        city,
        if (state.isNotEmpty) state,
        if (postalCode.isNotEmpty) postalCode,
        country,
      ].join(', ');

  @override
  List<Object?> get props =>
      [fullName, phone, street, city, state, postalCode, country, landmark];
}

class OrderItem extends Equatable {
  const OrderItem({
    required this.id,
    required this.productId,
    required this.variantId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.image,
    this.sku = '',
    this.color = '',
    this.size = '',
    this.brandName = '',
    this.returnStatus,
    this.returnReason = '',
    this.returnRequestedAt,
    this.returnResolvedAt,
    this.returnAdminNote = '',
  });

  final String id;

  final String productId;

  final String variantId;
  final String name;
  final String? image;
  final String sku;
  final String color;
  final String size;
  final String brandName;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  final ReturnStatus? returnStatus;
  final String returnReason;
  final DateTime? returnRequestedAt;
  final DateTime? returnResolvedAt;
  final String returnAdminNote;

  String? get variantLabel {
    final parts = [
      if (color.isNotEmpty) color,
      if (size.isNotEmpty) size,
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  bool get isReturnable =>
      returnStatus == null || returnStatus == ReturnStatus.rejected;

  @override
  List<Object?> get props => [
        id,
        productId,
        variantId,
        name,
        image,
        sku,
        color,
        size,
        brandName,
        quantity,
        unitPrice,
        lineTotal,
        returnStatus,
        returnReason,
        returnRequestedAt,
        returnResolvedAt,
        returnAdminNote,
      ];
}

class OrderPricing extends Equatable {
  const OrderPricing({
    required this.subtotal,
    required this.grandTotal,
    this.discount = 0,
    this.tax = 0,
    this.shipping = 0,
    this.currency = 'NPR',
    this.taxRate = 0,
  });

  final double subtotal;
  final double discount;
  final double tax;
  final double shipping;
  final double grandTotal;
  final String currency;

  final double taxRate;

  bool get hasDiscount => discount > 0;

  bool get isFreeShipping => shipping <= 0;

  String get taxLabel =>
      taxRate <= 0 ? 'Tax' : '${(taxRate * 100).toStringAsFixed(0)}% VAT';

  @override
  List<Object?> get props =>
      [subtotal, discount, tax, shipping, grandTotal, currency, taxRate];
}

class OrderCoupon extends Equatable {
  const OrderCoupon({this.code, this.couponId, this.discountAmount = 0});

  final String? code;
  final String? couponId;
  final double discountAmount;

  bool get isApplied => code != null && code!.isNotEmpty;

  @override
  List<Object?> get props => [code, couponId, discountAmount];
}

class OrderPayment extends Equatable {
  const OrderPayment({
    required this.method,
    required this.status,
    this.transactionId,
    this.paidAt,
    this.failureReason = '',
    this.refundedAt,
    this.refundAmount = 0,
  });

  final PaymentMethod method;
  final PaymentStatus status;
  final String? transactionId;
  final DateTime? paidAt;
  final String failureReason;
  final DateTime? refundedAt;
  final double refundAmount;

  bool get isPaid => status == PaymentStatus.paid;

  bool get isRefunded => status == PaymentStatus.refunded;

  bool get isCollectedOnDelivery =>
      method == PaymentMethod.cod && status == PaymentStatus.pending;

  @override
  List<Object?> get props => [
        method,
        status,
        transactionId,
        paidAt,
        failureReason,
        refundedAt,
        refundAmount,
      ];
}

class OrderTimelineEntry extends Equatable {
  const OrderTimelineEntry({
    required this.status,
    this.note = '',
    this.changedBy,
    this.occurredAt,
  });

  final OrderStatus status;
  final String note;

  final String? changedBy;
  final DateTime? occurredAt;

  @override
  List<Object?> get props => [status, note, changedBy, occurredAt];
}

class Order extends Equatable {
  const Order({
    required this.id,
    required this.orderNumber,
    required this.items,
    required this.shippingAddress,
    required this.billingAddress,
    required this.pricing,
    required this.payment,
    required this.status,
    this.customerEmail = '',
    this.customerName = '',
    this.coupon = const OrderCoupon(),
    this.timeline = const [],
    this.returnStatus,
    this.customerNote = '',
    this.adminNote = '',
    this.cancellationReason = '',
    this.deliveredAt,
    this.cancelledAt,
    this.estimatedDeliveryDate,
    this.trackingNumber,
    this.createdAt,
    this.updatedAt,
    this.totalItemsOrNull,
    this.isCancellableOrNull,
    this.isTerminalOrNull,
  });

  final String id;

  final String orderNumber;

  final String customerEmail;
  final String customerName;
  final List<OrderItem> items;
  final OrderAddress shippingAddress;
  final OrderAddress billingAddress;
  final OrderPricing pricing;
  final OrderCoupon coupon;
  final OrderPayment payment;
  final OrderStatus status;
  final List<OrderTimelineEntry> timeline;

  final ReturnStatus? returnStatus;

  final String customerNote;
  final String adminNote;
  final String cancellationReason;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final DateTime? estimatedDeliveryDate;
  final String? trackingNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final int? totalItemsOrNull;
  final bool? isCancellableOrNull;
  final bool? isTerminalOrNull;

  int get totalItems =>
      totalItemsOrNull ??
      items.fold(0, (sum, item) => sum + item.quantity);

  bool get isCancellable =>
      isCancellableOrNull ?? OrderStatus.customerCancellable.contains(status);

  bool get isTerminal => isTerminalOrNull ?? status.isTerminal;

  static const returnWindow = Duration(days: 7);

  bool get canRequestReturn {
    if (status != OrderStatus.delivered || deliveredAt == null) return false;
    if (returnStatus == ReturnStatus.requested) return false;
    if (DateTime.now().difference(deliveredAt!) > returnWindow) return false;
    return items.any((item) => item.isReturnable);
  }

  int? get returnWindowDaysRemaining {
    if (status != OrderStatus.delivered || deliveredAt == null) return null;
    final closesAt = deliveredAt!.add(returnWindow);
    final remaining = closesAt.difference(DateTime.now()).inDays;
    return remaining < 0 ? 0 : remaining;
  }

  List<OrderItem> get returnableItems =>
      items.where((item) => item.isReturnable).toList(growable: false);

  bool get hasSeparateBillingAddress => billingAddress != shippingAddress;

  List<OrderTimelineEntry> get chronologicalTimeline {
    final sorted = [...timeline];
    sorted.sort((a, b) {
      final left = a.occurredAt;
      final right = b.occurredAt;
      if (left == null || right == null) return 0;
      return left.compareTo(right);
    });
    return sorted;
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        customerEmail,
        customerName,
        items,
        shippingAddress,
        billingAddress,
        pricing,
        coupon,
        payment,
        status,
        timeline,
        returnStatus,
        customerNote,
        adminNote,
        cancellationReason,
        deliveredAt,
        cancelledAt,
        estimatedDeliveryDate,
        trackingNumber,
        createdAt,
        updatedAt,
        totalItemsOrNull,
        isCancellableOrNull,
        isTerminalOrNull,
      ];
}

class OrderTracking extends Equatable {
  const OrderTracking({
    required this.orderNumber,
    required this.status,
    this.timeline = const [],
    this.trackingNumber,
    this.estimatedDeliveryDate,
    this.deliveredAt,
    this.cancelledAt,
    this.totalItems = 0,
    this.isCancellable = false,
    this.placedAt,
  });

  final String orderNumber;
  final OrderStatus status;
  final List<OrderTimelineEntry> timeline;
  final String? trackingNumber;
  final DateTime? estimatedDeliveryDate;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;

  final int totalItems;
  final bool isCancellable;

  final DateTime? placedAt;

  bool get hasTrackingNumber =>
      trackingNumber != null && trackingNumber!.isNotEmpty;

  List<OrderTimelineEntry> get chronologicalTimeline {
    final sorted = [...timeline];
    sorted.sort((a, b) {
      final left = a.occurredAt;
      final right = b.occurredAt;
      if (left == null || right == null) return 0;
      return left.compareTo(right);
    });
    return sorted;
  }

  int get progressIndex => OrderStatus.progression.indexOf(status);

  @override
  List<Object?> get props => [
        orderNumber,
        status,
        timeline,
        trackingNumber,
        estimatedDeliveryDate,
        deliveredAt,
        cancelledAt,
        totalItems,
        isCancellable,
        placedAt,
      ];
}
