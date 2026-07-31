import 'package:equatable/equatable.dart';

enum CouponType {
  percentage,
  fixed;

  static CouponType parse(String? raw) =>
      raw?.toLowerCase() == 'fixed' ? CouponType.fixed : CouponType.percentage;

  String get wireValue => name;
}

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

  final double value;

  final double? maxDiscountAmount;

  final double minPurchaseAmount;
  final DateTime? expiresAt;

  final List<String> applicableCategories;
  final List<String> applicableBrands;

  final bool isApplicable;

  final double estimatedDiscount;

  final double amountToQualify;

  bool get isRestricted =>
      applicableCategories.isNotEmpty || applicableBrands.isNotEmpty;

  bool get hasExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

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

  final double estimatedDiscount;

  @override
  List<Object?> get props =>
      [code, description, type, value, estimatedDiscount];
}
