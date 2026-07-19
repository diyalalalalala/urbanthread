// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartSummaryModel _$CartSummaryModelFromJson(Map<String, dynamic> json) =>
    CartSummaryModel(
      subtotal: _readNum(json['subtotal']),
      grandTotal: _readNum(json['grandTotal']),
      discount: json['discount'] == null ? 0 : _readNum(json['discount']),
      tax: json['tax'] == null ? 0 : _readNum(json['tax']),
      shipping: json['shipping'] == null ? 0 : _readNum(json['shipping']),
      currency: json['currency'] as String? ?? 'NPR',
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
      savedForLaterCount: (json['savedForLaterCount'] as num?)?.toInt() ?? 0,
      freeShippingEligible: json['freeShippingEligible'] as bool? ?? false,
      amountToFreeShipping: json['amountToFreeShipping'] == null
          ? 0
          : _readNum(json['amountToFreeShipping']),
      coupon: json['coupon'] == null
          ? null
          : AppliedCouponModel.fromJson(json['coupon'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CartSummaryModelToJson(CartSummaryModel instance) =>
    <String, dynamic>{
      'subtotal': instance.subtotal,
      'discount': instance.discount,
      'tax': instance.tax,
      'shipping': instance.shipping,
      'grandTotal': instance.grandTotal,
      'currency': instance.currency,
      'itemCount': instance.itemCount,
      'savedForLaterCount': instance.savedForLaterCount,
      'freeShippingEligible': instance.freeShippingEligible,
      'amountToFreeShipping': instance.amountToFreeShipping,
      'coupon': instance.coupon,
    };

AppliedCouponModel _$AppliedCouponModelFromJson(Map<String, dynamic> json) =>
    AppliedCouponModel(
      code: json['code'] as String,
      discountAmount: json['discountAmount'] == null
          ? 0
          : _readNum(json['discountAmount']),
      valid: json['valid'] as bool? ?? true,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$AppliedCouponModelToJson(AppliedCouponModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'discountAmount': instance.discountAmount,
      'valid': instance.valid,
      'message': instance.message,
    };

CartItemModel _$CartItemModelFromJson(Map<String, dynamic> json) =>
    CartItemModel(
      id: json['_id'] as String,
      snapshot: CartItemSnapshotModel.fromJson(
        json['snapshot'] as Map<String, dynamic>,
      ),
      product: _readId(json['product']),
      variantId: _readId(json['variantId']),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      savedForLater: json['savedForLater'] as bool? ?? false,
    );

Map<String, dynamic> _$CartItemModelToJson(CartItemModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'product': _writeId(instance.product),
      'variantId': _writeId(instance.variantId),
      'quantity': instance.quantity,
      'snapshot': instance.snapshot,
      'savedForLater': instance.savedForLater,
    };

CartItemSnapshotModel _$CartItemSnapshotModelFromJson(
  Map<String, dynamic> json,
) => CartItemSnapshotModel(
  name: json['name'] as String,
  unitPrice: _readNum(json['unitPrice']),
  image: json['image'] as String? ?? '',
  sku: json['sku'] as String? ?? '',
  color: json['color'] as String? ?? '',
  size: json['size'] as String? ?? '',
);

Map<String, dynamic> _$CartItemSnapshotModelToJson(
  CartItemSnapshotModel instance,
) => <String, dynamic>{
  'name': instance.name,
  'image': instance.image,
  'sku': instance.sku,
  'color': instance.color,
  'size': instance.size,
  'unitPrice': instance.unitPrice,
};

CartModel _$CartModelFromJson(Map<String, dynamic> json) => CartModel(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$CartModelToJson(CartModel instance) => <String, dynamic>{
  'items': instance.items,
};

CartValidationModel _$CartValidationModelFromJson(
  Map<String, dynamic> json,
) => CartValidationModel(
  cart: CartModel.fromJson(json['cart'] as Map<String, dynamic>),
  summary: CartSummaryModel.fromJson(json['summary'] as Map<String, dynamic>),
  coupon: json['coupon'] == null
      ? null
      : ValidatedCouponModel.fromJson(json['coupon'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CartValidationModelToJson(
  CartValidationModel instance,
) => <String, dynamic>{
  'cart': instance.cart,
  'summary': instance.summary,
  'coupon': instance.coupon,
};

ValidatedCouponModel _$ValidatedCouponModelFromJson(
  Map<String, dynamic> json,
) => ValidatedCouponModel(
  code: json['code'] as String,
  couponId: _readId(json['couponId']),
  discountAmount: json['discountAmount'] == null
      ? 0
      : _readNum(json['discountAmount']),
);

Map<String, dynamic> _$ValidatedCouponModelToJson(
  ValidatedCouponModel instance,
) => <String, dynamic>{
  'code': instance.code,
  'couponId': _writeId(instance.couponId),
  'discountAmount': instance.discountAmount,
};

AvailableCouponModel _$AvailableCouponModelFromJson(
  Map<String, dynamic> json,
) => AvailableCouponModel(
  id: json['_id'] as String,
  code: json['code'] as String,
  type: json['type'] as String,
  value: _readNum(json['value']),
  description: json['description'] as String? ?? '',
  maxDiscountAmount: _readNullableNum(json['maxDiscountAmount']),
  minPurchaseAmount: json['minPurchaseAmount'] == null
      ? 0
      : _readNum(json['minPurchaseAmount']),
  expiresAt: json['expiresAt'] as String?,
  applicableCategories: json['applicableCategories'] == null
      ? const []
      : _readIdList(json['applicableCategories']),
  applicableBrands: json['applicableBrands'] == null
      ? const []
      : _readIdList(json['applicableBrands']),
  isApplicable: json['isApplicable'] as bool? ?? false,
  estimatedDiscount: json['estimatedDiscount'] == null
      ? 0
      : _readNum(json['estimatedDiscount']),
  amountToQualify: json['amountToQualify'] == null
      ? 0
      : _readNum(json['amountToQualify']),
);

Map<String, dynamic> _$AvailableCouponModelToJson(
  AvailableCouponModel instance,
) => <String, dynamic>{
  '_id': instance.id,
  'code': instance.code,
  'description': instance.description,
  'type': instance.type,
  'value': instance.value,
  'maxDiscountAmount': _writeNullableNum(instance.maxDiscountAmount),
  'minPurchaseAmount': instance.minPurchaseAmount,
  'expiresAt': instance.expiresAt,
  'applicableCategories': _writeIdList(instance.applicableCategories),
  'applicableBrands': _writeIdList(instance.applicableBrands),
  'isApplicable': instance.isApplicable,
  'estimatedDiscount': instance.estimatedDiscount,
  'amountToQualify': instance.amountToQualify,
};

CouponPreviewModel _$CouponPreviewModelFromJson(Map<String, dynamic> json) =>
    CouponPreviewModel(
      code: json['code'] as String,
      type: json['type'] as String,
      value: _readNum(json['value']),
      description: json['description'] as String? ?? '',
      estimatedDiscount: json['estimatedDiscount'] == null
          ? 0
          : _readNum(json['estimatedDiscount']),
    );

Map<String, dynamic> _$CouponPreviewModelToJson(CouponPreviewModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'description': instance.description,
      'type': instance.type,
      'value': instance.value,
      'estimatedDiscount': instance.estimatedDiscount,
    };

Map<String, dynamic> _$ValidateCouponRequestToJson(
  ValidateCouponRequest instance,
) => <String, dynamic>{'code': instance.code, 'subtotal': ?instance.subtotal};

Map<String, dynamic> _$AddressRequestToJson(AddressRequest instance) =>
    <String, dynamic>{
      'label': ?instance.label,
      'type': ?instance.type,
      'fullName': ?instance.fullName,
      'phone': ?instance.phone,
      'street': ?instance.street,
      'city': ?instance.city,
      'state': ?instance.state,
      'postalCode': ?instance.postalCode,
      'country': ?instance.country,
      'landmark': ?instance.landmark,
      'isDefault': ?instance.isDefault,
    };
