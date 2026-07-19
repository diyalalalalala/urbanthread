import 'package:equatable/equatable.dart';

/// The coupon currently attached to the cart, as the server re-evaluates it.
///
/// Re-validated on every summary calculation rather than trusted from the
/// stored `discountAmount` — a code can expire or hit its usage limit while
/// it sits on an idle cart. When that happens the discount drops to zero and
/// [valid] goes false with a [message] explaining it, instead of the cart
/// quietly honouring a dead code.
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

  /// Why it was rejected. Null while [valid].
  final String? message;

  @override
  List<Object?> get props => [code, discountAmount, valid, message];
}

/// The authoritative money for the cart, computed server-side.
///
/// Nothing here is ever sent back. Checkout recomputes all of it from live
/// prices inside the order transaction, and `POST /orders` rejects any
/// request carrying a pricing field. These figures exist to *show* the
/// customer what they will pay, not to tell the server what to charge.
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

  /// The total. Spelled `grandTotal` everywhere in this API — there is no
  /// `total` key.
  final double grandTotal;

  final String currency;

  /// Units in the cart, excluding anything saved for later.
  final int itemCount;

  final int savedForLaterCount;
  final bool freeShippingEligible;

  /// How much more to spend to reach free shipping; zero once eligible.
  final double amountToFreeShipping;

  final AppliedCoupon? coupon;

  bool get isEmpty => itemCount == 0;

  bool get hasDiscount => discount > 0;

  /// A coupon is attached but the server has just rejected it. Checkout is
  /// blocked until it is removed or replaced.
  bool get hasBrokenCoupon => coupon != null && !coupon!.valid;

  /// Whether the mock gateway will refuse this total.
  ///
  /// The mock provider is deterministic rather than random, so the failure
  /// path is reproducible in a demo: it declines when **the integer part of
  /// the grand total ends in 7**. Knowing that up front lets checkout warn
  /// before the customer commits, rather than letting them discover it as a
  /// rolled-back order — but it is only a prediction. The binding total is
  /// the one the server derives from live prices inside the transaction, so
  /// this may differ, and the 422 still has to be handled.
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

/// One line of the cart, as checkout needs to render it.
///
/// Read from the cart's `snapshot` block — the nesting orders do not have.
/// Only what the review step displays is carried; checkout never posts these,
/// because the server reads the cart itself.
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

/// What `GET /cart/validate` returns when the cart *can* be checked out.
///
/// The endpoint is a gate, not a quote: it answers 200 with this only if
/// nothing blocks the order. Otherwise it answers 422 listing **every**
/// blocker at once — empty cart, each stock shortfall, an invalid coupon —
/// so the customer fixes them in one pass instead of discovering them one
/// failed checkout at a time.
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
