import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../orders/domain/entities/order.dart';
import '../../domain/entities/checkout_cart.dart';
import '../../domain/entities/coupon.dart';

/// Why checkout will not proceed, when the reason is the app's to explain
/// rather than the server's to reject.
enum CheckoutBlocker {
  /// `requireVerifiedEmail` guards `POST /orders`. Caught before the request
  /// so the customer gets an explanation and a "resend link" button instead
  /// of a bare 403.
  emailUnverified,

  /// No saved address, and `POST /orders` takes an address *id* — there is no
  /// way to pass a one-off address, so one must be created first.
  noAddress,

  /// Placing an order is never queued offline.
  offline,
}

/// Everything the checkout screen holds.
class CheckoutState extends Equatable {
  const CheckoutState({
    this.cart,
    this.addresses = const [],
    this.shippingAddressId,
    this.billingAddressId,
    this.billToShippingAddress = true,
    this.paymentMethod = PaymentMethod.cod,
    this.appliedCoupon,
    this.couponCode,
    this.customerNote = '',
    this.simulateFailure = false,
    this.isLoading = true,
    this.isApplyingCoupon = false,
    this.isPlacingOrder = false,
    this.failure,
    this.couponFailure,
    this.placeFailure,
    this.blockers = const [],
    this.placedOrder,
  });

  final CheckoutCart? cart;
  final List<Address> addresses;

  /// The id sent as `shippingAddressId`. An **id**, not an address — the
  /// server looks it up on the user document and snapshots it itself.
  final String? shippingAddressId;

  /// Sent only when [billToShippingAddress] is false. Omitting it means
  /// "same as shipping", which is what most orders want.
  final String? billingAddressId;

  final bool billToShippingAddress;
  final PaymentMethod paymentMethod;

  /// The preview returned by `POST /coupons/validate`. Advisory: the discount
  /// actually applied is recomputed server-side when the order is placed.
  final CouponPreview? appliedCoupon;

  /// The code that will ride along on `POST /orders`.
  final String? couponCode;

  final String customerNote;

  /// Forces the mock gateway to decline, for demonstrating the failure path.
  final bool simulateFailure;

  final bool isLoading;
  final bool isApplyingCoupon;
  final bool isPlacingOrder;

  /// Failed to load the cart or the address book.
  final Failure? failure;

  /// The coupon was rejected. Scoped to its own field so it does not blank
  /// the page.
  final Failure? couponFailure;

  /// `POST /orders` was refused — most importantly by a declined payment, in
  /// which case **no order exists**: the server rolled the whole transaction
  /// back and put the stock back on the shelf.
  final Failure? placeFailure;

  /// Client-side reasons the order cannot be placed.
  final List<CheckoutBlocker> blockers;

  /// Set once, on success. Its presence is what triggers navigation to the
  /// confirmation screen.
  final Order? placedOrder;

  CartSummary get summary => cart?.summary ?? const CartSummary.empty();

  Address? get shippingAddress => _addressById(shippingAddressId);

  Address? get billingAddress =>
      billToShippingAddress ? shippingAddress : _addressById(billingAddressId);

  Address? _addressById(String? id) {
    if (id == null) return null;
    for (final address in addresses) {
      if (address.id == id) return address;
    }
    return null;
  }

  bool get hasBlockers => blockers.isNotEmpty;

  bool get isEmailUnverified =>
      blockers.contains(CheckoutBlocker.emailUnverified);

  bool get isOffline => blockers.contains(CheckoutBlocker.offline);

  /// Everything that must be true before the place-order button lights up.
  bool get canPlaceOrder =>
      !isLoading &&
      !isPlacingOrder &&
      !hasBlockers &&
      cart != null &&
      !cart!.isEmpty &&
      shippingAddressId != null &&
      (billToShippingAddress || billingAddressId != null);

  /// Whether the mock gateway is expected to refuse this total.
  ///
  /// It declines deterministically when the integer part of the grand total
  /// ends in 7. Surfacing that before the customer commits turns a confusing
  /// rolled-back order into a choice they can make — pay cash instead, or
  /// change the basket. Only a prediction: the server recomputes the total
  /// from live prices, so the 422 still has to be handled.
  bool get expectsMockDecline =>
      paymentMethod == PaymentMethod.mockGateway &&
      (summary.willMockGatewayDecline || simulateFailure);

  CheckoutState copyWith({
    CheckoutCart? cart,
    List<Address>? addresses,
    String? shippingAddressId,
    String? billingAddressId,
    bool clearBillingAddressId = false,
    bool? billToShippingAddress,
    PaymentMethod? paymentMethod,
    CouponPreview? appliedCoupon,
    String? couponCode,
    bool clearCoupon = false,
    String? customerNote,
    bool? simulateFailure,
    bool? isLoading,
    bool? isApplyingCoupon,
    bool? isPlacingOrder,
    Failure? failure,
    bool clearFailure = false,
    Failure? couponFailure,
    bool clearCouponFailure = false,
    Failure? placeFailure,
    bool clearPlaceFailure = false,
    List<CheckoutBlocker>? blockers,
    Order? placedOrder,
  }) =>
      CheckoutState(
        cart: cart ?? this.cart,
        addresses: addresses ?? this.addresses,
        shippingAddressId: shippingAddressId ?? this.shippingAddressId,
        billingAddressId: clearBillingAddressId
            ? null
            : (billingAddressId ?? this.billingAddressId),
        billToShippingAddress:
            billToShippingAddress ?? this.billToShippingAddress,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        appliedCoupon: clearCoupon ? null : (appliedCoupon ?? this.appliedCoupon),
        couponCode: clearCoupon ? null : (couponCode ?? this.couponCode),
        customerNote: customerNote ?? this.customerNote,
        simulateFailure: simulateFailure ?? this.simulateFailure,
        isLoading: isLoading ?? this.isLoading,
        isApplyingCoupon: isApplyingCoupon ?? this.isApplyingCoupon,
        isPlacingOrder: isPlacingOrder ?? this.isPlacingOrder,
        failure: clearFailure ? null : (failure ?? this.failure),
        couponFailure:
            clearCouponFailure ? null : (couponFailure ?? this.couponFailure),
        placeFailure:
            clearPlaceFailure ? null : (placeFailure ?? this.placeFailure),
        blockers: blockers ?? this.blockers,
        placedOrder: placedOrder ?? this.placedOrder,
      );

  @override
  List<Object?> get props => [
        cart,
        addresses,
        shippingAddressId,
        billingAddressId,
        billToShippingAddress,
        paymentMethod,
        appliedCoupon,
        couponCode,
        customerNote,
        simulateFailure,
        isLoading,
        isApplyingCoupon,
        isPlacingOrder,
        failure,
        couponFailure,
        placeFailure,
        blockers,
        placedOrder,
      ];
}

/// State of the address book editor.
class AddressBookState extends Equatable {
  const AddressBookState({
    this.addresses = const [],
    this.isLoading = true,
    this.isSubmitting = false,
    this.failure,
  });

  final List<Address> addresses;
  final bool isLoading;
  final bool isSubmitting;
  final Failure? failure;

  bool get isEmpty => !isLoading && addresses.isEmpty;

  Address? get defaultAddress {
    for (final address in addresses) {
      if (address.isDefault) return address;
    }
    return addresses.isEmpty ? null : addresses.first;
  }

  AddressBookState copyWith({
    List<Address>? addresses,
    bool? isLoading,
    bool? isSubmitting,
    Failure? failure,
    bool clearFailure = false,
  }) =>
      AddressBookState(
        addresses: addresses ?? this.addresses,
        isLoading: isLoading ?? this.isLoading,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        failure: clearFailure ? null : (failure ?? this.failure),
      );

  @override
  List<Object?> get props => [addresses, isLoading, isSubmitting, failure];
}
