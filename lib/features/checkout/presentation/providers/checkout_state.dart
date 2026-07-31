import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../orders/domain/entities/order.dart';
import '../../domain/entities/checkout_cart.dart';
import '../../domain/entities/coupon.dart';

enum CheckoutBlocker {
  noAddress,

  offline,
}

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

  final String? shippingAddressId;

  final String? billingAddressId;

  final bool billToShippingAddress;
  final PaymentMethod paymentMethod;

  final CouponPreview? appliedCoupon;

  final String? couponCode;

  final String customerNote;

  final bool simulateFailure;

  final bool isLoading;
  final bool isApplyingCoupon;
  final bool isPlacingOrder;

  final Failure? failure;

  final Failure? couponFailure;

  final Failure? placeFailure;

  final List<CheckoutBlocker> blockers;

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

  bool get isOffline => blockers.contains(CheckoutBlocker.offline);

  bool get canPlaceOrder =>
      !isLoading &&
      !isPlacingOrder &&
      !hasBlockers &&
      cart != null &&
      !cart!.isEmpty &&
      shippingAddressId != null &&
      (billToShippingAddress || billingAddressId != null);

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
