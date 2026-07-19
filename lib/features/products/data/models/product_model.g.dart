// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
  id: json['_id'] as String,
  name: json['name'] as String,
  slug: json['slug'] as String,
  price: (json['price'] as num).toDouble(),
  description: json['description'] as String? ?? '',
  shortDescription: json['shortDescription'] as String? ?? '',
  category: const CategoryRefConverter().fromJson(json['category']),
  brand: const BrandRefConverter().fromJson(json['brand']),
  discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0,
  effectivePrice: (json['effectivePrice'] as num?)?.toDouble(),
  images:
      (json['images'] as List<dynamic>?)
          ?.map((e) => ProductImageModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  variants:
      (json['variants'] as List<dynamic>?)
          ?.map((e) => ProductVariantModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  totalStock: (json['totalStock'] as num?)?.toInt() ?? 0,
  specifications:
      (json['specifications'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  rating: json['rating'] == null
      ? const RatingModel()
      : RatingModel.fromJson(json['rating'] as Map<String, dynamic>),
  soldCount: (json['soldCount'] as num?)?.toInt() ?? 0,
  viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
  isActive: json['isActive'] as bool? ?? true,
  isFeatured: json['isFeatured'] as bool? ?? false,
  isNewArrival: json['isNewArrival'] as bool? ?? false,
  createdAt: json['createdAt'] as String?,
  primaryImage: json['primaryImage'] as String?,
  inStock: json['inStock'] as bool?,
  isLowStock: json['isLowStock'] as bool?,
  availableColors: (json['availableColors'] as List<dynamic>?)
      ?.map((e) => ProductColorModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  availableSizes: (json['availableSizes'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  score: (json['score'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'shortDescription': instance.shortDescription,
      'category': const CategoryRefConverter().toJson(instance.category),
      'brand': const BrandRefConverter().toJson(instance.brand),
      'price': instance.price,
      'discountPercentage': instance.discountPercentage,
      'effectivePrice': instance.effectivePrice,
      'images': instance.images,
      'variants': instance.variants,
      'totalStock': instance.totalStock,
      'specifications': instance.specifications,
      'tags': instance.tags,
      'rating': instance.rating,
      'soldCount': instance.soldCount,
      'viewCount': instance.viewCount,
      'isActive': instance.isActive,
      'isFeatured': instance.isFeatured,
      'isNewArrival': instance.isNewArrival,
      'createdAt': instance.createdAt,
      'primaryImage': instance.primaryImage,
      'inStock': instance.inStock,
      'isLowStock': instance.isLowStock,
      'availableColors': instance.availableColors,
      'availableSizes': instance.availableSizes,
      'score': instance.score,
    };

ProductImageModel _$ProductImageModelFromJson(Map<String, dynamic> json) =>
    ProductImageModel(
      id: json['_id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      publicId: json['publicId'] as String? ?? '',
      alt: json['alt'] as String? ?? '',
      isPrimary: json['isPrimary'] as bool? ?? false,
    );

Map<String, dynamic> _$ProductImageModelToJson(ProductImageModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'url': instance.url,
      'publicId': instance.publicId,
      'alt': instance.alt,
      'isPrimary': instance.isPrimary,
    };

ProductColorModel _$ProductColorModelFromJson(Map<String, dynamic> json) =>
    ProductColorModel(
      name: json['name'] as String,
      hex: json['hex'] as String? ?? '#000000',
    );

Map<String, dynamic> _$ProductColorModelToJson(ProductColorModel instance) =>
    <String, dynamic>{'name': instance.name, 'hex': instance.hex};

ProductVariantModel _$ProductVariantModelFromJson(Map<String, dynamic> json) =>
    ProductVariantModel(
      color: ProductColorModel.fromJson(json['color'] as Map<String, dynamic>),
      size: json['size'] as String,
      id: json['_id'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      priceOverride: (json['priceOverride'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$ProductVariantModelToJson(
  ProductVariantModel instance,
) => <String, dynamic>{
  '_id': instance.id,
  'color': instance.color,
  'size': instance.size,
  'sku': instance.sku,
  'stock': instance.stock,
  'priceOverride': instance.priceOverride,
  'isActive': instance.isActive,
};

RatingModel _$RatingModelFromJson(Map<String, dynamic> json) => RatingModel(
  average: (json['average'] as num?)?.toDouble() ?? 0,
  count: (json['count'] as num?)?.toInt() ?? 0,
  distribution:
      (json['distribution'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
);

Map<String, dynamic> _$RatingModelToJson(RatingModel instance) =>
    <String, dynamic>{
      'average': instance.average,
      'count': instance.count,
      'distribution': instance.distribution,
    };

CategoryRefModel _$CategoryRefModelFromJson(Map<String, dynamic> json) =>
    CategoryRefModel(
      id: json['_id'] as String,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );

Map<String, dynamic> _$CategoryRefModelToJson(CategoryRefModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
    };

BrandRefModel _$BrandRefModelFromJson(Map<String, dynamic> json) =>
    BrandRefModel(
      id: json['_id'] as String,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      logo: json['logo'] == null
          ? null
          : BrandLogoModel.fromJson(json['logo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BrandRefModelToJson(BrandRefModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'logo': instance.logo,
    };

BrandLogoModel _$BrandLogoModelFromJson(Map<String, dynamic> json) =>
    BrandLogoModel(
      url: json['url'] as String? ?? '',
      publicId: json['publicId'] as String? ?? '',
    );

Map<String, dynamic> _$BrandLogoModelToJson(BrandLogoModel instance) =>
    <String, dynamic>{'url': instance.url, 'publicId': instance.publicId};

FrequentlyBoughtTogetherModel _$FrequentlyBoughtTogetherModelFromJson(
  Map<String, dynamic> json,
) => FrequentlyBoughtTogetherModel(
  product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
  coPurchaseCount: (json['coPurchaseCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$FrequentlyBoughtTogetherModelToJson(
  FrequentlyBoughtTogetherModel instance,
) => <String, dynamic>{
  'product': instance.product,
  'coPurchaseCount': instance.coPurchaseCount,
};
