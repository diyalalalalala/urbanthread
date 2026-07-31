import 'package:equatable/equatable.dart';

import 'cart.dart';

class CartSummaryCoupon extends Equatable {
  const CartSummaryCoupon({
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

  const CartSummary.empty() : this();

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

  final CartSummaryCoupon? coupon;

  bool get isEmpty => itemCount == 0;

  double get freeShippingProgress {
    if (freeShippingEligible || amountToFreeShipping <= 0) return 1;
    final target = subtotal + amountToFreeShipping;
    if (target <= 0) return 0;
    return (subtotal / target).clamp(0.0, 1.0);
  }

  bool get hasRejectedCoupon => coupon != null && !coupon!.valid;

  static const _taxRate = 0.13;
  static const _shippingFlatRate = 150.0;
  static const _freeShippingThreshold = 5000.0;

  CartSummary estimate(Cart cart) {
    final active = cart.activeItems;
    final newSubtotal = _round(
      active.fold<double>(0, (sum, item) => sum + item.lineTotal),
    );

    final carriedDiscount =
        discount > newSubtotal ? newSubtotal : discount;

    final taxable = newSubtotal - carriedDiscount;
    final newTax = _round((taxable < 0 ? 0 : taxable) * _taxRate);
    final newShipping =
        newSubtotal <= 0 || newSubtotal >= _freeShippingThreshold
            ? 0.0
            : _shippingFlatRate;

    return CartSummary(
      subtotal: newSubtotal,
      discount: carriedDiscount,
      tax: newTax,
      shipping: newShipping,
      grandTotal:
          _round(newSubtotal - carriedDiscount + newTax + newShipping),
      currency: currency,
      itemCount: active.fold(0, (sum, item) => sum + item.quantity),
      savedForLaterCount: cart.savedItems.length,
      freeShippingEligible: newShipping == 0 && newSubtotal > 0,
      amountToFreeShipping:
          newSubtotal > 0 && newSubtotal < _freeShippingThreshold
              ? _round(_freeShippingThreshold - newSubtotal)
              : 0,
      coupon: coupon,
    );
  }

  static double _round(double value) => (value * 100).roundToDouble() / 100;

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
