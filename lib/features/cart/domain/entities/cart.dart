import 'package:equatable/equatable.dart';

/// One purchasable colour/size combination of a cart product.
///
/// Only the fields the cart screen can act on are modelled: the stepper needs
/// [stock] to cap itself, and a re-pick of size/colour needs the label pair.
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

  /// Null means "use the product's price" — some sizes legitimately cost more.
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

/// The product a cart line points at.
///
/// Deliberately *not* the catalogue's product entity. `/cart` populates a
/// narrow projection — and unlike everywhere else in the API, `category` and
/// `brand` arrive as bare ObjectId strings rather than populated objects — so
/// the cart carries its own self-contained shape instead of pretending to hold
/// a full product it never received.
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

  /// Needed to route to the detail page — there is no `GET /products/:id`.
  final String slug;

  /// Resolved primary image. `primaryImage` is a virtual that this projection
  /// drops, so it is derived from `images` on the way in.
  final String? imageUrl;

  final double price;
  final double discountPercentage;

  /// Post-discount price. The *live* one — compare against the line's
  /// snapshot to spot a price change the server has not yet noticed.
  final double effectivePrice;

  final bool isActive;
  final List<CartVariant> variants;

  /// Bare ObjectIds on this endpoint, hence ids rather than entities.
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

/// A single line in the cart.
///
/// Name, image, sku, colour, size and unit price all live under the server's
/// `snapshot` object — there is no top-level `price`, `size` or `color` on a
/// cart item. They are flattened here so the UI reads one object, and the
/// snapshot's purpose (the price as it was when added, which the server
/// compares against the live price to raise a `price_changed` notice) is
/// preserved by keeping [unitPrice] distinct from `product.effectivePrice`.
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

  /// The cart *line* id — this is the `{itemId}` in the PATCH/DELETE paths,
  /// not the product id.
  final String id;

  final CartProduct product;
  final String variantId;

  /// Server-enforced range is 1..10.
  final int quantity;

  /// Snapshot price per unit, taken when the item was added.
  final double unitPrice;

  final String name;
  final String? imageUrl;
  final String sku;
  final String color;
  final String size;

  /// Saved-for-later lines stay in the same `items[]` array — there is no
  /// separate `savedForLater` collection to read. Filtering is the client's
  /// job, and [Cart.activeItems] / [Cart.savedItems] do it in one place.
  final bool savedForLater;

  final DateTime? addedAt;

  /// The API returns no per-line subtotal, so it is computed here.
  double get lineTotal => unitPrice * quantity;

  /// The variant this line refers to, when the populated product still carries
  /// it. Null once a variant is deleted — the server raises a `removed` notice
  /// on the next read, but the current payload can still contain the line.
  CartVariant? get variant => product.variantById(variantId);

  /// Units the customer could still add, capped at the API's per-line maximum
  /// of 10. Null when stock is unknown (the variant is no longer populated),
  /// which the stepper treats as "10" rather than blocking the control.
  int? get maxSelectableQuantity {
    final stock = variant?.stock;
    if (stock == null) return null;
    return stock < maxQuantityPerLine ? stock : maxQuantityPerLine;
  }

  /// True when the live price has drifted from the snapshot. The server says
  /// the same thing through a `price_changed` notice, but only after a read
  /// that reconciles — this is the cheap local check for a badge.
  bool get priceChanged =>
      product.effectivePrice > 0 &&
      (product.effectivePrice - unitPrice).abs() > 0.009;

  /// Backend cap: `max: [10, 'Maximum 10 units of a single item per order']`.
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

/// The coupon attached to the cart document.
///
/// Distinct from the summary's coupon block: this is what is *stored*, while
/// the summary reports whether it still validates. A code can sit here and be
/// worth nothing because it expired since it was applied.
class CartCoupon extends Equatable {
  const CartCoupon({this.couponId, this.code, this.discountAmount = 0});

  final String? couponId;
  final String? code;
  final double discountAmount;

  bool get isApplied => (code ?? '').isNotEmpty;

  @override
  List<Object?> get props => [couponId, code, discountAmount];
}

/// The cart document itself.
class Cart extends Equatable {
  const Cart({
    required this.id,
    this.items = const [],
    this.coupon = const CartCoupon(),
    this.createdAt,
    this.updatedAt,
  });

  /// An empty cart with no server identity yet — what an offline first-run
  /// shows before `/cart` has ever answered.
  const Cart.empty() : this(id: '');

  final String id;

  /// Active *and* saved-for-later lines, in one array, exactly as the API
  /// returns them.
  final List<CartItem> items;

  final CartCoupon coupon;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Lines that count toward the order.
  List<CartItem> get activeItems =>
      items.where((item) => !item.savedForLater).toList(growable: false);

  /// Lines parked for later. Excluded from every total and from checkout.
  List<CartItem> get savedItems =>
      items.where((item) => item.savedForLater).toList(growable: false);

  bool get isEmpty => items.isEmpty;
  bool get hasActiveItems => activeItems.isNotEmpty;

  /// Total units across active lines — the bottom-nav badge figure. Mirrors
  /// the server's `itemCount` virtual, which list responses drop.
  int get itemCount =>
      activeItems.fold(0, (sum, item) => sum + item.quantity);

  CartItem? itemById(String itemId) {
    for (final item in items) {
      if (item.id == itemId) return item;
    }
    return null;
  }

  /// Whether a product/variant pair is already in the cart. Adding it again
  /// increments the existing line rather than creating a second one.
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

  /// Replaces one line, leaving the rest untouched. The building block of
  /// every optimistic quantity change.
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
