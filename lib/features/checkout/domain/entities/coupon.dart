import 'package:equatable/equatable.dart';

/// How a coupon reduces the subtotal.
///
/// The wire field is **`type`**, not `discountType`. Reading the latter
/// yields null and every coupon silently becomes a fixed-amount one.
enum CouponType {
  percentage,
  fixed;

  static CouponType parse(String? raw) =>
      raw?.toLowerCase() == 'fixed' ? CouponType.fixed : CouponType.percentage;

  String get wireValue => name;
}

/// A coupon the signed-in customer could use, from
/// `GET /coupons/available?subtotal=`.
///
/// The list is already filtered to codes this account has not exhausted, so
/// everything here is redeemable in principle — [isApplicable] then says
/// whether it applies to *this* basket, which is a question about the
/// subtotal rather than about eligibility.
class AvailableCoupon extends Equatable {
  const AvailableCoupon({
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

  final String id;
  final String code;
  final String description;
  final CouponType type;

  /// A percentage when [type] is [CouponType.percentage], otherwise rupees.
  final double value;

  /// Ceiling on a percentage discount. Null when uncapped.
  final double? maxDiscountAmount;

  final double minPurchaseAmount;
  final DateTime? expiresAt;

  /// When non-empty, the coupon only touches lines in these categories.
  final List<String> applicableCategories;
  final List<String> applicableBrands;

  /// Whether the basket already meets [minPurchaseAmount].
  final bool isApplicable;

  /// What it would take off, against the subtotal that was queried.
  ///
  /// An estimate only. A restricted coupon applies to a subset of lines, and
  /// the binding figure is the one the cart summary computes — which is why
  /// applying a coupon refreshes the summary rather than subtracting this.
  final double estimatedDiscount;

  /// How much more to spend before it applies; zero once [isApplicable].
  final double amountToQualify;

  bool get isRestricted =>
      applicableCategories.isNotEmpty || applicableBrands.isNotEmpty;

  bool get hasExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  /// `20% off` / `Rs 500 off`, for the coupon tile's headline.
  String get valueLabel => switch (type) {
        CouponType.percentage => '${value.toStringAsFixed(0)}% off',
        CouponType.fixed => 'Rs ${value.toStringAsFixed(0)} off',
      };

  @override
  List<Object?> get props => [
        id,
        code,
        description,
        type,
        value,
        maxDiscountAmount,
        minPurchaseAmount,
        expiresAt,
        applicableCategories,
        applicableBrands,
        isApplicable,
        estimatedDiscount,
        amountToQualify,
      ];
}

/// The answer to `POST /coupons/validate` — a narrower shape than
/// [AvailableCoupon], carrying only what a "does this code work?" check needs.
class CouponPreview extends Equatable {
  const CouponPreview({
    required this.code,
    required this.type,
    required this.value,
    this.description = '',
    this.estimatedDiscount = 0,
  });

  final String code;
  final String description;
  final CouponType type;
  final double value;

  /// Preview against the subtotal that was sent. The cart summary's figure
  /// wins once the code is actually applied.
  final double estimatedDiscount;

  @override
  List<Object?> get props =>
      [code, description, type, value, estimatedDiscount];
}
