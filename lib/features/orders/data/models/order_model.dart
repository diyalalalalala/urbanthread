import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/media_url.dart';
import '../../domain/entities/order.dart';

part 'order_model.g.dart';

String? _readId(Object? raw) => switch (raw) {
      String value when value.isNotEmpty => value,
      Map<String, dynamic> value => value['_id'] as String?,
      _ => null,
    };

String? _writeId(String? value) => value;

String? _nullIfBlank(String? value) =>
    (value == null || value.isEmpty) ? null : value;

DateTime? _parseDate(String? raw) =>
    (raw == null || raw.isEmpty) ? null : DateTime.tryParse(raw);

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

  final OrderCouponModel? coupon;

  final OrderPaymentModel payment;
  final String status;
  final List<OrderTimelineEntryModel> timeline;

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

  @JsonKey(name: '_id')
  final String id;

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

  final List<String> itemIds;

  final String reason;

  Map<String, dynamic> toJson() => _$ReturnRequestBodyToJson(this);
}
