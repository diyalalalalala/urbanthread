import 'package:equatable/equatable.dart';

/// How far along an order is.
///
/// All eight states the backend's `ORDER_STATUS` enum can hold. The wire form
/// of [outForDelivery] is snake_case (`out_for_delivery`) while every other
/// value is its own name, so [wireValue] cannot simply be `name`.
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

  /// One line of reassurance for the customer, shown under the status chip.
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

  /// Nothing further will happen to the order.
  ///
  /// Mirrors the backend's `isTerminal` virtual, which is derived from an
  /// empty transition list in `ORDER_STATUS_FLOW`.
  bool get isTerminal =>
      this == OrderStatus.cancelled || this == OrderStatus.returned;

  /// The happy-path sequence, for the tracking stepper. Cancelled and
  /// returned are deliberately absent — they are exits from this path, not
  /// steps along it, and drawing them as future steps would imply every order
  /// ends up cancelled.
  static const progression = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.packed,
    OrderStatus.shipped,
    OrderStatus.outForDelivery,
    OrderStatus.delivered,
  ];

  /// Statuses a customer may cancel from themselves. The backend enforces the
  /// same pair in `CUSTOMER_CANCELLABLE_STATUSES`; checking it client-side
  /// hides the button rather than letting the tap earn a 422.
  static const customerCancellable = [
    OrderStatus.pending,
    OrderStatus.confirmed,
  ];
}

/// How the order was paid for.
///
/// There are only these two. No payment gateway exists in this system —
/// [mockGateway] settles in-process inside the `POST /orders` transaction, so
/// there is no redirect, no WebView and nothing to poll.
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

/// Return state, held both on the order as a whole and per item.
///
/// Null — not a member of this enum — means "no return has been asked for",
/// which is the overwhelmingly common case.
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

/// The address as it was at the moment of purchase.
///
/// Deliberately *not* the address-book [Address] entity from the
/// authentication feature. The backend embeds this snapshot with
/// `{_id: false}`, so it has no id, no `type` and no `isDefault` — an order
/// records where the parcel went, not which book entry it came from. Editing
/// the address book later must not rewrite a delivered order's history, and
/// giving this its own type is what makes that impossible to get wrong.
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

/// One purchased line.
///
/// Flat, unlike a cart item: the cart nests its copied fields under
/// `snapshot`, an order does not. Reading `item.name` here and
/// `item.snapshot.name` there is the single most common mix-up between the
/// two shapes.
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

  /// The order-item subdocument id. This — not [productId] — is what
  /// `POST /orders/{id}/return` expects in its `itemIds` array.
  final String id;

  /// A raw ObjectId string. The backend never populates it on an order, so
  /// there is no product document here to read a current price or slug from;
  /// it exists for "buy this again" links and analytics only.
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

  /// `Charcoal · M`, or null when the variant has neither axis.
  String? get variantLabel {
    final parts = [
      if (color.isNotEmpty) color,
      if (size.isNotEmpty) size,
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  /// Whether this line may still be included in a return request.
  ///
  /// A rejected return may be re-requested; anything requested, approved or
  /// already refunded may not, or the customer would be credited twice for
  /// one garment.
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

/// Every money component of the order, stored rather than recomputed.
///
/// The total is **`grandTotal`**. There is no `total` key anywhere in this
/// API, and reading one would silently yield zero.
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

  /// The rate actually applied, retained so an old order's tax line stays
  /// reproducible after a VAT change.
  final double taxRate;

  bool get hasDiscount => discount > 0;

  bool get isFreeShipping => shipping <= 0;

  /// `13% VAT`, for the tax row's label.
  String get taxLabel =>
      taxRate <= 0 ? 'Tax' : '${(taxRate * 100).toStringAsFixed(0)}% VAT';

  @override
  List<Object?> get props =>
      [subtotal, discount, tax, shipping, grandTotal, currency, taxRate];
}

/// The coupon redeemed against this order, if any.
class OrderCoupon extends Equatable {
  const OrderCoupon({this.code, this.couponId, this.discountAmount = 0});

  final String? code;
  final String? couponId;
  final double discountAmount;

  bool get isApplied => code != null && code!.isNotEmpty;

  @override
  List<Object?> get props => [code, couponId, discountAmount];
}

/// Payment state. For [PaymentMethod.cod] this stays pending until the courier
/// collects; for [PaymentMethod.mockGateway] it is already settled by the time
/// the client sees the order.
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

  /// True when money is still owed at the door.
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

/// One status change, in the order's history.
///
/// The array is called **`timeline`**, not `statusHistory`, and its entries
/// carry no `_id` — the subdocument schema sets `{_id: false}`. Equality
/// therefore has to come from the contents, which Equatable gives us anyway.
class OrderTimelineEntry extends Equatable {
  const OrderTimelineEntry({
    required this.status,
    this.note = '',
    this.changedBy,
    this.occurredAt,
  });

  final OrderStatus status;
  final String note;

  /// The admin who made the change; null for system transitions.
  final String? changedBy;
  final DateTime? occurredAt;

  @override
  List<Object?> get props => [status, note, changedBy, occurredAt];
}

/// A placed order.
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

  /// `UT-YYYYMMDD-NNNN`, the reference a customer quotes to support.
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

  /// Order-level return state, distinct from the per-item states.
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

  // ── Server virtuals ────────────────────────────────────────────────────
  // `totalItems`, `isCancellable` and `isTerminal` are Mongoose virtuals, so
  // they are present on hydrated responses (POST /orders, the detail route,
  // cancel, return) and **absent from `GET /orders/my-orders`**, which reads
  // lean. Rather than let a list row silently report zero items, each is held
  // nullable and read through a getter that falls back to a client-side
  // computation over the stored fields.

  final int? totalItemsOrNull;
  final bool? isCancellableOrNull;
  final bool? isTerminalOrNull;

  /// Total units across every line.
  int get totalItems =>
      totalItemsOrNull ??
      items.fold(0, (sum, item) => sum + item.quantity);

  /// Whether the customer may still cancel this themselves.
  bool get isCancellable =>
      isCancellableOrNull ?? OrderStatus.customerCancellable.contains(status);

  bool get isTerminal => isTerminalOrNull ?? status.isTerminal;

  /// How long after delivery a return may be requested. Mirrors the
  /// backend's `business.returnWindowDays`.
  static const returnWindow = Duration(days: 7);

  /// Whether the *order* is eligible for a return request right now.
  ///
  /// Three conditions, all enforced server-side as well: it must be
  /// delivered, inside the window measured from [deliveredAt], and not
  /// already have a request under review.
  bool get canRequestReturn {
    if (status != OrderStatus.delivered || deliveredAt == null) return false;
    if (returnStatus == ReturnStatus.requested) return false;
    if (DateTime.now().difference(deliveredAt!) > returnWindow) return false;
    return items.any((item) => item.isReturnable);
  }

  /// Days left to start a return, or null when the window does not apply.
  int? get returnWindowDaysRemaining {
    if (status != OrderStatus.delivered || deliveredAt == null) return null;
    final closesAt = deliveredAt!.add(returnWindow);
    final remaining = closesAt.difference(DateTime.now()).inDays;
    return remaining < 0 ? 0 : remaining;
  }

  /// Items a return request may include.
  List<OrderItem> get returnableItems =>
      items.where((item) => item.isReturnable).toList(growable: false);

  bool get hasSeparateBillingAddress => billingAddress != shippingAddress;

  /// Timeline oldest-first, which is the order a stepper reads in. The API
  /// appends chronologically, but sorting defensively costs nothing and
  /// protects the stepper from an out-of-order entry.
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

/// The narrow projection `GET /orders/{id}/track` answers with.
///
/// Hand-assembled by the backend rather than a subset of the order document,
/// which is why it carries no prices or address, and why the placement time
/// arrives as **`placedAt`** — it is `createdAt` renamed.
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

  /// Present here even though the list route drops it — this route reads a
  /// hydrated document, so the virtuals survive.
  final int totalItems;
  final bool isCancellable;

  /// `createdAt` under another name.
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

  /// The furthest step reached along [OrderStatus.progression], or -1 when the
  /// order left the happy path (cancelled/returned).
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
