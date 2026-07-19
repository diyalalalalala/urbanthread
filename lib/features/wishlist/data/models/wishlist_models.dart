import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/media_url.dart';
import '../../../cart/data/models/cart_models.dart';
import '../../domain/entities/wishlist.dart';
import '../../domain/entities/wishlist_move_result.dart';

part 'wishlist_models.g.dart';

/// Wire formats for `/wishlist`.
///
/// As with the cart, `toJson` is kept on every response DTO: the wishlist is
/// cached in Hive so it renders offline, and round-tripping the DTO means the
/// cached copy decodes through the same path as a live response.

/// The payload of `GET /wishlist` and of every wishlist mutation.
///
/// Hand-built by the service rather than serialised from Mongoose — there is
/// no `user` field and no `createdAt`/`updatedAt`, only these three keys.
@JsonSerializable()
class WishlistModel {
  const WishlistModel({
    required this.id,
    this.items = const [],
    this.itemCount,
  });

  factory WishlistModel.fromJson(Map<String, dynamic> json) =>
      _$WishlistModelFromJson(json);

  @JsonKey(name: '_id')
  final String id;
  final List<WishlistItemModel> items;

  /// Sent on every response, but modelled as nullable so a locally-edited
  /// cached copy can leave it to be recomputed from [items].
  final int? itemCount;

  Map<String, dynamic> toJson() => _$WishlistModelToJson(this);

  WishlistModel copyWith({List<WishlistItemModel>? items}) => WishlistModel(
        id: id,
        items: items ?? this.items,
        // Deliberately dropped when the items change: a stale count beside an
        // edited list is worse than deriving it.
        itemCount: items == null ? itemCount : null,
      );

  Wishlist toEntity() => Wishlist(
        id: id,
        items: items
            // The server already filters deleted and deactivated products, so
            // a null here would mean the contract changed. Guarding costs
            // nothing and keeps a bad payload from taking down the screen.
            .where((item) => item.product != null)
            .map((item) => item.toEntity())
            .toList(growable: false),
        itemCount: itemCount,
      );
}

@JsonSerializable()
class WishlistItemModel {
  const WishlistItemModel({
    required this.id,
    this.product,
    this.variantId,
    this.priceWhenAdded = 0,
    this.addedAt,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) =>
      _$WishlistItemModelFromJson(json);

  @JsonKey(name: '_id')
  final String id;

  @JsonKey(fromJson: _productFromJson)
  final WishlistProductModel? product;

  /// Genuinely nullable — most saves do not pick a variant.
  @JsonKey(fromJson: _objectId)
  final String? variantId;

  final double priceWhenAdded;
  final String? addedAt;

  Map<String, dynamic> toJson() => _$WishlistItemModelToJson(this);

  WishlistItem toEntity() => WishlistItem(
        id: id,
        product: product!.toEntity(),
        variantId: variantId,
        priceWhenAdded: priceWhenAdded,
        addedAt: _parseDate(addedAt),
      );
}

/// The card-shaped product projection `/wishlist` populates.
///
/// Richer than the cart's: it carries `rating`, `totalStock`, and `brand` and
/// `category` as **populated `{_id, name, slug}` objects** rather than the
/// bare ObjectId strings the cart returns.
@JsonSerializable()
class WishlistProductModel {
  const WishlistProductModel({
    required this.id,
    required this.name,
    this.slug = '',
    this.images = const [],
    this.price = 0,
    this.discountPercentage = 0,
    this.effectivePrice = 0,
    this.rating,
    this.totalStock = 0,
    this.variants = const [],
    this.isActive = true,
    this.brand,
    this.category,
  });

  factory WishlistProductModel.fromJson(Map<String, dynamic> json) =>
      _$WishlistProductModelFromJson(json);

  @JsonKey(name: '_id')
  final String id;
  final String name;
  final String slug;

  /// Reused from the cart's models — the image and variant sub-documents are
  /// the same product schema on both endpoints, and a second identical DTO
  /// would be two things to keep in step with one backend field.
  final List<ProductImageModel> images;

  final double price;
  final double discountPercentage;
  final double effectivePrice;

  /// Nested `{average, count}` on the wire.
  final ProductRatingModel? rating;

  final int totalStock;
  final List<ProductVariantModel> variants;
  final bool isActive;

  @JsonKey(fromJson: _referenceFromJson)
  final ReferenceModel? brand;

  @JsonKey(fromJson: _referenceFromJson)
  final ReferenceModel? category;

  Map<String, dynamic> toJson() => _$WishlistProductModelToJson(this);

  /// `primaryImage` is a virtual this projection drops, so it is derived.
  String? get primaryImageUrl {
    if (images.isEmpty) return null;
    for (final image in images) {
      if (image.isPrimary && image.url.isNotEmpty) return image.url;
    }
    return images.first.url;
  }

  WishlistProduct toEntity() => WishlistProduct(
        id: id,
        name: name,
        slug: slug,
        imageUrl: MediaUrl.resolve(primaryImageUrl),
        price: price,
        discountPercentage: discountPercentage,
        effectivePrice: effectivePrice > 0 ? effectivePrice : price,
        ratingAverage: rating?.average ?? 0,
        ratingCount: rating?.count ?? 0,
        totalStock: totalStock,
        variants: variants
            .map(
              (variant) => WishlistVariant(
                id: variant.id,
                size: variant.size,
                colorName: variant.color?.name ?? '',
                colorHex: variant.color?.hex ?? '#000000',
                sku: variant.sku,
                stock: variant.stock,
                priceOverride: variant.priceOverride,
                isActive: variant.isActive,
              ),
            )
            .toList(growable: false),
        isActive: isActive,
        brand: brand?.toEntity(),
        category: category?.toEntity(),
      );
}

@JsonSerializable()
class ProductRatingModel {
  const ProductRatingModel({this.average = 0, this.count = 0});

  factory ProductRatingModel.fromJson(Map<String, dynamic> json) =>
      _$ProductRatingModelFromJson(json);

  final double average;
  final int count;

  Map<String, dynamic> toJson() => _$ProductRatingModelToJson(this);
}

/// A populated `{_id, name, slug}` reference.
@JsonSerializable()
class ReferenceModel {
  const ReferenceModel({required this.id, this.name = '', this.slug = ''});

  factory ReferenceModel.fromJson(Map<String, dynamic> json) =>
      _$ReferenceModelFromJson(json);

  @JsonKey(name: '_id')
  final String id;
  final String name;
  final String slug;

  Map<String, dynamic> toJson() => _$ReferenceModelToJson(this);

  WishlistReference toEntity() =>
      WishlistReference(id: id, name: name, slug: slug);
}

/// `POST /wishlist/{productId}/move-to-cart` → `{ cart, wishlist }`.
///
/// The `cart` member is the whole `{cart, notices, summary}` triple, so totals
/// are at `data.cart.summary` — nested one level deeper than every other cart
/// response, which is exactly the kind of thing a hand-written path would get
/// wrong.
@JsonSerializable(createToJson: false)
class WishlistMoveResultModel {
  const WishlistMoveResultModel({required this.cart, required this.wishlist});

  factory WishlistMoveResultModel.fromJson(Map<String, dynamic> json) =>
      _$WishlistMoveResultModelFromJson(json);

  final CartSnapshotModel cart;
  final WishlistModel wishlist;

  WishlistMoveResult toEntity() => WishlistMoveResult(
        cart: cart.toEntity(),
        wishlist: wishlist.toEntity(),
      );
}

/// `GET /wishlist/{productId}/check` → `{ productId, inWishlist }`.
@JsonSerializable(createToJson: false)
class WishlistCheckModel {
  const WishlistCheckModel({required this.productId, this.inWishlist = false});

  factory WishlistCheckModel.fromJson(Map<String, dynamic> json) =>
      _$WishlistCheckModelFromJson(json);

  final String productId;
  final bool inWishlist;
}

// ── Requests ─────────────────────────────────────────────────────────────

/// Body of `POST /wishlist`.
@JsonSerializable(createFactory: false, includeIfNull: false)
class AddWishlistItemRequest {
  const AddWishlistItemRequest({required this.productId, this.variantId});

  final String productId;

  /// Omitted rather than sent as null — the validator rejects an empty string
  /// but accepts an absent key.
  final String? variantId;

  Map<String, dynamic> toJson() => _$AddWishlistItemRequestToJson(this);
}

/// Body of `POST /wishlist/{productId}/move-to-cart`. Quantity is not a
/// parameter — the server hard-codes 1.
@JsonSerializable(createFactory: false, includeIfNull: false)
class WishlistMoveToCartRequest {
  const WishlistMoveToCartRequest({this.variantId});

  final String? variantId;

  Map<String, dynamic> toJson() => _$WishlistMoveToCartRequestToJson(this);
}

// ── Decoding helpers ─────────────────────────────────────────────────────

WishlistProductModel? _productFromJson(Object? raw) =>
    raw is Map<String, dynamic> ? WishlistProductModel.fromJson(raw) : null;

/// Tolerates a reference arriving unpopulated (a bare ObjectId) even though
/// this endpoint populates both — the same field is a raw string on the cart,
/// so the shape is not something to assume.
ReferenceModel? _referenceFromJson(Object? raw) {
  if (raw is Map<String, dynamic>) return ReferenceModel.fromJson(raw);
  if (raw is String && raw.isNotEmpty) return ReferenceModel(id: raw);
  return null;
}

String? _objectId(Object? raw) {
  if (raw is String) return raw.isEmpty ? null : raw;
  if (raw is Map) {
    final id = raw['_id'] ?? raw['id'];
    return id is String && id.isNotEmpty ? id : null;
  }
  return null;
}

DateTime? _parseDate(String? raw) =>
    (raw == null || raw.isEmpty) ? null : DateTime.tryParse(raw);
