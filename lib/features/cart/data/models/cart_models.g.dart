// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartSnapshotModel _$CartSnapshotModelFromJson(Map<String, dynamic> json) =>
    CartSnapshotModel(
      cart: CartModel.fromJson(json['cart'] as Map<String, dynamic>),
      notices:
          (json['notices'] as List<dynamic>?)
              ?.map((e) => CartNoticeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      summary: json['summary'] == null
          ? const CartSummaryModel()
          : CartSummaryModel.fromJson(json['summary'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CartSnapshotModelToJson(CartSnapshotModel instance) =>
    <String, dynamic>{
      'cart': instance.cart,
      'notices': instance.notices,
      'summary': instance.summary,
    };

CartModel _$CartModelFromJson(Map<String, dynamic> json) => CartModel(
  id: json['_id'] as String,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  coupon: json['coupon'] == null
      ? null
      : CartCouponModel.fromJson(json['coupon'] as Map<String, dynamic>),
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$CartModelToJson(CartModel instance) => <String, dynamic>{
  '_id': instance.id,
  'items': instance.items,
  'coupon': instance.coupon,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

CartCouponModel _$CartCouponModelFromJson(Map<String, dynamic> json) =>
    CartCouponModel(
      couponId: _objectId(json['couponId']),
      code: json['code'] as String?,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$CartCouponModelToJson(CartCouponModel instance) =>
    <String, dynamic>{
      'couponId': instance.couponId,
      'code': instance.code,
      'discountAmount': instance.discountAmount,
    };

CartItemModel _$CartItemModelFromJson(Map<String, dynamic> json) =>
    CartItemModel(
      id: json['_id'] as String,
      variantId: _objectId(json['variantId']),
      quantity: (json['quantity'] as num).toInt(),
      product: _productFromJson(json['product']),
      snapshot: json['snapshot'] == null
          ? const CartItemSnapshotModel()
          : CartItemSnapshotModel.fromJson(
              json['snapshot'] as Map<String, dynamic>,
            ),
      savedForLater: json['savedForLater'] as bool? ?? false,
      addedAt: json['addedAt'] as String?,
    );

Map<String, dynamic> _$CartItemModelToJson(CartItemModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'product': instance.product,
      'variantId': instance.variantId,
      'quantity': instance.quantity,
      'snapshot': instance.snapshot,
      'savedForLater': instance.savedForLater,
      'addedAt': instance.addedAt,
    };

CartItemSnapshotModel _$CartItemSnapshotModelFromJson(
  Map<String, dynamic> json,
) => CartItemSnapshotModel(
  name: json['name'] as String? ?? '',
  image: json['image'] as String? ?? '',
  sku: json['sku'] as String? ?? '',
  color: json['color'] as String? ?? '',
  size: json['size'] as String? ?? '',
  unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
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

CartProductModel _$CartProductModelFromJson(
  Map<String, dynamic> json,
) => CartProductModel(
  id: json['_id'] as String,
  name: json['name'] as String,
  slug: json['slug'] as String? ?? '',
  images:
      (json['images'] as List<dynamic>?)
          ?.map((e) => ProductImageModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  price: (json['price'] as num?)?.toDouble() ?? 0,
  discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0,
  effectivePrice: (json['effectivePrice'] as num?)?.toDouble() ?? 0,
  isActive: json['isActive'] as bool? ?? true,
  variants:
      (json['variants'] as List<dynamic>?)
          ?.map((e) => ProductVariantModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  category: _objectId(json['category']),
  brand: _objectId(json['brand']),
);

Map<String, dynamic> _$CartProductModelToJson(CartProductModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'images': instance.images,
      'price': instance.price,
      'discountPercentage': instance.discountPercentage,
      'effectivePrice': instance.effectivePrice,
      'isActive': instance.isActive,
      'variants': instance.variants,
      'category': instance.category,
      'brand': instance.brand,
    };

ProductImageModel _$ProductImageModelFromJson(Map<String, dynamic> json) =>
    ProductImageModel(
      url: json['url'] as String? ?? '',
      publicId: json['publicId'] as String? ?? '',
      alt: json['alt'] as String? ?? '',
      isPrimary: json['isPrimary'] as bool? ?? false,
    );

Map<String, dynamic> _$ProductImageModelToJson(ProductImageModel instance) =>
    <String, dynamic>{
      'url': instance.url,
      'publicId': instance.publicId,
      'alt': instance.alt,
      'isPrimary': instance.isPrimary,
    };

ProductVariantModel _$ProductVariantModelFromJson(Map<String, dynamic> json) =>
    ProductVariantModel(
      id: json['_id'] as String,
      size: json['size'] as String? ?? '',
      color: json['color'] == null
          ? null
          : VariantColorModel.fromJson(json['color'] as Map<String, dynamic>),
      sku: json['sku'] as String? ?? '',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      priceOverride: (json['priceOverride'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$ProductVariantModelToJson(
  ProductVariantModel instance,
) => <String, dynamic>{
  '_id': instance.id,
  'size': instance.size,
  'color': instance.color,
  'sku': instance.sku,
  'stock': instance.stock,
  'priceOverride': instance.priceOverride,
  'isActive': instance.isActive,
};

VariantColorModel _$VariantColorModelFromJson(Map<String, dynamic> json) =>
    VariantColorModel(
      name: json['name'] as String? ?? '',
      hex: json['hex'] as String? ?? '#000000',
    );

Map<String, dynamic> _$VariantColorModelToJson(VariantColorModel instance) =>
    <String, dynamic>{'name': instance.name, 'hex': instance.hex};

CartNoticeModel _$CartNoticeModelFromJson(Map<String, dynamic> json) =>
    CartNoticeModel(
      type: json['type'] as String,
      message: json['message'] as String,
      itemId: _objectId(json['itemId']),
    );

Map<String, dynamic> _$CartNoticeModelToJson(CartNoticeModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'message': instance.message,
      'itemId': instance.itemId,
    };

CartSummaryModel _$CartSummaryModelFromJson(
  Map<String, dynamic> json,
) => CartSummaryModel(
  subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
  discount: (json['discount'] as num?)?.toDouble() ?? 0,
  tax: (json['tax'] as num?)?.toDouble() ?? 0,
  shipping: (json['shipping'] as num?)?.toDouble() ?? 0,
  grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0,
  currency: json['currency'] as String? ?? 'NPR',
  itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
  savedForLaterCount: (json['savedForLaterCount'] as num?)?.toInt() ?? 0,
  freeShippingEligible: json['freeShippingEligible'] as bool? ?? false,
  amountToFreeShipping: (json['amountToFreeShipping'] as num?)?.toDouble() ?? 0,
  coupon: json['coupon'] == null
      ? null
      : CartSummaryCouponModel.fromJson(json['coupon'] as Map<String, dynamic>),
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

CartSummaryCouponModel _$CartSummaryCouponModelFromJson(
  Map<String, dynamic> json,
) => CartSummaryCouponModel(
  code: json['code'] as String,
  discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
  valid: json['valid'] as bool? ?? true,
  message: json['message'] as String?,
);

Map<String, dynamic> _$CartSummaryCouponModelToJson(
  CartSummaryCouponModel instance,
) => <String, dynamic>{
  'code': instance.code,
  'discountAmount': instance.discountAmount,
  'valid': instance.valid,
  'message': instance.message,
};

CartValidationModel _$CartValidationModelFromJson(Map<String, dynamic> json) =>
    CartValidationModel(
      summary: json['summary'] == null
          ? const CartSummaryModel()
          : CartSummaryModel.fromJson(json['summary'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AddCartItemRequestToJson(AddCartItemRequest instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'variantId': instance.variantId,
      'quantity': ?instance.quantity,
    };

Map<String, dynamic> _$UpdateCartItemRequestToJson(
  UpdateCartItemRequest instance,
) => <String, dynamic>{'quantity': instance.quantity};

Map<String, dynamic> _$ApplyCouponRequestToJson(ApplyCouponRequest instance) =>
    <String, dynamic>{'code': instance.code};
