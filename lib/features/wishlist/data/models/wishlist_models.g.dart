// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WishlistModel _$WishlistModelFromJson(Map<String, dynamic> json) =>
    WishlistModel(
      id: json['_id'] as String,
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) => WishlistItemModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      itemCount: (json['itemCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WishlistModelToJson(WishlistModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'items': instance.items,
      'itemCount': instance.itemCount,
    };

WishlistItemModel _$WishlistItemModelFromJson(Map<String, dynamic> json) =>
    WishlistItemModel(
      id: json['_id'] as String,
      product: _productFromJson(json['product']),
      variantId: _objectId(json['variantId']),
      priceWhenAdded: (json['priceWhenAdded'] as num?)?.toDouble() ?? 0,
      addedAt: json['addedAt'] as String?,
    );

Map<String, dynamic> _$WishlistItemModelToJson(WishlistItemModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'product': instance.product,
      'variantId': instance.variantId,
      'priceWhenAdded': instance.priceWhenAdded,
      'addedAt': instance.addedAt,
    };

WishlistProductModel _$WishlistProductModelFromJson(
  Map<String, dynamic> json,
) => WishlistProductModel(
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
  rating: json['rating'] == null
      ? null
      : ProductRatingModel.fromJson(json['rating'] as Map<String, dynamic>),
  totalStock: (json['totalStock'] as num?)?.toInt() ?? 0,
  variants:
      (json['variants'] as List<dynamic>?)
          ?.map((e) => ProductVariantModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  isActive: json['isActive'] as bool? ?? true,
  brand: _referenceFromJson(json['brand']),
  category: _referenceFromJson(json['category']),
);

Map<String, dynamic> _$WishlistProductModelToJson(
  WishlistProductModel instance,
) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'slug': instance.slug,
  'images': instance.images,
  'price': instance.price,
  'discountPercentage': instance.discountPercentage,
  'effectivePrice': instance.effectivePrice,
  'rating': instance.rating,
  'totalStock': instance.totalStock,
  'variants': instance.variants,
  'isActive': instance.isActive,
  'brand': instance.brand,
  'category': instance.category,
};

ProductRatingModel _$ProductRatingModelFromJson(Map<String, dynamic> json) =>
    ProductRatingModel(
      average: (json['average'] as num?)?.toDouble() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ProductRatingModelToJson(ProductRatingModel instance) =>
    <String, dynamic>{'average': instance.average, 'count': instance.count};

ReferenceModel _$ReferenceModelFromJson(Map<String, dynamic> json) =>
    ReferenceModel(
      id: json['_id'] as String,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );

Map<String, dynamic> _$ReferenceModelToJson(ReferenceModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
    };

WishlistMoveResultModel _$WishlistMoveResultModelFromJson(
  Map<String, dynamic> json,
) => WishlistMoveResultModel(
  cart: CartSnapshotModel.fromJson(json['cart'] as Map<String, dynamic>),
  wishlist: WishlistModel.fromJson(json['wishlist'] as Map<String, dynamic>),
);

WishlistCheckModel _$WishlistCheckModelFromJson(Map<String, dynamic> json) =>
    WishlistCheckModel(
      productId: json['productId'] as String,
      inWishlist: json['inWishlist'] as bool? ?? false,
    );

Map<String, dynamic> _$AddWishlistItemRequestToJson(
  AddWishlistItemRequest instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'variantId': ?instance.variantId,
};

Map<String, dynamic> _$WishlistMoveToCartRequestToJson(
  WishlistMoveToCartRequest instance,
) => <String, dynamic>{'variantId': ?instance.variantId};
