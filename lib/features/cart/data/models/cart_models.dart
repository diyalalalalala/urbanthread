import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/media_url.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_notice.dart';
import '../../domain/entities/cart_snapshot.dart';
import '../../domain/entities/cart_summary.dart';

part 'cart_models.g.dart';

@JsonSerializable()
class CartSnapshotModel {
  const CartSnapshotModel({
    required this.cart,
    this.notices = const [],
    this.summary = const CartSummaryModel(),
  });

  factory CartSnapshotModel.fromJson(Map<String, dynamic> json) =>
      _$CartSnapshotModelFromJson(json);

  final CartModel cart;
  final List<CartNoticeModel> notices;
  final CartSummaryModel summary;

  Map<String, dynamic> toJson() => _$CartSnapshotModelToJson(this);

  CartSnapshotModel copyWith({
    CartModel? cart,
    List<CartNoticeModel>? notices,
    CartSummaryModel? summary,
  }) =>
      CartSnapshotModel(
        cart: cart ?? this.cart,
        notices: notices ?? this.notices,
        summary: summary ?? this.summary,
      );

  CartSnapshot toEntity() => CartSnapshot(
        cart: cart.toEntity(),
        notices: notices.map((notice) => notice.toEntity()).toList(
              growable: false,
            ),
        summary: summary.toEntity(),
      );
}

@JsonSerializable()
class CartModel {
  const CartModel({
    required this.id,
    this.items = const [],
    this.coupon,
    this.createdAt,
    this.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) =>
      _$CartModelFromJson(json);

  @JsonKey(name: '_id')
  final String id;

  final List<CartItemModel> items;

  final CartCouponModel? coupon;
  final String? createdAt;
  final String? updatedAt;

  Map<String, dynamic> toJson() => _$CartModelToJson(this);

  CartModel copyWith({
    List<CartItemModel>? items,
    CartCouponModel? coupon,
    bool clearCoupon = false,
  }) =>
      CartModel(
        id: id,
        items: items ?? this.items,
        coupon: clearCoupon ? null : (coupon ?? this.coupon),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  Cart toEntity() => Cart(
        id: id,
        items: items
            .where((item) => item.product != null)
            .map((item) => item.toEntity())
            .toList(growable: false),
        coupon: coupon?.toEntity() ?? const CartCoupon(),
        createdAt: _parseDate(createdAt),
        updatedAt: _parseDate(updatedAt),
      );
}

@JsonSerializable()
class CartCouponModel {
  const CartCouponModel({this.couponId, this.code, this.discountAmount = 0});

  factory CartCouponModel.fromJson(Map<String, dynamic> json) =>
      _$CartCouponModelFromJson(json);

  @JsonKey(fromJson: _objectId)
  final String? couponId;

  final String? code;
  final double discountAmount;

  Map<String, dynamic> toJson() => _$CartCouponModelToJson(this);

  CartCoupon toEntity() => CartCoupon(
        couponId: couponId,
        code: (code ?? '').isEmpty ? null : code,
        discountAmount: discountAmount,
      );
}

@JsonSerializable()
class CartItemModel {
  const CartItemModel({
    required this.id,
    required this.variantId,
    required this.quantity,
    this.product,
    this.snapshot = const CartItemSnapshotModel(),
    this.savedForLater = false,
    this.addedAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);

  @JsonKey(name: '_id')
  final String id;

  @JsonKey(fromJson: _productFromJson)
  final CartProductModel? product;

  @JsonKey(fromJson: _objectId)
  final String? variantId;

  final int quantity;

  final CartItemSnapshotModel snapshot;

  final bool savedForLater;
  final String? addedAt;

  Map<String, dynamic> toJson() => _$CartItemModelToJson(this);

  CartItemModel copyWith({int? quantity, bool? savedForLater}) => CartItemModel(
        id: id,
        product: product,
        variantId: variantId,
        quantity: quantity ?? this.quantity,
        snapshot: snapshot,
        savedForLater: savedForLater ?? this.savedForLater,
        addedAt: addedAt,
      );

  CartItem toEntity() => CartItem(
        id: id,
        product: product!.toEntity(),
        variantId: variantId ?? '',
        quantity: quantity,
        unitPrice: snapshot.unitPrice,
        name: snapshot.name.isEmpty ? product!.name : snapshot.name,
        imageUrl: MediaUrl.firstOf([
          snapshot.image,
          product!.primaryImageUrl,
        ]),
        sku: snapshot.sku,
        color: snapshot.color,
        size: snapshot.size,
        savedForLater: savedForLater,
        addedAt: _parseDate(addedAt),
      );
}

@JsonSerializable()
class CartItemSnapshotModel {
  const CartItemSnapshotModel({
    this.name = '',
    this.image = '',
    this.sku = '',
    this.color = '',
    this.size = '',
    this.unitPrice = 0,
  });

  factory CartItemSnapshotModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemSnapshotModelFromJson(json);

  final String name;
  final String image;
  final String sku;
  final String color;
  final String size;

  final double unitPrice;

  Map<String, dynamic> toJson() => _$CartItemSnapshotModelToJson(this);
}

@JsonSerializable()
class CartProductModel {
  const CartProductModel({
    required this.id,
    required this.name,
    this.slug = '',
    this.images = const [],
    this.price = 0,
    this.discountPercentage = 0,
    this.effectivePrice = 0,
    this.isActive = true,
    this.variants = const [],
    this.category,
    this.brand,
  });

  factory CartProductModel.fromJson(Map<String, dynamic> json) =>
      _$CartProductModelFromJson(json);

  @JsonKey(name: '_id')
  final String id;
  final String name;
  final String slug;
  final List<ProductImageModel> images;
  final double price;
  final double discountPercentage;
  final double effectivePrice;
  final bool isActive;
  final List<ProductVariantModel> variants;

  @JsonKey(fromJson: _objectId)
  final String? category;

  @JsonKey(fromJson: _objectId)
  final String? brand;

  Map<String, dynamic> toJson() => _$CartProductModelToJson(this);

  String? get primaryImageUrl {
    if (images.isEmpty) return null;
    for (final image in images) {
      if (image.isPrimary && image.url.isNotEmpty) return image.url;
    }
    return images.first.url;
  }

  CartProduct toEntity() => CartProduct(
        id: id,
        name: name,
        slug: slug,
        imageUrl: MediaUrl.resolve(primaryImageUrl),
        price: price,
        discountPercentage: discountPercentage,
        effectivePrice: effectivePrice > 0 ? effectivePrice : price,
        isActive: isActive,
        variants: variants
            .map((variant) => variant.toEntity())
            .toList(growable: false),
        categoryId: category,
        brandId: brand,
      );
}

@JsonSerializable()
class ProductImageModel {
  const ProductImageModel({
    this.url = '',
    this.publicId = '',
    this.alt = '',
    this.isPrimary = false,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) =>
      _$ProductImageModelFromJson(json);

  final String url;
  final String publicId;
  final String alt;
  final bool isPrimary;

  Map<String, dynamic> toJson() => _$ProductImageModelToJson(this);
}

@JsonSerializable()
class ProductVariantModel {
  const ProductVariantModel({
    required this.id,
    this.size = '',
    this.color,
    this.sku = '',
    this.stock = 0,
    this.priceOverride,
    this.isActive = true,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) =>
      _$ProductVariantModelFromJson(json);

  @JsonKey(name: '_id')
  final String id;
  final String size;
  final VariantColorModel? color;
  final String sku;
  final int stock;

  final double? priceOverride;
  final bool isActive;

  Map<String, dynamic> toJson() => _$ProductVariantModelToJson(this);

  CartVariant toEntity() => CartVariant(
        id: id,
        size: size,
        colorName: color?.name ?? '',
        colorHex: color?.hex ?? '#000000',
        sku: sku,
        stock: stock,
        priceOverride: priceOverride,
        isActive: isActive,
      );
}

@JsonSerializable()
class VariantColorModel {
  const VariantColorModel({this.name = '', this.hex = '#000000'});

  factory VariantColorModel.fromJson(Map<String, dynamic> json) =>
      _$VariantColorModelFromJson(json);

  final String name;
  final String hex;

  Map<String, dynamic> toJson() => _$VariantColorModelToJson(this);
}

@JsonSerializable()
class CartNoticeModel {
  const CartNoticeModel({
    required this.type,
    required this.message,
    this.itemId,
  });

  factory CartNoticeModel.fromJson(Map<String, dynamic> json) =>
      _$CartNoticeModelFromJson(json);

  final String type;
  final String message;

  @JsonKey(fromJson: _objectId)
  final String? itemId;

  Map<String, dynamic> toJson() => _$CartNoticeModelToJson(this);

  CartNotice toEntity() => CartNotice(
        type: CartNoticeType.parse(type),
        message: message,
        itemId: itemId,
      );
}

@JsonSerializable()
class CartSummaryModel {
  const CartSummaryModel({
    this.subtotal = 0,
    this.discount = 0,
    this.tax = 0,
    this.shipping = 0,
    this.grandTotal = 0,
    this.currency = 'NPR',
    this.itemCount = 0,
    this.savedForLaterCount = 0,
    this.freeShippingEligible = false,
    this.amountToFreeShipping = 0,
    this.coupon,
  });

  factory CartSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$CartSummaryModelFromJson(json);

  factory CartSummaryModel.fromEntity(CartSummary summary) =>
      CartSummaryModel(
        subtotal: summary.subtotal,
        discount: summary.discount,
        tax: summary.tax,
        shipping: summary.shipping,
        grandTotal: summary.grandTotal,
        currency: summary.currency,
        itemCount: summary.itemCount,
        savedForLaterCount: summary.savedForLaterCount,
        freeShippingEligible: summary.freeShippingEligible,
        amountToFreeShipping: summary.amountToFreeShipping,
        coupon: summary.coupon == null
            ? null
            : CartSummaryCouponModel(
                code: summary.coupon!.code,
                discountAmount: summary.coupon!.discountAmount,
                valid: summary.coupon!.valid,
                message: summary.coupon!.message,
              ),
      );

  final double subtotal;
  final double discount;
  final double tax;
  final double shipping;

  final double grandTotal;

  final String currency;
  final int itemCount;
  final int savedForLaterCount;
  final bool freeShippingEligible;
  final double amountToFreeShipping;
  final CartSummaryCouponModel? coupon;

  Map<String, dynamic> toJson() => _$CartSummaryModelToJson(this);

  CartSummary toEntity() => CartSummary(
        subtotal: subtotal,
        discount: discount,
        tax: tax,
        shipping: shipping,
        grandTotal: grandTotal,
        currency: currency,
        itemCount: itemCount,
        savedForLaterCount: savedForLaterCount,
        freeShippingEligible: freeShippingEligible,
        amountToFreeShipping: amountToFreeShipping,
        coupon: coupon?.toEntity(),
      );
}

@JsonSerializable()
class CartSummaryCouponModel {
  const CartSummaryCouponModel({
    required this.code,
    this.discountAmount = 0,
    this.valid = true,
    this.message,
  });

  factory CartSummaryCouponModel.fromJson(Map<String, dynamic> json) =>
      _$CartSummaryCouponModelFromJson(json);

  final String code;
  final double discountAmount;
  final bool valid;
  final String? message;

  Map<String, dynamic> toJson() => _$CartSummaryCouponModelToJson(this);

  CartSummaryCoupon toEntity() => CartSummaryCoupon(
        code: code,
        discountAmount: discountAmount,
        valid: valid,
        message: (message ?? '').isEmpty ? null : message,
      );
}

@JsonSerializable(createToJson: false)
class CartValidationModel {
  const CartValidationModel({this.summary = const CartSummaryModel()});

  factory CartValidationModel.fromJson(Map<String, dynamic> json) =>
      _$CartValidationModelFromJson(json);

  final CartSummaryModel summary;
}

@JsonSerializable(createFactory: false, includeIfNull: false)
class AddCartItemRequest {
  const AddCartItemRequest({
    required this.productId,
    required this.variantId,
    this.quantity,
  });

  final String productId;
  final String variantId;

  final int? quantity;

  Map<String, dynamic> toJson() => _$AddCartItemRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class UpdateCartItemRequest {
  const UpdateCartItemRequest({required this.quantity});

  final int quantity;

  Map<String, dynamic> toJson() => _$UpdateCartItemRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class ApplyCouponRequest {
  const ApplyCouponRequest({required this.code});

  final String code;

  Map<String, dynamic> toJson() => _$ApplyCouponRequestToJson(this);
}

String? _objectId(Object? raw) {
  if (raw is String) return raw.isEmpty ? null : raw;
  if (raw is Map) {
    final id = raw['_id'] ?? raw['id'];
    return id is String && id.isNotEmpty ? id : null;
  }
  return null;
}

CartProductModel? _productFromJson(Object? raw) =>
    raw is Map<String, dynamic> ? CartProductModel.fromJson(raw) : null;

DateTime? _parseDate(String? raw) =>
    (raw == null || raw.isEmpty) ? null : DateTime.tryParse(raw);
