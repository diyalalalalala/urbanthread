import 'package:equatable/equatable.dart';

import 'cart.dart';

/// The coupon block inside a summary.
///
/// Separate from [CartCoupon] because it answers a different question: the
/// cart stores *which* code is attached, this reports whether it still
/// validates. The server re-checks on every read, so a code that expired
/// while the cart sat idle comes back `valid: false` with a reason instead of
/// silently continuing to discount.
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

  /// Why it stopped applying. Null while valid.
  final String? message;

  @override
  List<Object?> get props => [code, discountAmount, valid, message];
}

/// Server-calculated money for the cart.
///
/// Every figure here is authoritative — the backend recomputes it at checkout
/// and charges what *it* derives, never what the client sends. The client-side
/// [estimate] below exists only to keep an optimistic frame coherent for the
/// few hundred milliseconds before the real numbers land.
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

  /// The payable total. The API calls it `grandTotal` — there is no `total`
  /// key anywhere in this backend.
  final double grandTotal;

  final String currency;

  /// Units across active lines. Excludes saved-for-later.
  final int itemCount;
  final int savedForLaterCount;

  final bool freeShippingEligible;

  /// How much more is needed to cross the free-shipping threshold. Zero when
  /// already eligible or when the cart is empty.
  final double amountToFreeShipping;

  final CartSummaryCoupon? coupon;

  bool get isEmpty => itemCount == 0;

  /// Fraction of the way to free shipping, for the progress bar. Clamped, so
  /// a cart well past the threshold does not overflow the track.
  double get freeShippingProgress {
    if (freeShippingEligible || amountToFreeShipping <= 0) return 1;
    final target = subtotal + amountToFreeShipping;
    if (target <= 0) return 0;
    return (subtotal / target).clamp(0.0, 1.0);
  }

  /// True when a code is attached but no longer applies — the case the UI has
  /// to explain rather than quietly ignore.
  bool get hasRejectedCoupon => coupon != null && !coupon!.valid;

  // The backend's business constants (`config.business`, from `env.js`
  // defaults). Mirrored here *only* for the optimistic estimate below; the
  // server's own numbers replace them the moment a response arrives.
  static const _taxRate = 0.13;
  static const _shippingFlatRate = 150.0;
  static const _freeShippingThreshold = 5000.0;

  /// A locally recomputed summary for an optimistic UI frame.
  ///
  /// Quantity steppers must move the total immediately or they feel broken,
  /// but the real total can only come from the server — every mutating cart
  /// endpoint returns a fresh summary precisely so the client never has to
  /// price anything. So this replays the server's arithmetic on the lines we
  /// already hold and carries the *previous* discount forward untouched:
  /// coupon rules (minimum spend, per-product eligibility, usage limits) are
  /// not knowable on the device, and guessing at them would show a number the
  /// server then contradicts.
  CartSummary estimate(Cart cart) {
    final active = cart.activeItems;
    final newSubtotal = _round(
      active.fold<double>(0, (sum, item) => sum + item.lineTotal),
    );

    // Carry the discount, but never let it exceed the new subtotal — halving
    // a cart must not produce a negative taxable amount.
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
