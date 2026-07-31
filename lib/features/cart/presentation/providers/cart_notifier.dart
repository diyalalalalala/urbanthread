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

@Riverpod(keepAlive: true)
class CartNotifier extends _$CartNotifier {
  @override
  CartState build() {
    final repository = ref.watch(cartRepositoryProvider);

    ref.listen(connectionStatusProvider, (previous, next) {
      final isOnline = next.value ?? false;
      final wasOnline = previous?.value ?? false;
      if (isOnline && !wasOnline) unawaited(sync());
    });

    final cached = repository.cachedCart;
    unawaited(_load(silent: true));

    return CartState(
      snapshot: cached,
      isLoading: cached == null,
      pendingWrites: repository.pendingWriteCount,
    );
  }

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
          message: remaining == 0
              ? 'Your offline changes have been saved.'
              : 'Some offline changes could not be saved.',
        );
      case FailureResult():
        state = state.copyWith(
          isSyncing: false,
          pendingWrites: _pendingWrites,
        );
    }
  }

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

  Future<void> removeItem(String itemId) async {
    final current = state.snapshot;
    if (current == null || state.isItemBusy(itemId)) return;

    _applyOptimistic(current, current.cart.withoutItem(itemId), itemId);

    final result = await ref.read(removeCartItemUseCaseProvider)(itemId);
    _settle(result, itemId: itemId, rollbackTo: current);
  }

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

  Future<CartValidation?> validateForCheckout() async {
    state = state.copyWith(clearFailure: true, clearMessage: true);
    final result = await ref.read(validateCartUseCaseProvider)(
      const NoParams(),
    );

    return result.fold(
      onSuccess: (validation) async {
        if (!validation.isValid) await refresh();
        return validation;
      },
      onFailure: (failure) {
        state = state.copyWith(failure: failure, message: failure.message);
        return null;
      },
    );
  }

  void adoptSnapshot(CartSnapshot snapshot) {
    state = state.copyWith(
      snapshot: snapshot,
      clearFailure: true,
      pendingWrites: _pendingWrites,
    );
  }

  void consumeMessage() => state = state.copyWith(clearMessage: true);

  int get _pendingWrites => ref.read(cartRepositoryProvider).pendingWriteCount;

  void _applyOptimistic(CartSnapshot current, Cart updated, String itemId) {
    state = state.copyWith(
      snapshot: current.withOptimisticCart(updated),
      busyItemIds: {...state.busyItemIds, itemId},
      clearFailure: true,
      clearMessage: true,
    );
  }

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

@Riverpod(keepAlive: true)
int cartItemCount(Ref ref) =>
    ref.watch(cartProvider).snapshot?.itemCount ?? 0;

@riverpod
double cartGrandTotal(Ref ref) =>
    ref.watch(cartProvider).snapshot?.summary.grandTotal ?? 0;

@riverpod
bool isInCart(Ref ref, {required String productId, required String variantId}) {
  final cart = ref.watch(cartProvider).snapshot?.cart;
  return cart?.lineFor(productId: productId, variantId: variantId) != null;
}
