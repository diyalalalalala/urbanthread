import 'package:equatable/equatable.dart';

import 'cart.dart';
import 'cart_notice.dart';
import 'cart_summary.dart';

class CartSnapshot extends Equatable {
  const CartSnapshot({
    required this.cart,
    this.notices = const [],
    this.summary = const CartSummary.empty(),
  });

  const CartSnapshot.empty()
      : this(cart: const Cart.empty(), summary: const CartSummary.empty());

  final Cart cart;

  final List<CartNotice> notices;

  final CartSummary summary;

  List<CartItem> get activeItems => cart.activeItems;
  List<CartItem> get savedItems => cart.savedItems;

  bool get isEmpty => cart.isEmpty;

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

  CartSnapshot withOptimisticCart(Cart updated) => CartSnapshot(
        cart: updated,
        summary: summary.estimate(updated),
      );

  @override
  List<Object?> get props => [cart, notices, summary];
}
