import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/media_url.dart';
import '../../domain/entities/order.dart';

part 'order_model.g.dart';

/// Reads an id that the API sometimes populates into a whole document.
///
/// `order.user` is a bare ObjectId string on the lean list route but a
/// populated `{_id, name, email}` object on the detail route, and
/// `timeline[].changedBy` is either an id or null. One tolerant reader keeps
/// that asymmetry from becoming a parse failure on whichever route was not
/// tested.
String? _readId(Object? raw) => switch (raw) {
      String value when value.isNotEmpty => value,
      Map<String, dynamic> value => value['_id'] as String?,
      _ => null,
    };

String? _writeId(String? value) => value;

/// The API's null sentinel for a string is `''`, not null — `image`,
/// `trackingNumber`, `sku` and friends all default to an empty string. This
/// turns that back into a real Dart null at the entity boundary.
String? _nullIfBlank(String? value) =>
    (value == null || value.isEmpty) ? null : value;

DateTime? _parseDate(String? raw) =>
    (raw == null || raw.isEmpty) ? null : DateTime.tryParse(raw);

/// Tolerates an integer where a double is expected — Mongo stores a whole
/// rupee amount as an int, and `as double` on that throws.
double _readNum(Object? raw) => switch (raw) {
      num value => value.toDouble(),
      String value => double.tryParse(value) ?? 0,
      _ => 0,
    };

@JsonSerializable(createToJson: true)
class OrderModel {
  const OrderModel({
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
    this.coupon,
    this.timeline = const [],
    this.returnStatus,
    this.customerNote = '',
    this.adminNote = '',
    this.cancellationReason = '',
    this.deliveredAt,
    this.cancelledAt,
    this.estimatedDeliveryDate,
    this.trackingNumber = '',
    this.createdAt,
    this.updatedAt,
    this.totalItems,
    this.isCancellable,
    this.isTerminal,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  @JsonKey(name: '_id')
  final String id;

  final String orderNumber;
  final String customerEmail;
  final String customerName;
  final List<OrderItemModel> items;
  final OrderAddressModel shippingAddress;
  final OrderAddressModel billingAddress;
  final OrderPricingModel pricing;

  /// Always present as an object, but every field inside it is nullable when
  /// no coupon was used.
  final OrderCouponModel? coupon;

  final OrderPaymentModel payment;
  final String status;
  final List<OrderTimelineEntryModel> timeline;

  /// Null unless a return has been asked for.
  final String? returnStatus;

  final String customerNote;
  final String adminNote;
  final String cancellationReason;
  final String? deliveredAt;
  final String? cancelledAt;
  final String? estimatedDeliveryDate;
  final String trackingNumber;
  final String? createdAt;
  final String? updatedAt;

  // ── Virtuals ───────────────────────────────────────────────────────────
  // Mongoose virtuals, so they ride along on hydrated responses and vanish
  // from `GET /orders/my-orders`, which reads `.lean()`. Nullable here and
  // recomputed in the entity — defaulting them to 0/false would make every
  // list row claim it holds nothing and cannot be cancelled.

  final int? totalItems;
  final bool? isCancellable;
  final bool? isTerminal;

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  Order toEntity() {
    final shipping = shippingAddress.toEntity();
    return Order(
      id: id,
      orderNumber: orderNumber,
      customerEmail: customerEmail,
      customerName: customerName,
      items: items.map((item) => item.toEntity()).toList(growable: false),
      shippingAddress: shipping,
      billingAddress: billingAddress.toEntity(),
      pricing: pricing.toEntity(),
      coupon: coupon?.toEntity() ?? const OrderCoupon(),
      payment: payment.toEntity(),
      status: OrderStatus.parse(status),
      timeline:
          timeline.map((entry) => entry.toEntity()).toList(growable: false),
      returnStatus: ReturnStatus.parse(returnStatus),
      customerNote: customerNote,
      adminNote: adminNote,
      cancellationReason: cancellationReason,
      deliveredAt: _parseDate(deliveredAt),
      cancelledAt: _parseDate(cancelledAt),
      estimatedDeliveryDate: _parseDate(estimatedDeliveryDate),
      trackingNumber: _nullIfBlank(trackingNumber),
      createdAt: _parseDate(createdAt),
      updatedAt: _parseDate(updatedAt),
      totalItemsOrNull: totalItems,
      isCancellableOrNull: isCancellable,
      isTerminalOrNull: isTerminal,
    );
  }
}

/// A purchased line.
///
/// Flat: `name`, `unitPrice` and the rest sit directly on the item. Cart
/// items nest the same fields under `snapshot`; orders do not.
@JsonSerializable(createToJson: true)
class OrderItemModel {
  const OrderItemModel({
    required this.id,
    required this.product,
    required this.variantId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.image = '',
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

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);

  /// The subdocument id, and the only id `POST /orders/{id}/return` accepts.
  @JsonKey(name: '_id')
  final String id;

  /// Never populated on an order — the record is a snapshot by design, so
  /// this stays a raw ObjectId string. Read through the tolerant reader
  /// anyway, so a future populate would not break parsing.
  @JsonKey(fromJson: _readId, toJson: _writeId)
  final String? product;

  @JsonKey(fromJson: _readId, toJson: _writeId)
  final String? variantId;

  final String name;
  final String image;
  final String sku;
  final String color;
  final String size;
  final String brandName;
  final int quantity;

  @JsonKey(fromJson: _readNum)
  final double unitPrice;

  @JsonKey(fromJson: _readNum)
  final double lineTotal;

  final String? returnStatus;
  final String returnReason;
  final String? returnRequestedAt;
  final String? returnResolvedAt;
  final String returnAdminNote;

  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);

  OrderItem toEntity() => OrderItem(
        id: id,
        productId: product ?? '',
        variantId: variantId ?? '',
        name: name,
        image: MediaUrl.resolve(image),
        sku: sku,
        color: color,
        size: size,
        brandName: brandName,
        quantity: quantity,
        unitPrice: unitPrice,
        lineTotal: lineTotal,
        returnStatus: ReturnStatus.parse(returnStatus),
        returnReason: returnReason,
        returnRequestedAt: _parseDate(returnRequestedAt),
        returnResolvedAt: _parseDate(returnResolvedAt),
        returnAdminNote: returnAdminNote,
      );
}

/// The embedded address snapshot.
///
/// Declared with `{_id: false}` server-side, so unlike an address-book entry
/// it has no `_id`, no `type` and no `isDefault`. Do not try to read them.
@JsonSerializable(createToJson: true)
class OrderAddressModel {
  const OrderAddressModel({
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    this.state = '',
    this.postalCode = '',
    this.country = 'Nepal',
    this.landmark = '',
  });

  factory OrderAddressModel.fromJson(Map<String, dynamic> json) =>
      _$OrderAddressModelFromJson(json);

  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String landmark;

  Map<String, dynamic> toJson() => _$OrderAddressModelToJson(this);

  OrderAddress toEntity() => OrderAddress(
        fullName: fullName,
        phone: phone,
        street: street,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
        landmark: landmark,
      );
}

@JsonSerializable(createToJson: true)
class OrderPricingModel {
  const OrderPricingModel({
    required this.subtotal,
    required this.grandTotal,
    this.discount = 0,
    this.tax = 0,
    this.shipping = 0,
    this.currency = 'NPR',
    this.taxRate = 0,
  });

  factory OrderPricingModel.fromJson(Map<String, dynamic> json) =>
      _$OrderPricingModelFromJson(json);

  @JsonKey(fromJson: _readNum)
  final double subtotal;

  @JsonKey(fromJson: _readNum)
  final double discount;

  @JsonKey(fromJson: _readNum)
  final double tax;

  @JsonKey(fromJson: _readNum)
  final double shipping;

  /// The total. There is no `total` key on this object — reading one would
  /// quietly yield nothing.
  @JsonKey(fromJson: _readNum)
  final double grandTotal;

  final String currency;

  @JsonKey(fromJson: _readNum)
  final double taxRate;

  Map<String, dynamic> toJson() => _$OrderPricingModelToJson(this);

  OrderPricing toEntity() => OrderPricing(
        subtotal: subtotal,
        discount: discount,
        tax: tax,
        shipping: shipping,
        grandTotal: grandTotal,
        currency: currency,
        taxRate: taxRate,
      );
}

@JsonSerializable(createToJson: true)
class OrderCouponModel {
  const OrderCouponModel({this.code, this.couponId, this.discountAmount = 0});

  factory OrderCouponModel.fromJson(Map<String, dynamic> json) =>
      _$OrderCouponModelFromJson(json);

  final String? code;

  @JsonKey(fromJson: _readId, toJson: _writeId)
  final String? couponId;

  @JsonKey(fromJson: _readNum)
  final double discountAmount;

  Map<String, dynamic> toJson() => _$OrderCouponModelToJson(this);

  OrderCoupon toEntity() => OrderCoupon(
        code: _nullIfBlank(code),
        couponId: couponId,
        discountAmount: discountAmount,
      );
}

@JsonSerializable(createToJson: true)
class OrderPaymentModel {
  const OrderPaymentModel({
    required this.method,
    this.status = 'pending',
    this.transactionId,
    this.paidAt,
    this.failureReason = '',
    this.refundedAt,
    this.refundAmount = 0,
  });

  factory OrderPaymentModel.fromJson(Map<String, dynamic> json) =>
      _$OrderPaymentModelFromJson(json);

  final String method;
  final String status;
  final String? transactionId;
  final String? paidAt;
  final String failureReason;
  final String? refundedAt;

  @JsonKey(fromJson: _readNum)
  final double refundAmount;

  Map<String, dynamic> toJson() => _$OrderPaymentModelToJson(this);

  OrderPayment toEntity() => OrderPayment(
        method: PaymentMethod.parse(method),
        status: PaymentStatus.parse(status),
        transactionId: _nullIfBlank(transactionId),
        paidAt: _parseDate(paidAt),
        failureReason: failureReason,
        refundedAt: _parseDate(refundedAt),
        refundAmount: refundAmount,
      );
}

/// One `timeline` entry. Note the array's name — it is `timeline`, never
/// `statusHistory` — and that entries carry no `_id`.
@JsonSerializable(createToJson: true)
class OrderTimelineEntryModel {
  const OrderTimelineEntryModel({
    required this.status,
    this.note = '',
    this.changedBy,
    this.occurredAt,
  });

  factory OrderTimelineEntryModel.fromJson(Map<String, dynamic> json) =>
      _$OrderTimelineEntryModelFromJson(json);

  final String status;
  final String note;

  /// Null for system-generated transitions; an admin's id otherwise, which
  /// the API may populate into an object.
  @JsonKey(fromJson: _readId, toJson: _writeId)
  final String? changedBy;

  final String? occurredAt;

  Map<String, dynamic> toJson() => _$OrderTimelineEntryModelToJson(this);

  OrderTimelineEntry toEntity() => OrderTimelineEntry(
        status: OrderStatus.parse(status),
        note: note,
        changedBy: changedBy,
        occurredAt: _parseDate(occurredAt),
      );
}

/// `GET /orders/{id}/track` — a hand-built projection, not a slice of the
/// order document. Its `placedAt` is the order's `createdAt` renamed, and its
/// virtuals are present because the route reads a hydrated document.
@JsonSerializable(createToJson: true)
class OrderTrackingModel {
  const OrderTrackingModel({
    required this.orderNumber,
    required this.status,
    this.timeline = const [],
    this.trackingNumber = '',
    this.estimatedDeliveryDate,
    this.deliveredAt,
    this.cancelledAt,
    this.totalItems = 0,
    this.isCancellable = false,
    this.placedAt,
  });

  factory OrderTrackingModel.fromJson(Map<String, dynamic> json) =>
      _$OrderTrackingModelFromJson(json);

  final String orderNumber;
  final String status;
  final List<OrderTimelineEntryModel> timeline;
  final String trackingNumber;
  final String? estimatedDeliveryDate;
  final String? deliveredAt;
  final String? cancelledAt;
  final int totalItems;
  final bool isCancellable;
  final String? placedAt;

  Map<String, dynamic> toJson() => _$OrderTrackingModelToJson(this);

  OrderTracking toEntity() => OrderTracking(
        orderNumber: orderNumber,
        status: OrderStatus.parse(status),
        timeline:
            timeline.map((entry) => entry.toEntity()).toList(growable: false),
        trackingNumber: _nullIfBlank(trackingNumber),
        estimatedDeliveryDate: _parseDate(estimatedDeliveryDate),
        deliveredAt: _parseDate(deliveredAt),
        cancelledAt: _parseDate(cancelledAt),
        totalItems: totalItems,
        isCancellable: isCancellable,
        placedAt: _parseDate(placedAt),
      );
}

// ── Request bodies ───────────────────────────────────────────────────────

/// The `POST /orders` body.
///
/// `includeIfNull: false` is load-bearing. `billingAddressId` absent means
/// "same as shipping"; sending it as an explicit null would still satisfy the
/// optional-with-null validator, but omitting the other optionals matters —
/// `couponCode` and `customerNote` are validated as non-empty strings when
/// present, so a null would be rejected where an absent key is fine.
///
/// Note what is *not* here: no items, no pricing, no status. All of those are
/// on the backend's explicit reject list and turn the request into a 422.
@JsonSerializable(createFactory: false, includeIfNull: false)
class PlaceOrderRequest {
  const PlaceOrderRequest({
    required this.shippingAddressId,
    required this.paymentMethod,
    this.billingAddressId,
    this.couponCode,
    this.customerNote,
    this.simulateFailure,
  });

  final String shippingAddressId;
  final String? billingAddressId;
  final String paymentMethod;
  final String? couponCode;
  final String? customerNote;

  /// Omitted unless explicitly requested, so an ordinary checkout sends no
  /// trace of the demo affordance.
  final bool? simulateFailure;

  Map<String, dynamic> toJson() => _$PlaceOrderRequestToJson(this);
}

@JsonSerializable(createFactory: false, includeIfNull: false)
class CancelOrderRequest {
  const CancelOrderRequest({this.reason});

  final String? reason;

  Map<String, dynamic> toJson() => _$CancelOrderRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class ReturnRequestBody {
  const ReturnRequestBody({required this.itemIds, required this.reason});

  /// Order-item ids. Sending product ids here earns a 422 naming the unknown
  /// item.
  final List<String> itemIds;

  final String reason;

  Map<String, dynamic> toJson() => _$ReturnRequestBodyToJson(this);
}
