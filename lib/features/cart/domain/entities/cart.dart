import 'package:equatable/equatable.dart';

class CartVariant extends Equatable {
  const CartVariant({
    required this.id,
    required this.size,
    this.colorName = '',
    this.colorHex = '#000000',
    this.sku = '',
    this.stock = 0,
    this.priceOverride,
    this.isActive = true,
  });

  final String id;
  final String size;
  final String colorName;
  final String colorHex;
  final String sku;
  final int stock;

  final double? priceOverride;
  final bool isActive;

  bool get inStock => stock > 0 && isActive;

  @override
  List<Object?> get props => [
        id,
        size,
        colorName,
        colorHex,
        sku,
        stock,
        priceOverride,
        isActive,
      ];
}

class CartProduct extends Equatable {
  const CartProduct({
    required this.id,
    required this.name,
    required this.slug,
    this.imageUrl,
    this.price = 0,
    this.discountPercentage = 0,
    this.effectivePrice = 0,
    this.isActive = true,
    this.variants = const [],
    this.categoryId,
    this.brandId,
  });

  final String id;
  final String name;

  final String slug;

  final String? imageUrl;

  final double price;
  final double discountPercentage;

  final double effectivePrice;

  final bool isActive;
  final List<CartVariant> variants;

  final String? categoryId;
  final String? brandId;

  CartVariant? variantById(String variantId) {
    for (final variant in variants) {
      if (variant.id == variantId) return variant;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        imageUrl,
        price,
        discountPercentage,
        effectivePrice,
        isActive,
        variants,
        categoryId,
        brandId,
      ];
}

class CartItem extends Equatable {
  const CartItem({
    required this.id,
    required this.product,
    required this.variantId,
    required this.quantity,
    required this.unitPrice,
    this.name = '',
    this.imageUrl,
    this.sku = '',
    this.color = '',
    this.size = '',
    this.savedForLater = false,
    this.addedAt,
  });

  final String id;

  final CartProduct product;
  final String variantId;

  final int quantity;

  final double unitPrice;

  final String name;
  final String? imageUrl;
  final String sku;
  final String color;
  final String size;

  final bool savedForLater;

  final DateTime? addedAt;

  double get lineTotal => unitPrice * quantity;

  CartVariant? get variant => product.variantById(variantId);

  int? get maxSelectableQuantity {
    final stock = variant?.stock;
    if (stock == null) return null;
    return stock < maxQuantityPerLine ? stock : maxQuantityPerLine;
  }

  bool get priceChanged =>
      product.effectivePrice > 0 &&
      (product.effectivePrice - unitPrice).abs() > 0.009;

  static const maxQuantityPerLine = 10;

  CartItem copyWith({int? quantity, bool? savedForLater}) => CartItem(
        id: id,
        product: product,
        variantId: variantId,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice,
        name: name,
        imageUrl: imageUrl,
        sku: sku,
        color: color,
        size: size,
        savedForLater: savedForLater ?? this.savedForLater,
        addedAt: addedAt,
      );

  @override
  List<Object?> get props => [
        id,
        product,
        variantId,
        quantity,
        unitPrice,
        name,
        imageUrl,
        sku,
        color,
        size,
        savedForLater,
        addedAt,
      ];
}

class CartCoupon extends Equatable {
  const CartCoupon({this.couponId, this.code, this.discountAmount = 0});

  final String? couponId;
  final String? code;
  final double discountAmount;

  bool get isApplied => (code ?? '').isNotEmpty;

  @override
  List<Object?> get props => [couponId, code, discountAmount];
}

class Cart extends Equatable {
  const Cart({
    required this.id,
    this.items = const [],
    this.coupon = const CartCoupon(),
    this.createdAt,
    this.updatedAt,
  });

  const Cart.empty() : this(id: '');

  final String id;

  final List<CartItem> items;

  final CartCoupon coupon;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  List<CartItem> get activeItems =>
      items.where((item) => !item.savedForLater).toList(growable: false);

  List<CartItem> get savedItems =>
      items.where((item) => item.savedForLater).toList(growable: false);

  bool get isEmpty => items.isEmpty;
  bool get hasActiveItems => activeItems.isNotEmpty;

  int get itemCount =>
      activeItems.fold(0, (sum, item) => sum + item.quantity);

  CartItem? itemById(String itemId) {
    for (final item in items) {
      if (item.id == itemId) return item;
    }
    return null;
  }

  CartItem? lineFor({required String productId, required String variantId}) {
    for (final item in items) {
      if (item.product.id == productId && item.variantId == variantId) {
        return item;
      }
    }
    return null;
  }

  Cart copyWith({List<CartItem>? items, CartCoupon? coupon}) => Cart(
        id: id,
        items: items ?? this.items,
        coupon: coupon ?? this.coupon,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  Cart withItem(CartItem replacement) => copyWith(
        items: [
          for (final item in items)
            if (item.id == replacement.id) replacement else item,
        ],
      );

  Cart withoutItem(String itemId) => copyWith(
        items: items.where((item) => item.id != itemId).toList(growable: false),
      );

  @override
  List<Object?> get props => [id, items, coupon, createdAt, updatedAt];
}
