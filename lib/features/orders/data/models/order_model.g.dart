// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  id: json['_id'] as String,
  orderNumber: json['orderNumber'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  shippingAddress: OrderAddressModel.fromJson(
    json['shippingAddress'] as Map<String, dynamic>,
  ),
  billingAddress: OrderAddressModel.fromJson(
    json['billingAddress'] as Map<String, dynamic>,
  ),
  pricing: OrderPricingModel.fromJson(json['pricing'] as Map<String, dynamic>),
  payment: OrderPaymentModel.fromJson(json['payment'] as Map<String, dynamic>),
  status: json['status'] as String,
  customerEmail: json['customerEmail'] as String? ?? '',
  customerName: json['customerName'] as String? ?? '',
  coupon: json['coupon'] == null
      ? null
      : OrderCouponModel.fromJson(json['coupon'] as Map<String, dynamic>),
  timeline:
      (json['timeline'] as List<dynamic>?)
          ?.map(
            (e) => OrderTimelineEntryModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  returnStatus: json['returnStatus'] as String?,
  customerNote: json['customerNote'] as String? ?? '',
  adminNote: json['adminNote'] as String? ?? '',
  cancellationReason: json['cancellationReason'] as String? ?? '',
  deliveredAt: json['deliveredAt'] as String?,
  cancelledAt: json['cancelledAt'] as String?,
  estimatedDeliveryDate: json['estimatedDeliveryDate'] as String?,
  trackingNumber: json['trackingNumber'] as String? ?? '',
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  totalItems: (json['totalItems'] as num?)?.toInt(),
  isCancellable: json['isCancellable'] as bool?,
  isTerminal: json['isTerminal'] as bool?,
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'orderNumber': instance.orderNumber,
      'customerEmail': instance.customerEmail,
      'customerName': instance.customerName,
      'items': instance.items,
      'shippingAddress': instance.shippingAddress,
      'billingAddress': instance.billingAddress,
      'pricing': instance.pricing,
      'coupon': instance.coupon,
      'payment': instance.payment,
      'status': instance.status,
      'timeline': instance.timeline,
      'returnStatus': instance.returnStatus,
      'customerNote': instance.customerNote,
      'adminNote': instance.adminNote,
      'cancellationReason': instance.cancellationReason,
      'deliveredAt': instance.deliveredAt,
      'cancelledAt': instance.cancelledAt,
      'estimatedDeliveryDate': instance.estimatedDeliveryDate,
      'trackingNumber': instance.trackingNumber,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'totalItems': instance.totalItems,
      'isCancellable': instance.isCancellable,
      'isTerminal': instance.isTerminal,
    };

OrderItemModel _$OrderItemModelFromJson(Map<String, dynamic> json) =>
    OrderItemModel(
      id: json['_id'] as String,
      product: _readId(json['product']),
      variantId: _readId(json['variantId']),
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: _readNum(json['unitPrice']),
      lineTotal: _readNum(json['lineTotal']),
      image: json['image'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      color: json['color'] as String? ?? '',
      size: json['size'] as String? ?? '',
      brandName: json['brandName'] as String? ?? '',
      returnStatus: json['returnStatus'] as String?,
      returnReason: json['returnReason'] as String? ?? '',
      returnRequestedAt: json['returnRequestedAt'] as String?,
      returnResolvedAt: json['returnResolvedAt'] as String?,
      returnAdminNote: json['returnAdminNote'] as String? ?? '',
    );

Map<String, dynamic> _$OrderItemModelToJson(OrderItemModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'product': _writeId(instance.product),
      'variantId': _writeId(instance.variantId),
      'name': instance.name,
      'image': instance.image,
      'sku': instance.sku,
      'color': instance.color,
      'size': instance.size,
      'brandName': instance.brandName,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'lineTotal': instance.lineTotal,
      'returnStatus': instance.returnStatus,
      'returnReason': instance.returnReason,
      'returnRequestedAt': instance.returnRequestedAt,
      'returnResolvedAt': instance.returnResolvedAt,
      'returnAdminNote': instance.returnAdminNote,
    };

OrderAddressModel _$OrderAddressModelFromJson(Map<String, dynamic> json) =>
    OrderAddressModel(
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
      country: json['country'] as String? ?? 'Nepal',
      landmark: json['landmark'] as String? ?? '',
    );

Map<String, dynamic> _$OrderAddressModelToJson(OrderAddressModel instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'phone': instance.phone,
      'street': instance.street,
      'city': instance.city,
      'state': instance.state,
      'postalCode': instance.postalCode,
      'country': instance.country,
      'landmark': instance.landmark,
    };

OrderPricingModel _$OrderPricingModelFromJson(Map<String, dynamic> json) =>
    OrderPricingModel(
      subtotal: _readNum(json['subtotal']),
      grandTotal: _readNum(json['grandTotal']),
      discount: json['discount'] == null ? 0 : _readNum(json['discount']),
      tax: json['tax'] == null ? 0 : _readNum(json['tax']),
      shipping: json['shipping'] == null ? 0 : _readNum(json['shipping']),
      currency: json['currency'] as String? ?? 'NPR',
      taxRate: json['taxRate'] == null ? 0 : _readNum(json['taxRate']),
    );

Map<String, dynamic> _$OrderPricingModelToJson(OrderPricingModel instance) =>
    <String, dynamic>{
      'subtotal': instance.subtotal,
      'discount': instance.discount,
      'tax': instance.tax,
      'shipping': instance.shipping,
      'grandTotal': instance.grandTotal,
      'currency': instance.currency,
      'taxRate': instance.taxRate,
    };

OrderCouponModel _$OrderCouponModelFromJson(Map<String, dynamic> json) =>
    OrderCouponModel(
      code: json['code'] as String?,
      couponId: _readId(json['couponId']),
      discountAmount: json['discountAmount'] == null
          ? 0
          : _readNum(json['discountAmount']),
    );

Map<String, dynamic> _$OrderCouponModelToJson(OrderCouponModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'couponId': _writeId(instance.couponId),
      'discountAmount': instance.discountAmount,
    };

OrderPaymentModel _$OrderPaymentModelFromJson(Map<String, dynamic> json) =>
    OrderPaymentModel(
      method: json['method'] as String,
      status: json['status'] as String? ?? 'pending',
      transactionId: json['transactionId'] as String?,
      paidAt: json['paidAt'] as String?,
      failureReason: json['failureReason'] as String? ?? '',
      refundedAt: json['refundedAt'] as String?,
      refundAmount: json['refundAmount'] == null
          ? 0
          : _readNum(json['refundAmount']),
    );

Map<String, dynamic> _$OrderPaymentModelToJson(OrderPaymentModel instance) =>
    <String, dynamic>{
      'method': instance.method,
      'status': instance.status,
      'transactionId': instance.transactionId,
      'paidAt': instance.paidAt,
      'failureReason': instance.failureReason,
      'refundedAt': instance.refundedAt,
      'refundAmount': instance.refundAmount,
    };

OrderTimelineEntryModel _$OrderTimelineEntryModelFromJson(
  Map<String, dynamic> json,
) => OrderTimelineEntryModel(
  status: json['status'] as String,
  note: json['note'] as String? ?? '',
  changedBy: _readId(json['changedBy']),
  occurredAt: json['occurredAt'] as String?,
);

Map<String, dynamic> _$OrderTimelineEntryModelToJson(
  OrderTimelineEntryModel instance,
) => <String, dynamic>{
  'status': instance.status,
  'note': instance.note,
  'changedBy': _writeId(instance.changedBy),
  'occurredAt': instance.occurredAt,
};

OrderTrackingModel _$OrderTrackingModelFromJson(Map<String, dynamic> json) =>
    OrderTrackingModel(
      orderNumber: json['orderNumber'] as String,
      status: json['status'] as String,
      timeline:
          (json['timeline'] as List<dynamic>?)
              ?.map(
                (e) =>
                    OrderTimelineEntryModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      trackingNumber: json['trackingNumber'] as String? ?? '',
      estimatedDeliveryDate: json['estimatedDeliveryDate'] as String?,
      deliveredAt: json['deliveredAt'] as String?,
      cancelledAt: json['cancelledAt'] as String?,
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
      isCancellable: json['isCancellable'] as bool? ?? false,
      placedAt: json['placedAt'] as String?,
    );

Map<String, dynamic> _$OrderTrackingModelToJson(OrderTrackingModel instance) =>
    <String, dynamic>{
      'orderNumber': instance.orderNumber,
      'status': instance.status,
      'timeline': instance.timeline,
      'trackingNumber': instance.trackingNumber,
      'estimatedDeliveryDate': instance.estimatedDeliveryDate,
      'deliveredAt': instance.deliveredAt,
      'cancelledAt': instance.cancelledAt,
      'totalItems': instance.totalItems,
      'isCancellable': instance.isCancellable,
      'placedAt': instance.placedAt,
    };

Map<String, dynamic> _$PlaceOrderRequestToJson(PlaceOrderRequest instance) =>
    <String, dynamic>{
      'shippingAddressId': instance.shippingAddressId,
      'billingAddressId': ?instance.billingAddressId,
      'paymentMethod': instance.paymentMethod,
      'couponCode': ?instance.couponCode,
      'customerNote': ?instance.customerNote,
      'simulateFailure': ?instance.simulateFailure,
    };

Map<String, dynamic> _$CancelOrderRequestToJson(CancelOrderRequest instance) =>
    <String, dynamic>{'reason': ?instance.reason};

Map<String, dynamic> _$ReturnRequestBodyToJson(ReturnRequestBody instance) =>
    <String, dynamic>{'itemIds': instance.itemIds, 'reason': instance.reason};
