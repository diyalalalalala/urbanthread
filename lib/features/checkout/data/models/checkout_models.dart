import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/media_url.dart';
import '../../domain/entities/checkout_cart.dart';
import '../../domain/entities/coupon.dart';

part 'checkout_models.g.dart';

String? _readId(Object? raw) => switch (raw) {
      String value when value.isNotEmpty => value,
      Map<String, dynamic> value => value['_id'] as String?,
      _ => null,
    };

String? _writeId(String? value) => value;

List<String> _readIdList(Object? raw) {
  if (raw is! List) return const [];
  return raw
      .map(_readId)
      .whereType<String>()
      .toList(growable: false);
}

List<String> _writeIdList(List<String> value) => value;

double _readNum(Object? raw) => switch (raw) {
      num value => value.toDouble(),
      String value => double.tryParse(value) ?? 0,
      _ => 0,
    };

double? _readNullableNum(Object? raw) => switch (raw) {
      num value => value.toDouble(),
      String value => double.tryParse(value),
      _ => null,
    };

Object? _writeNullableNum(double? value) => value;

DateTime? _parseDate(String? raw) =>
    (raw == null || raw.isEmpty) ? null : DateTime.tryParse(raw);

String? _nullIfBlank(String? value) =>
    (value == null || value.isEmpty) ? null : value;

@JsonSerializable(createToJson: true)
class CartSummaryModel {
  const CartSummaryModel({
    required this.subtotal,
    required this.grandTotal,
    this.discount = 0,
    this.tax = 0,
    this.shipping = 0,
    this.currency = 'NPR',
    this.itemCount = 0,
    this.savedForLaterCount = 0,
    this.freeShippingEligible = false,
    this.amountToFreeShipping = 0,
    this.coupon,
  });

  factory CartSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$CartSummaryModelFromJson(json);

  @JsonKey(fromJson: _readNum)
  final double subtotal;

  @JsonKey(fromJson: _readNum)
  final double discount;

  @JsonKey(fromJson: _readNum)
  final double tax;

  @JsonKey(fromJson: _readNum)
  final double shipping;

  @JsonKey(fromJson: _readNum)
  final double grandTotal;

  final String currency;
  final int itemCount;
  final int savedForLaterCount;
  final bool freeShippingEligible;

  @JsonKey(fromJson: _readNum)
  final double amountToFreeShipping;

  final AppliedCouponModel? coupon;

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

@JsonSerializable(createToJson: true)
class AppliedCouponModel {
  const AppliedCouponModel({
    required this.code,
    this.discountAmount = 0,
    this.valid = true,
    this.message,
  });

  factory AppliedCouponModel.fromJson(Map<String, dynamic> json) =>
      _$AppliedCouponModelFromJson(json);

  final String code;

  @JsonKey(fromJson: _readNum)
  final double discountAmount;

  final bool valid;
  final String? message;

  Map<String, dynamic> toJson() => _$AppliedCouponModelToJson(this);

  AppliedCoupon toEntity() => AppliedCoupon(
        code: code,
        discountAmount: discountAmount,
        valid: valid,
        message: _nullIfBlank(message),
      );
}

@JsonSerializable(createToJson: true)
class CartItemModel {
  const CartItemModel({
    required this.id,
    required this.snapshot,
    this.product,
    this.variantId,
    this.quantity = 1,
    this.savedForLater = false,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);

  @JsonKey(name: '_id')
  final String id;

  @JsonKey(fromJson: _readId, toJson: _writeId)
  final String? product;

  @JsonKey(fromJson: _readId, toJson: _writeId)
  final String? variantId;

  final int quantity;
  final CartItemSnapshotModel snapshot;

  final bool savedForLater;

  Map<String, dynamic> toJson() => _$CartItemModelToJson(this);

  CheckoutLine toEntity() => CheckoutLine(
        itemId: id,
        productId: product ?? '',
        variantId: variantId ?? '',
        name: snapshot.name,
        image: MediaUrl.resolve(snapshot.image),
        sku: snapshot.sku,
        color: snapshot.color,
        size: snapshot.size,
        quantity: quantity,
        unitPrice: snapshot.unitPrice,
      );
}

@JsonSerializable(createToJson: true)
class CartItemSnapshotModel {
  const CartItemSnapshotModel({
    required this.name,
    required this.unitPrice,
    this.image = '',
    this.sku = '',
    this.color = '',
    this.size = '',
  });

  factory CartItemSnapshotModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemSnapshotModelFromJson(json);

  final String name;
  final String image;
  final String sku;
  final String color;
  final String size;

  @JsonKey(fromJson: _readNum)
  final double unitPrice;

  Map<String, dynamic> toJson() => _$CartItemSnapshotModelToJson(this);
}

@JsonSerializable(createToJson: true)
class CartModel {
  const CartModel({this.items = const []});

  factory CartModel.fromJson(Map<String, dynamic> json) =>
      _$CartModelFromJson(json);

  final List<CartItemModel> items;

  Map<String, dynamic> toJson() => _$CartModelToJson(this);
}

@JsonSerializable(createToJson: true)
class CartValidationModel {
  const CartValidationModel({
    required this.cart,
    required this.summary,
    this.coupon,
  });

  factory CartValidationModel.fromJson(Map<String, dynamic> json) =>
      _$CartValidationModelFromJson(json);

  final CartModel cart;
  final CartSummaryModel summary;

  final ValidatedCouponModel? coupon;

  Map<String, dynamic> toJson() => _$CartValidationModelToJson(this);

  CheckoutCart toEntity() => CheckoutCart(
        lines: cart.items
            .where((item) => !item.savedForLater)
            .map((item) => item.toEntity())
            .toList(growable: false),
        summary: summary.toEntity(),
        coupon: coupon?.toEntity() ?? summary.coupon?.toEntity(),
      );
}

@JsonSerializable(createToJson: true)
class ValidatedCouponModel {
  const ValidatedCouponModel({
    required this.code,
    this.couponId,
    this.discountAmount = 0,
  });

  factory ValidatedCouponModel.fromJson(Map<String, dynamic> json) =>
      _$ValidatedCouponModelFromJson(json);

  final String code;

  @JsonKey(fromJson: _readId, toJson: _writeId)
  final String? couponId;

  @JsonKey(fromJson: _readNum)
  final double discountAmount;

  Map<String, dynamic> toJson() => _$ValidatedCouponModelToJson(this);

  AppliedCoupon toEntity() =>
      AppliedCoupon(code: code, discountAmount: discountAmount);
}

@JsonSerializable(createToJson: true)
class AvailableCouponModel {
  const AvailableCouponModel({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    this.description = '',
    this.maxDiscountAmount,
    this.minPurchaseAmount = 0,
    this.expiresAt,
    this.applicableCategories = const [],
    this.applicableBrands = const [],
    this.isApplicable = false,
    this.estimatedDiscount = 0,
    this.amountToQualify = 0,
  });

  factory AvailableCouponModel.fromJson(Map<String, dynamic> json) =>
      _$AvailableCouponModelFromJson(json);

  @JsonKey(name: '_id')
  final String id;

  final String code;
  final String description;

  final String type;

  @JsonKey(fromJson: _readNum)
  final double value;

  @JsonKey(fromJson: _readNullableNum, toJson: _writeNullableNum)
  final double? maxDiscountAmount;

  @JsonKey(fromJson: _readNum)
  final double minPurchaseAmount;

  final String? expiresAt;

  @JsonKey(fromJson: _readIdList, toJson: _writeIdList)
  final List<String> applicableCategories;

  @JsonKey(fromJson: _readIdList, toJson: _writeIdList)
  final List<String> applicableBrands;

  final bool isApplicable;

  @JsonKey(fromJson: _readNum)
  final double estimatedDiscount;

  @JsonKey(fromJson: _readNum)
  final double amountToQualify;

  Map<String, dynamic> toJson() => _$AvailableCouponModelToJson(this);

  AvailableCoupon toEntity() => AvailableCoupon(
        id: id,
        code: code,
        description: description,
        type: CouponType.parse(type),
        value: value,
        maxDiscountAmount: maxDiscountAmount,
        minPurchaseAmount: minPurchaseAmount,
        expiresAt: _parseDate(expiresAt),
        applicableCategories: applicableCategories,
        applicableBrands: applicableBrands,
        isApplicable: isApplicable,
        estimatedDiscount: estimatedDiscount,
        amountToQualify: amountToQualify,
      );
}

@JsonSerializable(createToJson: true)
class CouponPreviewModel {
  const CouponPreviewModel({
    required this.code,
    required this.type,
    required this.value,
    this.description = '',
    this.estimatedDiscount = 0,
  });

  factory CouponPreviewModel.fromJson(Map<String, dynamic> json) =>
      _$CouponPreviewModelFromJson(json);

  final String code;
  final String description;
  final String type;

  @JsonKey(fromJson: _readNum)
  final double value;

  @JsonKey(fromJson: _readNum)
  final double estimatedDiscount;

  Map<String, dynamic> toJson() => _$CouponPreviewModelToJson(this);

  CouponPreview toEntity() => CouponPreview(
        code: code,
        description: description,
        type: CouponType.parse(type),
        value: value,
        estimatedDiscount: estimatedDiscount,
      );
}

@JsonSerializable(createFactory: false, includeIfNull: false)
class ValidateCouponRequest {
  const ValidateCouponRequest({required this.code, this.subtotal});

  final String code;
  final double? subtotal;

  Map<String, dynamic> toJson() => _$ValidateCouponRequestToJson(this);
}

@JsonSerializable(createFactory: false, includeIfNull: false)
class AddressRequest {
  const AddressRequest({
    this.label,
    this.type,
    this.fullName,
    this.phone,
    this.street,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.landmark,
    this.isDefault,
  });

  final String? label;
  final String? type;
  final String? fullName;
  final String? phone;

  final String? street;

  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? landmark;
  final bool? isDefault;

  Map<String, dynamic> toJson() => _$AddressRequestToJson(this);
}
