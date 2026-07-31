import 'package:equatable/equatable.dart';

class AppliedCoupon extends Equatable {
  const AppliedCoupon({
    required this.code,
    this.discountAmount = 0,
    this.valid = true,
    this.message,
  });

  final String code;
  final double discountAmount;
  final bool valid;

  final String? message;

  @override
  List<Object?> get props => [code, discountAmount, valid, message];
}

class CartSummary extends Equatable {
  const CartSummary({
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

  const CartSummary.empty()
      : subtotal = 0,
        grandTotal = 0,
        discount = 0,
        tax = 0,
        shipping = 0,
        currency = 'NPR',
        itemCount = 0,
        savedForLaterCount = 0,
        freeShippingEligible = false,
        amountToFreeShipping = 0,
        coupon = null;

  final double subtotal;
  final double discount;
  final double tax;
  final double shipping;

  final double grandTotal;

  final String currency;

  final int itemCount;

  final int savedForLaterCount;
  final bool freeShippingEligible;

  final double amountToFreeShipping;

  final AppliedCoupon? coupon;

  bool get isEmpty => itemCount == 0;

  bool get hasDiscount => discount > 0;

  bool get hasBrokenCoupon => coupon != null && !coupon!.valid;

  bool get willMockGatewayDecline => grandTotal.floor() % 10 == 7;

  @override
  List<Object?> get props => [
        subtotal,
        discount,
        tax,
        shipping,
        grandTotal,
        currency,
        itemCount,
        savedForLaterCount,
        freeShippingEligible,
        amountToFreeShipping,
        coupon,
      ];
}

class CheckoutLine extends Equatable {
  const CheckoutLine({
    required this.itemId,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.variantId = '',
    this.image,
    this.sku = '',
    this.color = '',
    this.size = '',
  });

  final String itemId;
  final String productId;
  final String variantId;
  final String name;
  final String? image;
  final String sku;
  final String color;
  final String size;
  final int quantity;
  final double unitPrice;

  double get lineTotal => unitPrice * quantity;

  String? get variantLabel {
    final parts = [
      if (color.isNotEmpty) color,
      if (size.isNotEmpty) size,
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  @override
  List<Object?> get props => [
        itemId,
        productId,
        variantId,
        name,
        image,
        sku,
        color,
        size,
        quantity,
        unitPrice,
      ];
}

class CheckoutCart extends Equatable {
  const CheckoutCart({
    required this.lines,
    required this.summary,
    this.coupon,
  });

  final List<CheckoutLine> lines;
  final CartSummary summary;
  final AppliedCoupon? coupon;

  bool get isEmpty => lines.isEmpty;

  @override
  List<Object?> get props => [lines, summary, coupon];
}
