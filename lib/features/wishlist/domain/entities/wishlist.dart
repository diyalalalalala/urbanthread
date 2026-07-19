import 'package:equatable/equatable.dart';

/// A purchasable colour/size combination of a saved product.
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

/// A populated reference — `{_id, name, slug}`.
///
/// Worth noting the contrast with the cart, where `brand` and `category` come
/// back as bare ObjectId strings. The wishlist populates them, so its cards
/// can show a brand name without a second request.
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

/// The product behind a saved item.
///
/// The wishlist's own projection, not the catalogue entity: `/wishlist`
/// selects a fixed card-shaped subset and populates brand and category, so
/// this is self-contained and needs nothing from the products feature.
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

  /// Product detail is slug-only — there is no `GET /products/:id` — so this
  /// is what a tap on the card routes with.
  final String slug;

  final String? imageUrl;
  final double price;
  final double discountPercentage;

  /// Post-discount price, and the figure to compare against
  /// [WishlistItem.priceWhenAdded].
  final double effectivePrice;

  /// `rating` is nested on the API (`rating.average` / `rating.count`),
  /// flattened here.
  final double ratingAverage;
  final int ratingCount;

  /// Denormalised sum of variant stock.
  final int totalStock;

  final List<WishlistVariant> variants;
  final bool isActive;
  final WishlistReference? brand;
  final WishlistReference? category;

  bool get inStock => totalStock > 0;

  /// The first variant that can actually be bought, so "move to cart" has
  /// something to send when the item was saved without one.
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

/// One saved product.
class WishlistItem extends Equatable {
  const WishlistItem({
    required this.id,
    required this.product,
    this.variantId,
    this.priceWhenAdded = 0,
    this.addedAt,
  });

  /// The wishlist line id. Note it is *not* what the mutation routes take —
  /// `DELETE /wishlist/{productId}` and `/wishlist/{productId}/move-to-cart`
  /// both key off the product id.
  final String id;

  /// Always populated and non-null: the server filters out items whose
  /// product was deleted or deactivated before it answers.
  final WishlistProduct product;

  /// Optional preferred variant, so moving to the cart can skip the size
  /// picker. Genuinely nullable — most saves do not choose one.
  final String? variantId;

  /// The effective price at the moment it was saved. Purely informational;
  /// checkout always re-reads the live price.
  final double priceWhenAdded;

  final DateTime? addedAt;

  /// The variant to send when moving to the cart: the saved preference if it
  /// still exists, otherwise the first buyable one.
  WishlistVariant? get variantForCart =>
      product.variantById(variantId) ?? product.firstAvailableVariant;

  /// True when the product has got cheaper since it was saved — the prompt
  /// `priceWhenAdded` exists for.
  bool get priceDropped =>
      priceWhenAdded > 0 &&
      product.effectivePrice > 0 &&
      product.effectivePrice < priceWhenAdded - 0.009;

  double get priceDropAmount =>
      priceDropped ? priceWhenAdded - product.effectivePrice : 0;

  @override
  List<Object?> get props => [id, product, variantId, priceWhenAdded, addedAt];
}

/// The wishlist document as the API hands it back.
///
/// Hand-built by the service rather than serialised from Mongoose, which is
/// why there is no `user` field and no timestamps: it is exactly
/// `{_id, items, itemCount}`.
class Wishlist extends Equatable {
  const Wishlist({required this.id, this.items = const [], int? itemCount})
      : _itemCount = itemCount;

  const Wishlist.empty() : this(id: '');

  final String id;
  final List<WishlistItem> items;
  final int? _itemCount;

  /// The server's own count, falling back to the list length. They agree in
  /// practice; the fallback covers an optimistically-edited local copy.
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

  /// Drops a product locally, for an optimistic heart toggle. The count is
  /// recomputed from the list rather than carried over.
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
