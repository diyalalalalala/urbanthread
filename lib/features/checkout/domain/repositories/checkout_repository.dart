import '../../../../core/domain/result.dart';
import '../entities/checkout_cart.dart';
import '../entities/coupon.dart';

abstract interface class CheckoutRepository {
  Future<Result<CheckoutCart>> validateCart();

  Future<Result<CartSummary>> getCartSummary();

  Future<Result<List<AvailableCoupon>>> getAvailableCoupons(double subtotal);

  Future<Result<CouponPreview>> validateCoupon({
    required String code,
    double? subtotal,
  });
}
