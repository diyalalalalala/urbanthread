import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_wishlist_save.g.dart';

@Riverpod(keepAlive: true)
class PendingWishlistSave extends _$PendingWishlistSave {
  @override
  String? build() => null;

  void remember(String productId) => state = productId;

  bool claim(String productId) {
    if (state != productId) return false;
    state = null;
    return true;
  }

  void clear() => state = null;
}
