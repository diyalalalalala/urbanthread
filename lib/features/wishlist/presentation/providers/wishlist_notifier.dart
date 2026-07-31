import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../cart/presentation/providers/cart_notifier.dart';
import '../../domain/entities/wishlist.dart';
import '../../domain/usecases/add_to_wishlist_usecase.dart';
import '../../domain/usecases/move_wishlist_item_to_cart_usecase.dart';
import 'wishlist_providers.dart';
import 'wishlist_state.dart';

part 'wishlist_notifier.g.dart';

@Riverpod(keepAlive: true)
class WishlistNotifier extends _$WishlistNotifier {
  @override
  WishlistState build() {
    final repository = ref.watch(wishlistRepositoryProvider);

    ref.listen(connectionStatusProvider, (previous, next) {
      final isOnline = next.value ?? false;
      final wasOnline = previous?.value ?? false;
      if (isOnline && !wasOnline) unawaited(sync());
    });

    final cached = repository.cachedWishlist;
    unawaited(_load(silent: true));

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
        state = state.copyWith(
          isSyncing: false,
          pendingWrites: _pendingWrites,
        );
    }
  }

  Future<bool> add({required String productId, String? variantId}) async {
    if (state.isBusy(productId)) return false;
    _markBusy(productId);

    final result = await ref.read(addToWishlistUseCaseProvider)(
      AddToWishlistParams(productId: productId, variantId: variantId),
    );

    return _settle(result, productId, successMessage: 'Saved to your wishlist.');
  }

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

  Future<bool> toggle({required String productId, String? variantId}) {
    final saved = state.wishlist?.contains(productId) ?? false;
    return saved
        ? remove(productId)
        : add(productId: productId, variantId: variantId);
  }

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

  Future<bool> moveToCart({
    required String productId,
    String? variantId,
  }) async {
    final current = state.wishlist;
    if (current == null || state.isBusy(productId)) return false;

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

  void consumeMessage() => state = state.copyWith(clearMessage: true);

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

@Riverpod(keepAlive: true)
int wishlistCount(Ref ref) => ref.watch(wishlistProvider).itemCount;

@riverpod
bool isWishlisted(Ref ref, String productId) =>
    ref.watch(wishlistProvider).wishlist?.contains(productId) ?? false;
