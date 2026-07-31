import 'package:equatable/equatable.dart';

import '../../../cart/domain/entities/cart_snapshot.dart';
import 'wishlist.dart';

class WishlistMoveResult extends Equatable {
  const WishlistMoveResult({required this.cart, required this.wishlist});

  final CartSnapshot cart;

  final Wishlist wishlist;

  @override
  List<Object?> get props => [cart, wishlist];
}
