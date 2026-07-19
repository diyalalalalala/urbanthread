import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_snapshot.dart';
import '../../domain/entities/cart_validation.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/update_cart_item_quantity_usecase.dart';
import 'cart_providers.dart';
import 'cart_state.dart';

part 'cart_notifier.g.dart';

/// The cart, and the only thing allowed to change it.
///
/// Kept alive for the app's lifetime: the bottom-nav badge reads it from every
/// tab, and letting it dispose when the cart page closes would drop the badge
/// to zero and re-fetch on the next visit.
///
/// Mutations are optimistic. The previous snapshot is captured before the
/// request, the change is applied locally, and the captured copy is restored
/// if the server disagrees — a stepper that waits on a round trip before
/// moving feels broken, and the rollback is what makes that safe.
@Riverpod(keepAlive: true)
class CartNotifier extends _$CartNotifier {
  @override
  CartState build() {
    final repository = ref.watch(cartRepositoryProvider);

    // Connectivity returning is the trigger to flush anything queued offline.
    // Watched rather than polled so a write made in a lift reaches the server
    // as soon as the doors open, without the customer revisiting the cart.
    ref.listen(connectionStatusProvider, (previous, next) {
      final isOnline = next.value ?? false;
      final wasOnline = previous?.value ?? false;
      if (isOnline && !wasOnline) unawaited(sync());
    });

    // Paint from disk first. The cart is cached precisely so it renders
    // without a connection, and a spinner over data we already hold would be
    // a downgrade.
    final cached = repository.cachedCart;
    unawaited(_load(silent: cached != null));

    return CartState(
      snapshot: cached,
      isLoading: cached == null,
      pendingWrites: repository.pendingWriteCount,
    );
  }

  /// Re-reads the cart from the server.
  Future<void> refresh() => _load(silent: state.snapshot != null);

  Future<void> _load({bool silent = false}) async {
    if (!silent) state = state.copyWith(isLoading: true, clearFailure: true);

    final result = await ref.read(getCartUseCaseProvider)(const NoParams());

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          snapshot: value,
          isLoading: false,
          clearFailure: true,
          pendingWrites: _pendingWrites,
        );
      case FailureResult(:final failure):
        state = state.copyWith(
          isLoading: false,
          failure: failure,
          pendingWrites: _pendingWrites,
        );
    }
  }

  /// Replays queued offline writes, then reconciles with the server.
  Future<void> sync() async {
    if (state.isSyncing || !state.hasPendingWrites) return;

    state = state.copyWith(isSyncing: true, clearFailure: true);
    final result = await ref.read(syncCartUseCaseProvider)(const NoParams());

    switch (result) {
      case Success(:final value):
        final remaining = _pendingWrites;
        state = state.copyWith(
          snapshot: value,
          isSyncing: false,
          pendingWrites: remaining,
          // Say so explicitly. A cart that silently changes shape the moment
          // the signal returns is more alarming than one that explains itself.
          message: remaining == 0
              ? 'Your offline changes have been saved.'
              : 'Some offline changes could not be saved.',
        );
      case FailureResult():
        // Still unreachable. The queue is intact; nothing to tell the user
        // that the offline banner is not already saying.
        state = state.copyWith(
          isSyncing: false,
          pendingWrites: _pendingWrites,
        );
    }
  }

  // ── Mutations ──────────────────────────────────────────────────────────

  /// Adds a variant to the cart.
  ///
  /// This is the entry point for the rest of the app — product detail, product
  /// cards, "buy it again". Returns whether the server accepted it, so the
  /// caller can navigate or animate on success without re-reading state.
  Future<bool> addItem({
    required String productId,
    required String variantId,
    int quantity = 1,
  }) async {
    state = state.copyWith(clearFailure: true, clearMessage: true);

    final result = await ref.read(addToCartUseCaseProvider)(
      AddToCartParams(
        productId: productId,
        variantId: variantId,
        quantity: quantity,
      ),
    );

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          snapshot: value,
          pendingWrites: _pendingWrites,
          message: _pendingWrites > 0
              ? 'Saved. It will be added to your cart when you are back online.'
              : 'Added to your cart.',
        );
        return true;
      case FailureResult(:final failure):
        state = state.copyWith(
          failure: failure,
          message: failure.message,
          pendingWrites: _pendingWrites,
        );
        return false;
    }
  }

  /// Sets a line to an absolute quantity, optimistically.
  ///
  /// Dropping to zero is treated as a removal, which is what the stepper's
  /// minus button implies at 1 — the API would reject `quantity: 0` outright.
  Future<void> setQuantity(String itemId, int quantity) async {
    final current = state.snapshot;
    if (current == null || state.isItemBusy(itemId)) return;

    final item = current.cart.itemById(itemId);
    if (item == null || item.quantity == quantity) return;
    if (quantity < 1) return removeItem(itemId);

    _applyOptimistic(
      current,
      current.cart.withItem(item.copyWith(quantity: quantity)),
      itemId,
    );

    final result = await ref.read(updateCartItemQuantityUseCaseProvider)(
      UpdateCartItemQuantityParams(itemId: itemId, quantity: quantity),
    );
    _settle(result, itemId: itemId, rollbackTo: current);
  }

  Future<void> increment(String itemId) {
    final item = state.snapshot?.cart.itemById(itemId);
    if (item == null) return Future.value();
    return setQuantity(itemId, item.quantity + 1);
  }

  Future<void> decrement(String itemId) {
    final item = state.snapshot?.cart.itemById(itemId);
    if (item == null) return Future.value();
    return setQuantity(itemId, item.quantity - 1);
  }

  /// Removes a line. The row disappears immediately and comes back if the
  /// server refuses.
  Future<void> removeItem(String itemId) async {
    final current = state.snapshot;
    if (current == null || state.isItemBusy(itemId)) return;

    _applyOptimistic(current, current.cart.withoutItem(itemId), itemId);

    final result = await ref.read(removeCartItemUseCaseProvider)(itemId);
    _settle(result, itemId: itemId, rollbackTo: current);
  }

  /// Parks a line in the saved-for-later section.
  Future<void> saveForLater(String itemId) async {
    final current = state.snapshot;
    final item = current?.cart.itemById(itemId);
    if (current == null || item == null || state.isItemBusy(itemId)) return;

    _applyOptimistic(
      current,
      current.cart.withItem(item.copyWith(savedForLater: true)),
      itemId,
    );

    final result = await ref.read(saveForLaterUseCaseProvider)(itemId);
    _settle(result, itemId: itemId, rollbackTo: current);
  }

  /// Moves a saved line back into the cart.
  ///
  /// More likely to fail than saving: the server re-checks stock and refreshes
  /// the price snapshot on the way back, so an item parked months ago may no
  /// longer be available at that quantity.
  Future<void> moveToCart(String itemId) async {
    final current = state.snapshot;
    final item = current?.cart.itemById(itemId);
    if (current == null || item == null || state.isItemBusy(itemId)) return;

    _applyOptimistic(
      current,
      current.cart.withItem(item.copyWith(savedForLater: false)),
      itemId,
    );

    final result = await ref.read(moveToCartUseCaseProvider)(itemId);
    _settle(result, itemId: itemId, rollbackTo: current);
  }

  /// Applies a coupon. Returns the failure so the field can show it inline
  /// rather than only as a snack bar — a rejected code is a form error.
  Future<Failure?> applyCoupon(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return null;

    state = state.copyWith(
      isCouponBusy: true,
      clearFailure: true,
      clearMessage: true,
    );

    final result = await ref.read(applyCouponUseCaseProvider)(trimmed);

    return result.fold(
      onSuccess: (snapshot) {
        state = state.copyWith(
          snapshot: snapshot,
          isCouponBusy: false,
          // The server can accept the code and still report it as worthless —
          // the summary re-validates on every read. Say which happened.
          message: snapshot.summary.hasRejectedCoupon
              ? snapshot.summary.coupon?.message ?? 'That coupon did not apply.'
              : 'Coupon applied.',
        );
        return null;
      },
      onFailure: (failure) {
        state = state.copyWith(isCouponBusy: false, failure: failure);
        return failure;
      },
    );
  }

  Future<void> removeCoupon() async {
    state = state.copyWith(isCouponBusy: true, clearFailure: true);
    final result = await ref.read(removeCouponUseCaseProvider)(
      const NoParams(),
    );

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          snapshot: value,
          isCouponBusy: false,
          pendingWrites: _pendingWrites,
          message: 'Coupon removed.',
        );
      case FailureResult(:final failure):
        state = state.copyWith(
          isCouponBusy: false,
          failure: failure,
          message: failure.message,
        );
    }
  }

  /// Empties the cart, saved-for-later lines and coupon included.
  Future<void> clear() async {
    final current = state.snapshot;
    if (current == null) return;

    state = state.copyWith(
      snapshot: current.withOptimisticCart(const Cart.empty()),
      clearFailure: true,
    );

    final result = await ref.read(clearCartUseCaseProvider)(const NoParams());
    _settle(result, rollbackTo: current);
  }

  /// Runs the checkout gate. Returns null only when the request itself failed;
  /// an unusable cart comes back as an invalid [CartValidation], not an error.
  Future<CartValidation?> validateForCheckout() async {
    state = state.copyWith(clearFailure: true, clearMessage: true);
    final result = await ref.read(validateCartUseCaseProvider)(
      const NoParams(),
    );

    return result.fold(
      onSuccess: (validation) async {
        // Blockers usually mean the server reconciled the cart during the
        // check, so re-read to show the customer the cart the refusal is
        // about rather than the one they were looking at.
        if (!validation.isValid) await refresh();
        return validation;
      },
      onFailure: (failure) {
        state = state.copyWith(failure: failure, message: failure.message);
        return null;
      },
    );
  }

  /// Adopts a cart snapshot produced by another feature's request.
  ///
  /// `POST /wishlist/{productId}/move-to-cart` returns the complete cart
  /// triple nested inside its response, so the cart is already authoritative
  /// by the time the wishlist has finished. Re-reading `/cart` to learn what
  /// we were just told would waste a round trip and, worse, throw away the
  /// notices that response carried. The wishlist repository has already
  /// written the same snapshot to the cart's cache, so this only has to catch
  /// the in-memory state up.
  void adoptSnapshot(CartSnapshot snapshot) {
    state = state.copyWith(
      snapshot: snapshot,
      clearFailure: true,
      pendingWrites: _pendingWrites,
    );
  }

  /// Drops the one-shot snack-bar line once it has been shown.
  void consumeMessage() => state = state.copyWith(clearMessage: true);

  // ── Optimistic plumbing ────────────────────────────────────────────────

  int get _pendingWrites => ref.read(cartRepositoryProvider).pendingWriteCount;

  void _applyOptimistic(CartSnapshot current, Cart updated, String itemId) {
    state = state.copyWith(
      snapshot: current.withOptimisticCart(updated),
      busyItemIds: {...state.busyItemIds, itemId},
      clearFailure: true,
      clearMessage: true,
    );
  }

  /// Adopts the server's snapshot, or restores [rollbackTo] if it refused.
  void _settle(
    Result<CartSnapshot> result, {
    required CartSnapshot rollbackTo,
    String? itemId,
  }) {
    final released = <String>{...state.busyItemIds};
    if (itemId != null) released.remove(itemId);

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          snapshot: value,
          busyItemIds: released,
          pendingWrites: _pendingWrites,
          // Notices explain a change the customer did not make. They are the
          // only account they get of a line the server removed or capped, so
          // they are promoted to a message rather than left in the payload.
          message: value.notices.isEmpty ? null : value.notices.first.message,
        );
      case FailureResult(:final failure):
        state = state.copyWith(
          snapshot: rollbackTo,
          busyItemIds: released,
          failure: failure,
          message: failure.message,
          pendingWrites: _pendingWrites,
        );
    }
  }
}

/// Units in the cart, for the bottom-nav badge.
///
/// Kept alive and derived rather than `.select`-ed off [cartProvider] —
/// `.select` is unavailable on a generated notifier provider in Riverpod 3,
/// and a derived provider only re-emits when the count itself changes, which
/// is the same saving without the ceremony.
@Riverpod(keepAlive: true)
int cartItemCount(Ref ref) =>
    ref.watch(cartProvider).snapshot?.itemCount ?? 0;

/// The payable total, for a persistent checkout bar.
@riverpod
double cartGrandTotal(Ref ref) =>
    ref.watch(cartProvider).snapshot?.summary.grandTotal ?? 0;

/// Whether a product/variant pair is already in the cart, so a product page
/// can offer "view cart" instead of adding a second time.
@riverpod
bool isInCart(Ref ref, {required String productId, required String variantId}) {
  final cart = ref.watch(cartProvider).snapshot?.cart;
  return cart?.lineFor(productId: productId, variantId: variantId) != null;
}
