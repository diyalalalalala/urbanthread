import 'package:equatable/equatable.dart';

/// A colour swatch on a variant. `hex` is always populated by the backend
/// (`#000000` is its default), so it can be rendered without a null check.
class ProductColor extends Equatable {
  const ProductColor({required this.name, this.hex = '#000000'});

  final String name;
  final String hex;

  /// The 0xAARRGGBB value the swatch should paint, or null when the backend
  /// stored something that is not a hex triplet. Parsing here rather than in
  /// the widget keeps the fallback decision in one place.
  int? get argb {
    final cleaned = hex.replaceFirst('#', '').trim();
    final normalised = switch (cleaned.length) {
      6 => 'FF$cleaned',
      8 => cleaned,
      3 => 'FF${cleaned.split('').map((c) => '$c$c').join()}',
      _ => null,
    };
    if (normalised == null) return null;
    return int.tryParse(normalised, radix: 16);
  }

  @override
  List<Object?> get props => [name, hex];
}

/// One catalogue image.
///
/// [url] is nullable because the API's "no image" sentinel is an empty
/// string, normalised away in the model.
class ProductImage extends Equatable {
  const ProductImage({
    required this.id,
    this.url,
    this.alt = '',
    this.isPrimary = false,
  });

  final String id;
  final String? url;
  final String alt;
  final bool isPrimary;

  @override
  List<Object?> get props => [id, url, alt, isPrimary];
}

/// A purchasable colour/size combination, each with its own stock and SKU.
class ProductVariant extends Equatable {
  const ProductVariant({
    required this.id,
    required this.color,
    required this.size,
    required this.sku,
    this.stock = 0,
    this.priceOverride,
    this.isActive = true,
  });

  final String id;
  final ProductColor color;
  final String size;
  final String sku;
  final int stock;

  /// Null means "use the product's price". Some sizes genuinely cost more.
  final double? priceOverride;

  final bool isActive;

  bool get inStock => stock > 0;

  /// Purchasable = active *and* stocked. The API leaves inactive variants in
  /// the array rather than removing them, so both flags must be checked.
  bool get isSelectable => isActive && stock > 0;

  @override
  List<Object?> get props => [id, color, size, sku, stock, priceOverride, isActive];
}

/// A category as it appears embedded on a product.
///
/// Populated to `{_id, name, slug, parent}` on most endpoints but delivered as
/// a bare ObjectId string by `/products/:id/frequently-bought-together`. In
/// that case only [id] is known and [name]/[slug] are empty — call
/// [isResolved] before rendering a label.
class CategoryRef extends Equatable {
  const CategoryRef({required this.id, this.name = '', this.slug = ''});

  final String id;
  final String name;
  final String slug;

  bool get isResolved => name.isNotEmpty;

  @override
  List<Object?> get props => [id, name, slug];
}

/// A brand as it appears embedded on a product. Same polymorphism as
/// [CategoryRef].
class BrandRef extends Equatable {
  const BrandRef({
    required this.id,
    this.name = '',
    this.slug = '',
    this.logoUrl,
  });

  final String id;
  final String name;
  final String slug;
  final String? logoUrl;

  bool get isResolved => name.isNotEmpty;

  @override
  List<Object?> get props => [id, name, slug, logoUrl];
}

/// The denormalised rating aggregate stored on the product document.
///
/// [distribution] is keyed by star value 1–5. The wire format uses *string*
/// keys ("1".."5") because Mongo serialises a nested-object histogram that
/// way; they are converted to ints at the model boundary so the UI can index
/// with a number.
class ProductRating extends Equatable {
  const ProductRating({
    this.average = 0,
    this.count = 0,
    this.distribution = const {},
  });

  final double average;
  final int count;
  final Map<int, int> distribution;

  bool get hasReviews => count > 0;

  int countFor(int stars) => distribution[stars] ?? 0;

  /// Share of reviews at [stars], 0–1, for the histogram bars.
  double fractionFor(int stars) => count == 0 ? 0 : countFor(stars) / count;

  @override
  List<Object?> get props => [average, count, distribution];
}

/// A catalogue product.
///
/// The same entity is produced by list, search, detail, collection and
/// recommendation endpoints, which do not all return the same fields — so
/// every value the API only sometimes sends is nullable here and has a
/// client-side fallback. In particular the Mongoose virtuals ([primaryImage],
/// [rawInStock], [rawIsLowStock], [rawAvailableColors], [rawAvailableSizes])
/// exist **only** on `GET /products/{slug}`; every other route uses `.lean()`,
/// which strips them. Read them through the computed getters below, never
/// directly.
class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    this.description = '',
    this.shortDescription = '',
    this.category,
    this.brand,
    this.discountPercentage = 0,
    this.effectivePrice,
    this.images = const [],
    this.variants = const [],
    this.totalStock = 0,
    this.specifications = const {},
    this.tags = const [],
    this.rating = const ProductRating(),
    this.soldCount = 0,
    this.viewCount = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.isNewArrival = false,
    this.createdAt,
    this.primaryImage,
    this.rawInStock,
    this.rawIsLowStock,
    this.rawAvailableColors,
    this.rawAvailableSizes,
    this.searchScore,
  });

  /// Stock at or below which the backend considers a product low
  /// (`LOW_STOCK_THRESHOLD`, default 5). The API exposes the verdict only as
  /// the detail-page `isLowStock` virtual, so list cards need the threshold
  /// locally to reach the same answer.
  static const lowStockThreshold = 5;

  /// The canonical size order the backend sorts `availableSizes` by. Mirrored
  /// so a locally computed size list is ordered identically to the server's.
  static const sizeScale = ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL', 'FREE'];

  final String id;
  final String name;
  final String slug;
  final String description;
  final String shortDescription;

  /// Null only if the API omitted the field entirely; every product has one.
  final CategoryRef? category;
  final BrandRef? brand;

  final double price;
  final double discountPercentage;

  /// Post-discount price, stored server-side so `sort=price_asc` can index
  /// it. Nullable because a projection could drop it — use [sellingPrice].
  final double? effectivePrice;

  final List<ProductImage> images;
  final List<ProductVariant> variants;
  final int totalStock;
  final Map<String, String> specifications;
  final List<String> tags;
  final ProductRating rating;
  final int soldCount;
  final int viewCount;
  final bool isActive;
  final bool isFeatured;
  final bool isNewArrival;
  final DateTime? createdAt;

  // ── Virtuals — detail endpoint only ────────────────────────────────────

  /// The primary image *URL* (the virtual resolves to a string, not to the
  /// image object). Null off the detail route — use [displayImageUrl].
  final String? primaryImage;

  final bool? rawInStock;
  final bool? rawIsLowStock;
  final List<ProductColor>? rawAvailableColors;
  final List<String>? rawAvailableSizes;

  /// Text-search relevance, added by `/products/search` when the term is at
  /// least 3 characters. Absent everywhere else.
  final double? searchScore;

  // ── Derived ───────────────────────────────────────────────────────────

  /// What the customer actually pays. Falls back to computing the discount
  /// when `effectivePrice` was not projected.
  double get sellingPrice =>
      effectivePrice ?? (price * (1 - discountPercentage / 100));

  bool get hasDiscount => discountPercentage > 0;

  /// The struck-through original price, or null when nothing is on offer.
  double? get compareAtPrice => hasDiscount ? price : null;

  double get savings => hasDiscount ? price - sellingPrice : 0;

  /// The image to show on a card, preferring the server's own choice and
  /// falling back through the flagged primary to the first available.
  String? get displayImageUrl {
    if (primaryImage != null && primaryImage!.isNotEmpty) return primaryImage;
    for (final image in images) {
      if (image.isPrimary && image.url != null) return image.url;
    }
    for (final image in images) {
      if (image.url != null) return image.url;
    }
    return null;
  }

  /// Every renderable image URL, primary first — the detail gallery's source.
  List<String> get galleryUrls {
    final ordered = [...images]..sort((a, b) {
      if (a.isPrimary == b.isPrimary) return 0;
      return a.isPrimary ? -1 : 1;
    });
    return [
      for (final image in ordered)
        if (image.url != null) image.url!,
    ];
  }

  bool get inStock =>
      rawInStock ??
      (totalStock > 0 || variants.any((variant) => variant.isSelectable));

  bool get isLowStock =>
      rawIsLowStock ?? (totalStock > 0 && totalStock <= lowStockThreshold);

  bool get isOutOfStock => !inStock;

  /// Distinct colours across active variants, in first-seen order — the same
  /// rule the server's virtual applies.
  List<ProductColor> get availableColors {
    if (rawAvailableColors != null) return rawAvailableColors!;
    final seen = <String, ProductColor>{};
    for (final variant in variants) {
      if (variant.isActive) {
        seen.putIfAbsent(variant.color.name, () => variant.color);
      }
    }
    return seen.values.toList(growable: false);
  }

  /// Distinct sizes across active variants, ordered by [sizeScale]. Sizes
  /// outside the scale (numeric footwear) sort last, numerically — matching
  /// the backend so the chip order does not change between list and detail.
  List<String> get availableSizes {
    if (rawAvailableSizes != null) return rawAvailableSizes!;
    final sizes = <String>{
      for (final variant in variants)
        if (variant.isActive) variant.size,
    }.toList();
    sizes.sort((a, b) {
      final indexA = sizeScale.indexOf(a);
      final indexB = sizeScale.indexOf(b);
      if (indexA == -1 && indexB == -1) {
        return a.compareTo(b);
      }
      if (indexA == -1) return 1;
      if (indexB == -1) return -1;
      return indexA - indexB;
    });
    return sizes;
  }

  /// The variant matching both selections, or null if that combination does
  /// not exist. Colour is matched by name because that is the identity the
  /// backend's `$elemMatch` filter uses — hex is presentation only.
  ProductVariant? variantFor({String? color, String? size}) {
    for (final variant in variants) {
      final colourMatches = color == null || variant.color.name == color;
      final sizeMatches = size == null || variant.size == size;
      if (colourMatches && sizeMatches && variant.isActive) return variant;
    }
    return null;
  }

  /// Sizes available in [color] — used to grey out sizes that combination
  /// cannot satisfy.
  List<String> sizesForColor(String color) {
    final sizes = <String>{
      for (final variant in variants)
        if (variant.isActive && variant.color.name == color) variant.size,
    }.toList();
    sizes.sort((a, b) {
      final indexA = sizeScale.indexOf(a);
      final indexB = sizeScale.indexOf(b);
      if (indexA == -1 && indexB == -1) return a.compareTo(b);
      if (indexA == -1) return 1;
      if (indexB == -1) return -1;
      return indexA - indexB;
    });
    return sizes;
  }

  /// Price for a specific variant: its override replaces the base price but
  /// still takes the product-level discount, mirroring the server's
  /// `priceForVariant`. Keeping the two in step matters — the cart is priced
  /// server-side and a mismatch would look like a bug at checkout.
  double priceForVariant(ProductVariant? variant) {
    final base = variant?.priceOverride ?? price;
    return base * (1 - discountPercentage / 100);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        description,
        shortDescription,
        category,
        brand,
        price,
        discountPercentage,
        effectivePrice,
        images,
        variants,
        totalStock,
        specifications,
        tags,
        rating,
        soldCount,
        viewCount,
        isActive,
        isFeatured,
        isNewArrival,
        createdAt,
        primaryImage,
        rawInStock,
        rawIsLowStock,
        rawAvailableColors,
        rawAvailableSizes,
        searchScore,
      ];
}

/// A companion product from `/products/{id}/frequently-bought-together`,
/// carrying the co-purchase evidence alongside it.
///
/// Its own wrapper has no `_id`, so this is keyed by the product it holds.
class FrequentlyBoughtTogether extends Equatable {
  const FrequentlyBoughtTogether({
    required this.product,
    required this.coPurchaseCount,
  });

  final Product product;

  /// Number of distinct fulfilled orders containing both products.
  final int coPurchaseCount;

  @override
  List<Object?> get props => [product, coPurchaseCount];
}
