import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/media_url.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_notice.dart';
import '../../domain/entities/cart_snapshot.dart';
import '../../domain/entities/cart_summary.dart';

part 'cart_models.g.dart';

/// Wire formats for `/cart`.
///
/// Every model here keeps `toJson`, which is not the usual default for a
/// response DTO. The cart is cached in Hive so it renders offline, and
/// `CacheStore` stores JSON — round-tripping the DTO is what lets the cached
/// copy decode through exactly the same path as a live response.
///
/// Dates stay as strings for the same reason: no converter, no timezone
/// surprises on the way back out, and `toEntity()` is the single place that
/// parses them.

/// `{ cart, notices, summary }` — the payload of every cart endpoint except
/// `/cart/summary`.
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

  /// Used to persist the result of an offline mutation.
  ///
  /// Offline edits are applied to the *model* rather than to the entity so the
  /// cached copy stays a plain server-shaped JSON document — the same shape a
  /// live response would have written. That keeps one decode path for both,
  /// and means a queued write replaying later cannot find a cache it does not
  /// know how to read.
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

  /// Active and saved-for-later lines together — the API has no second array.
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
            // A line whose product did not populate cannot be rendered or
            // acted on. The server raises a `removed` notice for it on the
            // same read, so dropping it here loses nothing the customer needs.
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

  /// A reference, so it can arrive populated on some paths. Only the id is
  /// ever needed here.
  @JsonKey(fromJson: _objectId)
  final String? couponId;

  final String? code;
  final double discountAmount;

  Map<String, dynamic> toJson() => _$CartCouponModelToJson(this);

  CartCoupon toEntity() => CartCoupon(
        couponId: couponId,
        // The backend's "no coupon" is a literal null on both fields, but an
        // empty string would read as an applied code downstream.
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

  /// The line id used in `/cart/items/{itemId}` — not the product id.
  @JsonKey(name: '_id')
  final String id;

  /// Null only if the populate failed; see [CartModel.toEntity].
  @JsonKey(fromJson: _productFromJson)
  final CartProductModel? product;

  @JsonKey(fromJson: _objectId)
  final String? variantId;

  final int quantity;

  /// Price/name/size/colour as they were when the item was added. There is no
  /// top-level `price`, `size` or `color` on a cart item — only this.
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
        // Falls back to the product's own imagery: the snapshot's `image`
        // defaults to `""`, which is this API's null sentinel.
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

  /// Post-discount unit price at the time of adding.
  final double unitPrice;

  Map<String, dynamic> toJson() => _$CartItemSnapshotModelToJson(this);
}

/// The narrow product projection `/cart` populates.
///
/// `category` and `brand` are **bare ObjectId strings here**, unlike almost
/// everywhere else in the API where they arrive populated. The converter below
/// tolerates both anyway so a future backend change cannot break decoding.
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

  /// `primaryImage` is a virtual this projection drops, so it is derived from
  /// the stored array — the `isPrimary` flag first, then the first image.
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
        // `effectivePrice` is stored, not virtual, but an old document seeded
        // before the field existed would decode as 0 and make every line look
        // like a price drop.
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

  /// Null means "use the product's price".
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

  /// `removed` | `quantity_reduced` | `price_changed`.
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

/// The standalone payload of `GET /cart/summary`, and the `summary` block of
/// every other cart response.
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

  /// Persists a locally-estimated summary alongside an offline edit, so the
  /// cached cart still shows totals consistent with its own lines. Replaced
  /// wholesale by the server's figures on the next successful read.
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

  /// The payable total. Never `total` — that key does not exist.
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

/// `GET /cart/validate` on the happy path: `{ cart, summary, coupon }`.
///
/// Only the summary is modelled — the cart it echoes is identical to the one
/// already held, and the failure path (a 422 listing every blocker) never
/// reaches this type.
@JsonSerializable(createToJson: false)
class CartValidationModel {
  const CartValidationModel({this.summary = const CartSummaryModel()});

  factory CartValidationModel.fromJson(Map<String, dynamic> json) =>
      _$CartValidationModelFromJson(json);

  final CartSummaryModel summary;
}

// ── Requests ─────────────────────────────────────────────────────────────

/// Body of `POST /cart/items`.
///
/// Exactly these three keys. The route's validator rejects anything carrying a
/// price with a 422 — the server prices the line from its own product record,
/// which is the whole point of the snapshot design.
@JsonSerializable(createFactory: false, includeIfNull: false)
class AddCartItemRequest {
  const AddCartItemRequest({
    required this.productId,
    required this.variantId,
    this.quantity,
  });

  final String productId;
  final String variantId;

  /// Omitted rather than sent as null; the server defaults it to 1.
  final int? quantity;

  Map<String, dynamic> toJson() => _$AddCartItemRequestToJson(this);
}

/// Body of `PATCH /cart/items/{itemId}` — an absolute quantity, not a delta.
@JsonSerializable(createFactory: false)
class UpdateCartItemRequest {
  const UpdateCartItemRequest({required this.quantity});

  final int quantity;

  Map<String, dynamic> toJson() => _$UpdateCartItemRequestToJson(this);
}

/// Body of `POST /cart/coupon`. 3–24 characters; uppercased server-side.
@JsonSerializable(createFactory: false)
class ApplyCouponRequest {
  const ApplyCouponRequest({required this.code});

  final String code;

  Map<String, dynamic> toJson() => _$ApplyCouponRequestToJson(this);
}

// ── Decoding helpers ─────────────────────────────────────────────────────

/// Reads an id that may arrive as a bare ObjectId string or as a populated
/// object. `category` and `brand` are polymorphic across this API, and the
/// cart is the endpoint that returns the bare form.
String? _objectId(Object? raw) {
  if (raw is String) return raw.isEmpty ? null : raw;
  if (raw is Map) {
    final id = raw['_id'] ?? raw['id'];
    return id is String && id.isNotEmpty ? id : null;
  }
  return null;
}

/// Tolerates an unpopulated `product` (a bare id) instead of throwing. The
/// line is dropped in [CartModel.toEntity] rather than crashing the screen.
CartProductModel? _productFromJson(Object? raw) =>
    raw is Map<String, dynamic> ? CartProductModel.fromJson(raw) : null;

DateTime? _parseDate(String? raw) =>
    (raw == null || raw.isEmpty) ? null : DateTime.tryParse(raw);
