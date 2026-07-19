import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../authentication/presentation/providers/auth_notifier.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
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

/// The place-order flow.
///
/// Holds the whole of checkout as one value because the steps are not
/// independent: the coupon depends on the subtotal, the payment warning
/// depends on the total, and the submit button depends on all of it. Split
/// across providers, keeping them consistent would be the bulk of the code.
@riverpod
class CheckoutNotifier extends _$CheckoutNotifier {
  @override
  CheckoutState build() {
    unawaited(_load());
    return const CheckoutState();
  }

  /// Loads the cart and the address book together, then works out whether
  /// anything blocks the order.
  Future<void> _load() async {
    state = state.copyWith(
      isLoading: true,
      clearFailure: true,
      clearPlaceFailure: true,
    );

    // Started together and awaited separately, so the two requests overlap —
    // this is the screen's whole cold start — while each keeps its own type.
    // `Future.wait` would erase them to a common supertype.
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
          // Preselect the default — for most customers this is the whole
          // address step, and making them tap their only address is friction
          // for nothing.
          shippingAddressId:
              next.shippingAddressId ?? _defaultAddressId(value),
        );
      case FailureResult(:final failure):
        // Only surfaced when the cart loaded fine; otherwise the cart's own
        // error is the more useful thing to put on screen.
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

  /// The reasons checkout cannot proceed that the client can determine
  /// itself, so each gets a proper explanation instead of an HTTP error.
  Future<List<CheckoutBlocker>> _blockersFor(CheckoutState candidate) async {
    final blockers = <CheckoutBlocker>[];

    final user = ref.read(currentUserProvider);
    // The backend closes `POST /orders` behind `requireVerifiedEmail`. Left
    // to the server this surfaces as a bare 403 — "you do not have permission"
    // — which tells the customer nothing about what to do.
    if (user != null && !user.isEmailVerified) {
      blockers.add(CheckoutBlocker.emailUnverified);
    }

    if (candidate.addresses.isEmpty) blockers.add(CheckoutBlocker.noAddress);

    if (!await ref.read(networkInfoProvider).isConnected) {
      blockers.add(CheckoutBlocker.offline);
    }

    return blockers;
  }

  // ── Selection ────────────────────────────────────────────────────────

  void selectShippingAddress(String addressId) {
    state = state.copyWith(shippingAddressId: addressId);
  }

  void selectBillingAddress(String addressId) {
    state = state.copyWith(
      billingAddressId: addressId,
      billToShippingAddress: false,
    );
  }

  /// Toggles "bill to the same address".
  ///
  /// Turning it on clears `billingAddressId` rather than copying the shipping
  /// id into it — an absent key is what tells the server "same as shipping",
  /// and sending the id twice would work but says something subtly different.
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
    // Capped at the backend's own limit so a long note is trimmed here rather
    // than rejected after the customer has committed.
    state = state.copyWith(
      customerNote: note.length > 500 ? note.substring(0, 500) : note,
    );
  }

  /// Demo affordance: forces the mock gateway to decline.
  void setSimulateFailure(bool value) {
    state = state.copyWith(simulateFailure: value, clearPlaceFailure: true);
  }

  // ── Coupons ──────────────────────────────────────────────────────────

  /// Checks a code and holds it for the order.
  ///
  /// The code is *not* attached to the cart here — `POST /orders` takes a
  /// `couponCode` and applies it inside the checkout transaction, where the
  /// discount is recomputed against the server's own subtotal. So what is
  /// shown until then is explicitly an estimate.
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

  // ── Addresses ────────────────────────────────────────────────────────

  /// Saves a new address from inside checkout and selects it.
  ///
  /// This has to exist here rather than only in account settings: an order
  /// needs an address *id*, so a customer with an empty book is stuck until
  /// one is created.
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
          // Selecting what was just typed is what the customer expects; they
          // added it in order to use it.
          shippingAddressId: value.id,
        );
        state = next.copyWith(blockers: await _blockersFor(next));

        // The address book lives on the user document too, so the profile the
        // rest of the app holds is now stale.
        unawaited(ref.read(authProvider.notifier).refreshUser());
        return true;

      case FailureResult(:final failure):
        state = state.copyWith(isLoading: false, failure: failure);
        return false;
    }
  }

  /// Edits an existing entry without leaving checkout.
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

  /// Re-sends the confirmation email, for the unverified-email gate.
  Future<String?> resendVerificationEmail() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return null;

    final result =
        await ref.read(resendVerificationUseCaseProvider)(user.email);
    // The endpoint's own message is deliberately vague and must be shown
    // verbatim rather than replaced with a guess.
    return result.fold(
      onSuccess: (message) => message,
      onFailure: (failure) => failure.message,
    );
  }

  /// Re-reads the profile, to notice that the email has since been verified.
  Future<void> recheckVerification() async {
    await ref.read(authProvider.notifier).refreshUser();
    state = state.copyWith(blockers: await _blockersFor(state));
  }

  // ── Placing ──────────────────────────────────────────────────────────

  /// Places the order.
  ///
  /// One request, one answer, no gateway hop. What comes back is the final
  /// state: cash on delivery lands `pending`/`pending`, the mock gateway
  /// lands `confirmed`/`paid`.
  ///
  /// Returns the order on success and null on failure. A failure here — most
  /// often a declined payment — means the server rolled its whole transaction
  /// back: **no order was created**, no stock was taken, nothing to reconcile
  /// or resume. The state keeps every choice the customer made so they can
  /// switch to cash and try again without re-entering anything.
  Future<Order?> placeOrder() async {
    if (!state.canPlaceOrder) return null;

    state = state.copyWith(isPlacingOrder: true, clearPlaceFailure: true);

    // Re-checked immediately before submitting rather than only at load:
    // another shopper can take the last unit while this screen sits open, and
    // catching it here yields a fixable message instead of a rolled-back
    // order.
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
        // The cart is empty and the history has a new top row; neither
        // provider knows yet.
        ref.invalidate(ordersProvider);
        return value;

      case FailureResult(:final failure):
        state = state.copyWith(isPlacingOrder: false, placeFailure: failure);
        return null;
    }
  }

  void clearPlaceFailure() => state = state.copyWith(clearPlaceFailure: true);
}

/// The coupons on offer for the current subtotal.
///
/// A separate provider because the coupon sheet is opened on demand — folding
/// it into [CheckoutNotifier] would fetch a list most customers never look at
/// on every checkout.
@riverpod
Future<List<AvailableCoupon>> availableCoupons(Ref ref) async {
  final subtotal = ref.watch(checkoutProvider).summary.subtotal;
  final result = await ref.read(getAvailableCouponsUseCaseProvider)(subtotal);
  return result.fold(
    onSuccess: (coupons) => coupons,
    // Thrown so the FutureProvider surfaces it as an error state; the sheet
    // is optional, and a failure there must not break checkout itself.
    onFailure: (failure) => throw failure,
  );
}
