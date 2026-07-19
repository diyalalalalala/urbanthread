import '../../../../core/domain/result.dart';
import '../entities/checkout_cart.dart';
import '../entities/coupon.dart';

/// What checkout needs to know about the basket and its discounts.
///
/// The cart *feature* owns cart mutation — adding, removing, changing
/// quantities. This interface is deliberately read-only over the same data:
/// checkout needs the lines and totals to render a review step, and needs the
/// server's verdict on whether the basket can be ordered at all. Reaching
/// into the cart feature for that would couple two independently-built parts
/// of the app for the sake of two GETs.
abstract interface class CheckoutRepository {
  /// The gate before placing an order.
  ///
  /// Succeeds only when nothing blocks checkout. A blocked cart is a
  /// [ValidationFailure] whose `errors` list holds **every** problem at once
  /// — an empty basket, one entry per stock shortfall, an expired coupon —
  /// because sending the customer round the loop once per issue is worse than
  /// showing them all.
  Future<Result<CheckoutCart>> validateCart();

  /// Totals only, for a lighter refresh after applying a coupon.
  Future<Result<CartSummary>> getCartSummary();

  /// Coupons this account may still use, scored against [subtotal].
  Future<Result<List<AvailableCoupon>>> getAvailableCoupons(double subtotal);

  /// Checks a hand-typed code before it is attached to the order.
  ///
  /// The preview it returns is advisory — the discount actually applied is
  /// recomputed server-side from the cart's own subtotal when the order is
  /// placed.
  Future<Result<CouponPreview>> validateCoupon({
    required String code,
    double? subtotal,
  });
}
