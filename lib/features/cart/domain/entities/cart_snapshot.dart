import 'package:equatable/equatable.dart';

import 'cart.dart';
import 'cart_notice.dart';
import 'cart_summary.dart';

/// The `{ cart, notices, summary }` triple every cart endpoint answers with.
///
/// Modelled as one value rather than three because the API never returns them
/// apart on a mutation: `POST /cart/items`, `PATCH`, `DELETE`, the coupon
/// routes and both save-for-later directions all return the complete triple.
/// Treating it as a single state replacement is what makes refetching after a
/// write unnecessary — and refetching would be worse than redundant, since the
/// notices are regenerated per read and a second read would discard the ones
/// the write just produced.
class CartSnapshot extends Equatable {
  const CartSnapshot({
    required this.cart,
    this.notices = const [],
    this.summary = const CartSummary.empty(),
  });

  /// What an account with no cart yet looks like. Also the fallback when the
  /// device is offline and nothing has ever been cached.
  const CartSnapshot.empty()
      : this(cart: const Cart.empty(), summary: const CartSummary.empty());

  final Cart cart;

  /// Server-side reconciliation messages for *this* read. See [CartNotice].
  final List<CartNotice> notices;

  final CartSummary summary;

  List<CartItem> get activeItems => cart.activeItems;
  List<CartItem> get savedItems => cart.savedItems;

  bool get isEmpty => cart.isEmpty;

  /// Units in the cart. Prefers the server's count and falls back to the
  /// cart's own tally — `GET /cart/summary` is the only endpoint that returns
  /// a count without a cart, and an optimistic frame is the reverse.
  int get itemCount =>
      summary.itemCount > 0 ? summary.itemCount : cart.itemCount;

  CartNotice? noticeForItem(String itemId) {
    for (final notice in notices) {
      if (notice.itemId == itemId) return notice;
    }
    return null;
  }

  CartSnapshot copyWith({
    Cart? cart,
    List<CartNotice>? notices,
    CartSummary? summary,
  }) =>
      CartSnapshot(
        cart: cart ?? this.cart,
        notices: notices ?? this.notices,
        summary: summary ?? this.summary,
      );

  /// Applies a local change to the cart and re-derives an estimated summary,
  /// dropping the notices.
  ///
  /// Notices are cleared on purpose: they describe the server's last read, and
  /// keeping them beside optimistically-edited lines would tell the customer
  /// that a line they just changed was reduced by the server, which is not
  /// what happened.
  CartSnapshot withOptimisticCart(Cart updated) => CartSnapshot(
        cart: updated,
        summary: summary.estimate(updated),
      );

  @override
  List<Object?> get props => [cart, notices, summary];
}
