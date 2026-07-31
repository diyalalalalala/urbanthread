import 'package:equatable/equatable.dart';

class ProductColor extends Equatable {
  const ProductColor({required this.name, this.hex = '#000000'});

  final String name;
  final String hex;

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

  final double? priceOverride;

  final bool isActive;

  bool get inStock => stock > 0;

  bool get isSelectable => isActive && stock > 0;

  @override
  List<Object?> get props => [id, color, size, sku, stock, priceOverride, isActive];
}

class CategoryRef extends Equatable {
  const CategoryRef({required this.id, this.name = '', this.slug = ''});

  final String id;
  final String name;
  final String slug;

  bool get isResolved => name.isNotEmpty;

  @override
  List<Object?> get props => [id, name, slug];
}

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

  double fractionFor(int stars) => count == 0 ? 0 : countFor(stars) / count;

  @override
  List<Object?> get props => [average, count, distribution];
}

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

  static const lowStockThreshold = 5;

  static const sizeScale = ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL', 'FREE'];

  final String id;
  final String name;
  final String slug;
  final String description;
  final String shortDescription;

  final CategoryRef? category;
  final BrandRef? brand;

  final double price;
  final double discountPercentage;

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

  final String? primaryImage;

  final bool? rawInStock;
  final bool? rawIsLowStock;
  final List<ProductColor>? rawAvailableColors;
  final List<String>? rawAvailableSizes;

  final double? searchScore;

  double get sellingPrice =>
      effectivePrice ?? (price * (1 - discountPercentage / 100));

  bool get hasDiscount => discountPercentage > 0;

  double? get compareAtPrice => hasDiscount ? price : null;

  double get savings => hasDiscount ? price - sellingPrice : 0;

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

  ProductVariant? variantFor({String? color, String? size}) {
    for (final variant in variants) {
      final colourMatches = color == null || variant.color.name == color;
      final sizeMatches = size == null || variant.size == size;
      if (colourMatches && sizeMatches && variant.isActive) return variant;
    }
    return null;
  }

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

class FrequentlyBoughtTogether extends Equatable {
  const FrequentlyBoughtTogether({
    required this.product,
    required this.coPurchaseCount,
  });

  final Product product;

  final int coPurchaseCount;

  @override
  List<Object?> get props => [product, coPurchaseCount];
}
