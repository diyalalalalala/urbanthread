import 'package:equatable/equatable.dart';

import '../../../cart/domain/entities/cart_snapshot.dart';
import 'wishlist.dart';

/// The result of `POST /wishlist/{productId}/move-to-cart`.
///
/// The endpoint answers `data = { cart, wishlist }` where `cart` is itself the
/// full `{cart, notices, summary}` triple — so the totals live at
/// `data.cart.summary`, one level deeper than every other cart response. Both
/// halves are returned because both changed: the item left the wishlist and
/// joined the cart, and refetching either would waste a round trip.
///
/// This is also the one place the wishlist depends on the cart. That is the
/// API's shape, not a design choice — the dependency runs one way and the cart
/// knows nothing of the wishlist.
class WishlistMoveResult extends Equatable {
  const WishlistMoveResult({required this.cart, required this.wishlist});

  /// Quantity is hard-coded to 1 by the server; there is no way to move two.
  final CartSnapshot cart;

  final Wishlist wishlist;

  @override
  List<Object?> get props => [cart, wishlist];
}
