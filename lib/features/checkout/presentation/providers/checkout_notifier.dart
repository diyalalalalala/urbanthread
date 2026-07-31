import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../authentication/presentation/providers/auth_notifier.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/repositories/order_repository.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../../orders/presentation/providers/orders_notifier.dart';
import '../../domain/entities/address_draft.dart';
import '../../domain/entities/coupon.dart';
import '../../domain/usecases/update_address_usecase.dart';
import '../../domain/usecases/validate_coupon_usecase.dart';
import 'checkout_providers.dart';
import 'checkout_state.dart';

part 'checkout_notifier.g.dart';

@riverpod
class CheckoutNotifier extends _$CheckoutNotifier {
  @override
  CheckoutState build() {
    unawaited(_load(silent: true));
    return const CheckoutState();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(
        isLoading: true,
        clearFailure: true,
        clearPlaceFailure: true,
      );
    }

    final cartFuture = ref.read(validateCartUseCaseProvider)(const NoParams());
    final addressFuture =
        ref.read(getAddressesUseCaseProvider)(const NoParams());

    final cartResult = await cartFuture;
    final addressResult = await addressFuture;

    var next = state.copyWith(isLoading: false);

    switch (cartResult) {
      case Success(:final value):
        next = next.copyWith(cart: value);
      case FailureResult(:final failure):
        next = next.copyWith(failure: failure);
    }

    switch (addressResult) {
      case Success(:final value):
        next = next.copyWith(
          addresses: value,
          shippingAddressId:
              next.shippingAddressId ?? _defaultAddressId(value),
        );
      case FailureResult(:final failure):
        if (next.failure == null) next = next.copyWith(failure: failure);
    }

    state = next.copyWith(blockers: await _blockersFor(next));
  }

  Future<void> refresh() => _load();

  String? _defaultAddressId(List<Address> addresses) {
    if (addresses.isEmpty) return null;
    for (final address in addresses) {
      if (address.isDefault) return address.id;
    }
    return addresses.first.id;
  }

  Future<List<CheckoutBlocker>> _blockersFor(CheckoutState candidate) async {
    final blockers = <CheckoutBlocker>[];

    if (candidate.addresses.isEmpty) blockers.add(CheckoutBlocker.noAddress);

    if (!await ref.read(networkInfoProvider).isConnected) {
      blockers.add(CheckoutBlocker.offline);
    }

    return blockers;
  }

  void selectShippingAddress(String addressId) {
    state = state.copyWith(shippingAddressId: addressId);
  }

  void selectBillingAddress(String addressId) {
    state = state.copyWith(
      billingAddressId: addressId,
      billToShippingAddress: false,
    );
  }

  void setBillToShipping(bool value) {
    state = state.copyWith(
      billToShippingAddress: value,
      clearBillingAddressId: value,
    );
  }

  void selectPaymentMethod(PaymentMethod method) {
    state = state.copyWith(paymentMethod: method, clearPlaceFailure: true);
  }

  void setCustomerNote(String note) {
    state = state.copyWith(
      customerNote: note.length > 500 ? note.substring(0, 500) : note,
    );
  }

  void setSimulateFailure(bool value) {
    state = state.copyWith(simulateFailure: value, clearPlaceFailure: true);
  }

  Future<bool> applyCoupon(String code) async {
    final trimmed = code.trim().toUpperCase();
    if (trimmed.length < 3 || trimmed.length > 24) {
      state = state.copyWith(
        couponFailure: const ValidationFailure(
          'A coupon code is between 3 and 24 characters.',
        ),
      );
      return false;
    }

    state = state.copyWith(isApplyingCoupon: true, clearCouponFailure: true);

    final result = await ref.read(validateCouponUseCaseProvider)(
      ValidateCouponParams(code: trimmed, subtotal: state.summary.subtotal),
    );

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          isApplyingCoupon: false,
          appliedCoupon: value,
          couponCode: value.code,
        );
        return true;

      case FailureResult(:final failure):
        state = state.copyWith(
          isApplyingCoupon: false,
          couponFailure: failure,
        );
        return false;
    }
  }

  void removeCoupon() =>
      state = state.copyWith(clearCoupon: true, clearCouponFailure: true);

  void clearCouponFailure() =>
      state = state.copyWith(clearCouponFailure: true);

  Future<bool> addAddress(AddressDraft draft) async {
    state = state.copyWith(isLoading: true, clearFailure: true);

    final result = await ref.read(addAddressUseCaseProvider)(draft);

    switch (result) {
      case Success(:final value):
        final refreshed =
            await ref.read(getAddressesUseCaseProvider)(const NoParams());

        final addresses = refreshed.valueOrNull ?? [...state.addresses, value];
        final next = state.copyWith(
          addresses: addresses,
          isLoading: false,
          shippingAddressId: value.id,
        );
        state = next.copyWith(blockers: await _blockersFor(next));

        unawaited(ref.read(authProvider.notifier).refreshUser());
        return true;

      case FailureResult(:final failure):
        state = state.copyWith(isLoading: false, failure: failure);
        return false;
    }
  }

  Future<bool> updateAddress(String id, AddressDraft draft) async {
    state = state.copyWith(isLoading: true, clearFailure: true);

    final result = await ref.read(updateAddressUseCaseProvider)(
      UpdateAddressParams(id: id, draft: draft),
    );

    if (result case FailureResult(:final failure)) {
      state = state.copyWith(isLoading: false, failure: failure);
      return false;
    }

    final refreshed =
        await ref.read(getAddressesUseCaseProvider)(const NoParams());
    state = state.copyWith(
      addresses: refreshed.valueOrNull ?? state.addresses,
      isLoading: false,
    );
    unawaited(ref.read(authProvider.notifier).refreshUser());
    return true;
  }

  Future<Order?> placeOrder() async {
    if (!state.canPlaceOrder) return null;

    state = state.copyWith(isPlacingOrder: true, clearPlaceFailure: true);

    final validation = await ref.read(validateCartUseCaseProvider)(
      const NoParams(),
    );

    if (validation case FailureResult(:final failure)) {
      state = state.copyWith(isPlacingOrder: false, placeFailure: failure);
      return null;
    }

    final result = await ref.read(placeOrderUseCaseProvider)(
      PlaceOrderDraft(
        shippingAddressId: state.shippingAddressId!,
        billingAddressId:
            state.billToShippingAddress ? null : state.billingAddressId,
        paymentMethod: state.paymentMethod,
        couponCode: state.couponCode,
        customerNote:
            state.customerNote.trim().isEmpty ? null : state.customerNote.trim(),
        simulateFailure: state.simulateFailure,
      ),
    );

    switch (result) {
      case Success(:final value):
        state = state.copyWith(isPlacingOrder: false, placedOrder: value);
        ref.invalidate(ordersProvider);
        return value;

      case FailureResult(:final failure):
        state = state.copyWith(isPlacingOrder: false, placeFailure: failure);
        return null;
    }
  }

  void clearPlaceFailure() => state = state.copyWith(clearPlaceFailure: true);
}

@riverpod
Future<List<AvailableCoupon>> availableCoupons(Ref ref) async {
  final subtotal = ref.watch(checkoutProvider).summary.subtotal;
  final result = await ref.read(getAvailableCouponsUseCaseProvider)(subtotal);
  return result.fold(
    onSuccess: (coupons) => coupons,
    onFailure: (failure) => throw failure,
  );
}
