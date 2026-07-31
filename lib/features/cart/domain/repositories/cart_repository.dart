import '../../../../core/domain/result.dart';
import '../entities/cart_snapshot.dart';
import '../entities/cart_summary.dart';
import '../entities/cart_validation.dart';

abstract interface class CartRepository {
  Future<Result<CartSnapshot>> getCart();

  CartSnapshot? get cachedCart;

  Future<Result<CartSummary>> getSummary();

  Future<Result<CartValidation>> validate();

  Future<Result<CartSnapshot>> addItem({
    required String productId,
    required String variantId,
    int quantity,
  });

  Future<Result<CartSnapshot>> updateQuantity({
    required String itemId,
    required int quantity,
  });

  Future<Result<CartSnapshot>> removeItem(String itemId);

  Future<Result<CartSnapshot>> saveForLater(String itemId);

  Future<Result<CartSnapshot>> moveToCart(String itemId);

  Future<Result<CartSnapshot>> applyCoupon(String code);

  Future<Result<CartSnapshot>> removeCoupon();

  Future<Result<CartSnapshot>> clearCart();

  Future<Result<CartSnapshot>> syncPendingWrites();

  int get pendingWriteCount;
}
