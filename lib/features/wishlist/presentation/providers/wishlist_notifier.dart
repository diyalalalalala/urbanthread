import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../cart/presentation/providers/cart_notifier.dart';
import '../../domain/entities/wishlist.dart';
import '../../domain/usecases/add_to_wishlist_usecase.dart';
import '../../domain/usecases/move_wishlist_item_to_cart_usecase.dart';
import 'wishlist_providers.dart';
import 'wishlist_state.dart';

part 'wishlist_notifier.g.dart';

/// The wishlist, and the only thing allowed to change it.
///
/// Kept alive so the saved-items badge and every heart button in the app read
/// one source of truth. Removals are optimistic — the card leaves the grid on
/// tap and comes back if the server refuses — because a heart that waits on a
/// round trip before filling is the single most obvious lag in a storefront.
@Riverpod(keepAlive: true)
class WishlistNotifier extends _$WishlistNotifier {
  @override
  WishlistState build() {
    final repository = ref.watch(wishlistRepositoryProvider);

    ref.listen(connectionStatusProvider, (previous, next) {
      final isOnline = next.valueOrNull ?? false;
      final wasOnline = previous?.valueOrNull ?? false;
      if (isOnline && !wasOnline) unawaited(sync());
    });

    final cached = repository.cachedWishlist;
    unawaited(_load(silent: cached != null));

    return WishlistState(
      wishlist: cached,
      isLoading: cached == null,
      pendingWrites: repository.pendingWriteCount,
    );
  }

  Future<void> refresh() => _load(silent: state.wishlist != null);

  Future<void> _load({bool silent = false}) async {
    if (!silent) state = state.copyWith(isLoading: true, clearFailure: true);

    final result = await ref.read(getWishlistUseCaseProvider)(const NoParams());

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          wishlist: value,
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

  Future<void> sync() async {
    if (state.isSyncing || !state.hasPendingWrites) return;

    state = state.copyWith(isSyncing: true, clearFailure: true);
    final result = await ref.read(syncWishlistUseCaseProvider)(
      const NoParams(),
    );

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          wishlist: value,
          isSyncing: false,
          pendingWrites: _pendingWrites,
        );
      case FailureResult():
        // Still unreachable; the queue is intact and the offline banner is
        // already saying everything there is to say.
        state = state.copyWith(
          isSyncing: false,
          pendingWrites: _pendingWrites,
        );
    }
  }

  // ── Mutations ──────────────────────────────────────────────────────────

  /// Saves a product. Idempotent server-side, so a double-tap is harmless.
  Future<bool> add({required String productId, String? variantId}) async {
    if (state.isBusy(productId)) return false;
    _markBusy(productId);

    final result = await ref.read(addToWishlistUseCaseProvider)(
      AddToWishlistParams(productId: productId, variantId: variantId),
    );

    return _settle(result, productId, successMessage: 'Saved to your wishlist.');
  }

  /// Removes a product, optimistically.
  Future<bool> remove(String productId) async {
    final current = state.wishlist;
    if (current == null || state.isBusy(productId)) return false;

    state = state.copyWith(
      wishlist: current.without(productId),
      busyProductIds: {...state.busyProductIds, productId},
      clearFailure: true,
      clearMessage: true,
    );

    final result = await ref.read(removeFromWishlistUseCaseProvider)(productId);
    return _settle(
      result,
      productId,
      rollbackTo: current,
      successMessage: 'Removed from your wishlist.',
    );
  }

  /// The heart button's action: saves if not saved, removes if it is.
  ///
  /// Decided from local state rather than by asking `/wishlist/{id}/check`
  /// first — a tap must act immediately, and both directions are safe to get
  /// wrong: adding twice is a no-op, and removing something already gone is a
  /// 404 the queue discards.
  Future<bool> toggle({required String productId, String? variantId}) {
    final saved = state.wishlist?.contains(productId) ?? false;
    return saved
        ? remove(productId)
        : add(productId: productId, variantId: variantId);
  }

  /// Empties the wishlist.
  Future<void> clear() async {
    final current = state.wishlist;
    if (current == null || current.isEmpty) return;

    state = state.copyWith(
      wishlist: const Wishlist.empty(),
      clearFailure: true,
    );

    final result = await ref.read(clearWishlistUseCaseProvider)(
      const NoParams(),
    );

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          wishlist: value,
          pendingWrites: _pendingWrites,
          message: 'Wishlist cleared.',
        );
      case FailureResult(:final failure):
        state = state.copyWith(
          wishlist: current,
          failure: failure,
          message: failure.message,
          pendingWrites: _pendingWrites,
        );
    }
  }

  /// Buys one of a saved product and unsaves it.
  ///
  /// The response carries the cart as well, so the cart's state is updated
  /// from it directly — the badge and the cart page are correct the instant
  /// this returns, with no second request.
  Future<bool> moveToCart({
    required String productId,
    String? variantId,
  }) async {
    final current = state.wishlist;
    if (current == null || state.isBusy(productId)) return false;

    // Not optimistic. Move-to-cart can fail on stock, and the server adds to
    // the cart *before* unsaving precisely so a failure leaves the item
    // saved — removing the card first would contradict that guarantee.
    _markBusy(productId);

    final result = await ref.read(moveWishlistItemToCartUseCaseProvider)(
      MoveWishlistItemToCartParams(
        productId: productId,
        variantId: variantId,
      ),
    );

    switch (result) {
      case Success(:final value):
        ref.read(cartProvider.notifier).adoptSnapshot(value.cart);
        state = state.copyWith(
          wishlist: value.wishlist,
          busyProductIds: _released(productId),
          pendingWrites: _pendingWrites,
          message: 'Moved to your cart.',
        );
        return true;
      case FailureResult(:final failure):
        state = state.copyWith(
          busyProductIds: _released(productId),
          failure: failure,
          message: failure.message,
          pendingWrites: _pendingWrites,
        );
        return false;
    }
  }

  /// Drops the one-shot snack-bar line once it has been shown.
  void consumeMessage() => state = state.copyWith(clearMessage: true);

  // ── Plumbing ───────────────────────────────────────────────────────────

  int get _pendingWrites =>
      ref.read(wishlistRepositoryProvider).pendingWriteCount;

  void _markBusy(String productId) {
    state = state.copyWith(
      busyProductIds: {...state.busyProductIds, productId},
      clearFailure: true,
      clearMessage: true,
    );
  }

  Set<String> _released(String productId) =>
      <String>{...state.busyProductIds}..remove(productId);

  bool _settle(
    Result<Wishlist> result,
    String productId, {
    Wishlist? rollbackTo,
    String? successMessage,
  }) {
    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          wishlist: value,
          busyProductIds: _released(productId),
          pendingWrites: _pendingWrites,
          // An offline write is recorded rather than applied, so say so
          // instead of claiming it reached the server.
          message: _pendingWrites > 0
              ? 'Saved on this device — it will sync when you are online.'
              : successMessage,
        );
        return true;
      case FailureResult(:final failure):
        state = state.copyWith(
          wishlist: rollbackTo,
          busyProductIds: _released(productId),
          failure: failure,
          message: failure.message,
          pendingWrites: _pendingWrites,
        );
        return false;
    }
  }
}

/// Saved-item count, for the bottom-nav badge.
///
/// Derived rather than `.select`-ed — `.select` is unavailable on a generated
/// notifier provider in Riverpod 3, and this only re-emits when the number
/// itself changes.
@Riverpod(keepAlive: true)
int wishlistCount(Ref ref) => ref.watch(wishlistProvider).itemCount;

/// Whether a product is saved, for a heart button anywhere in the app.
///
/// Answers from the loaded wishlist, which is kept alive and cached — so a
/// product card does not pay a `/wishlist/{id}/check` round trip per tile.
@riverpod
bool isWishlisted(Ref ref, String productId) =>
    ref.watch(wishlistProvider).wishlist?.contains(productId) ?? false;
