import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_wishlist_save.g.dart';

/// A save that was asked for while signed out, held until the sign-in returns.
///
/// The whole `/wishlist` API sits behind `authenticate`, so tapping the heart
/// as a guest cannot do anything on its own. Sending the customer to log in
/// and then dropping what they asked for is the sort of thing that reads as
/// the button being broken, so the product id is parked here and replayed on
/// the way back.
///
/// It has to survive the trip, and the trip is destructive: the login screen
/// finishes with `context.go(redirect)`, which replaces the navigation stack —
/// the product page that comes back is a *new* widget with no memory of the
/// tap. So this is deliberately kept outside the page, and `keepAlive` because
/// an auto-disposed provider would be collected during the detour and take the
/// intent with it.
///
/// Holds one id, not a queue: this exists to carry a single tap across one
/// redirect, and a guest cannot accumulate more than that.
@Riverpod(keepAlive: true)
class PendingWishlistSave extends _$PendingWishlistSave {
  @override
  String? build() => null;

  /// Records that [productId] should be saved once there is a session.
  void remember(String productId) => state = productId;

  /// Consumes the intent, returning true when it was for [productId].
  ///
  /// Clearing as part of the read is what keeps the replay to exactly once —
  /// the alternative leaves an id behind that re-saves on the next visit to
  /// the same product, which looks like the app deciding for the customer.
  bool claim(String productId) {
    if (state != productId) return false;
    state = null;
    return true;
  }

  void clear() => state = null;
}
