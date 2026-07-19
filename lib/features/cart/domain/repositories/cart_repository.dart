import '../../../../core/domain/result.dart';
import '../entities/cart_snapshot.dart';
import '../entities/cart_summary.dart';
import '../entities/cart_validation.dart';

/// The cart contract the domain depends on.
///
/// Every mutation answers with a whole [CartSnapshot] because the API does:
/// the server returns the reconciled cart, its notices and freshly-calculated
/// totals from every write. Callers replace state with what they get back and
/// never issue a follow-up read.
abstract interface class CartRepository {
  /// The cart as the server sees it, falling back to the cached copy when
  /// offline.
  Future<Result<CartSnapshot>> getCart();

  /// The last cart written to disk, read synchronously. Used to paint the
  /// screen and the badge at launch before the network answers.
  CartSnapshot? get cachedCart;

  /// Totals only. Cheaper than [getCart] when the lines are not needed.
  Future<Result<CartSummary>> getSummary();

  /// The checkout gate. Reports blockers as a value rather than an error —
  /// see [CartValidation].
  Future<Result<CartValidation>> validate();

  /// Adds a variant. Re-adding a line already in the cart increments it
  /// server-side rather than duplicating it.
  ///
  /// The request body is exactly `{productId, variantId, quantity?}`; sending
  /// any price field is rejected with a 422.
  Future<Result<CartSnapshot>> addItem({
    required String productId,
    required String variantId,
    int quantity,
  });

  /// Sets a line to an absolute [quantity] — this is not a delta.
  Future<Result<CartSnapshot>> updateQuantity({
    required String itemId,
    required int quantity,
  });

  Future<Result<CartSnapshot>> removeItem(String itemId);

  /// Parks a line. It stays in the same `items[]` array with
  /// `savedForLater: true`, excluded from totals and checkout.
  Future<Result<CartSnapshot>> saveForLater(String itemId);

  /// The reverse of [saveForLater]. Re-checks stock and refreshes the price
  /// snapshot, so it can fail where the save could not.
  Future<Result<CartSnapshot>> moveToCart(String itemId);

  /// Applies a code. 3–24 characters; the server uppercases it.
  Future<Result<CartSnapshot>> applyCoupon(String code);

  Future<Result<CartSnapshot>> removeCoupon();

  Future<Result<CartSnapshot>> clearCart();

  /// Replays writes queued while offline, oldest first, then re-reads the
  /// cart so local state matches the server's reconciled view.
  ///
  /// Returns the reconciled snapshot, or a failure if the device is still
  /// unreachable. Entries the server can never accept are dropped rather than
  /// retried forever; entries that failed on transport stay queued.
  Future<Result<CartSnapshot>> syncPendingWrites();

  /// How many writes are waiting to be replayed. Drives the "changes not yet
  /// saved" hint on the cart screen.
  int get pendingWriteCount;
}
