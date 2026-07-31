import 'package:equatable/equatable.dart';

class WishlistVariant extends Equatable {
  const WishlistVariant({
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
  List<Object?> get props =>
      [id, size, colorName, colorHex, sku, stock, priceOverride, isActive];
}

class WishlistReference extends Equatable {
  const WishlistReference({
    required this.id,
    required this.name,
    this.slug = '',
  });

  final String id;
  final String name;
  final String slug;

  @override
  List<Object?> get props => [id, name, slug];
}

class WishlistProduct extends Equatable {
  const WishlistProduct({
    required this.id,
    required this.name,
    this.slug = '',
    this.imageUrl,
    this.price = 0,
    this.discountPercentage = 0,
    this.effectivePrice = 0,
    this.ratingAverage = 0,
    this.ratingCount = 0,
    this.totalStock = 0,
    this.variants = const [],
    this.isActive = true,
    this.brand,
    this.category,
  });

  final String id;
  final String name;

  final String slug;

  final String? imageUrl;
  final double price;
  final double discountPercentage;

  final double effectivePrice;

  final double ratingAverage;
  final int ratingCount;

  final int totalStock;

  final List<WishlistVariant> variants;
  final bool isActive;
  final WishlistReference? brand;
  final WishlistReference? category;

  bool get inStock => totalStock > 0;

  WishlistVariant? get firstAvailableVariant {
    for (final variant in variants) {
      if (variant.inStock) return variant;
    }
    return variants.isEmpty ? null : variants.first;
  }

  WishlistVariant? variantById(String? variantId) {
    if (variantId == null) return null;
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
        ratingAverage,
        ratingCount,
        totalStock,
        variants,
        isActive,
        brand,
        category,
      ];
}

class WishlistItem extends Equatable {
  const WishlistItem({
    required this.id,
    required this.product,
    this.variantId,
    this.priceWhenAdded = 0,
    this.addedAt,
  });

  final String id;

  final WishlistProduct product;

  final String? variantId;

  final double priceWhenAdded;

  final DateTime? addedAt;

  WishlistVariant? get variantForCart =>
      product.variantById(variantId) ?? product.firstAvailableVariant;

  bool get priceDropped =>
      priceWhenAdded > 0 &&
      product.effectivePrice > 0 &&
      product.effectivePrice < priceWhenAdded - 0.009;

  double get priceDropAmount =>
      priceDropped ? priceWhenAdded - product.effectivePrice : 0;

  @override
  List<Object?> get props => [id, product, variantId, priceWhenAdded, addedAt];
}

class Wishlist extends Equatable {
  const Wishlist({required this.id, this.items = const [], int? itemCount})
      : _itemCount = itemCount;

  const Wishlist.empty() : this(id: '');

  final String id;
  final List<WishlistItem> items;
  final int? _itemCount;

  int get itemCount => _itemCount ?? items.length;

  bool get isEmpty => items.isEmpty;

  bool contains(String productId) =>
      items.any((item) => item.product.id == productId);

  WishlistItem? itemForProduct(String productId) {
    for (final item in items) {
      if (item.product.id == productId) return item;
    }
    return null;
  }

  Wishlist without(String productId) => Wishlist(
        id: id,
        items: items
            .where((item) => item.product.id != productId)
            .toList(growable: false),
      );

  Wishlist withItem(WishlistItem item) => Wishlist(
        id: id,
        items: [item, ...items.where((it) => it.product.id != item.product.id)],
      );

  @override
  List<Object?> get props => [id, items, itemCount];
}
