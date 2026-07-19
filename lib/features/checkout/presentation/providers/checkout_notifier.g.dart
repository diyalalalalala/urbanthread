// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The place-order flow.
///
/// Holds the whole of checkout as one value because the steps are not
/// independent: the coupon depends on the subtotal, the payment warning
/// depends on the total, and the submit button depends on all of it. Split
/// across providers, keeping them consistent would be the bulk of the code.

@ProviderFor(CheckoutNotifier)
final checkoutProvider = CheckoutNotifierProvider._();

/// The place-order flow.
///
/// Holds the whole of checkout as one value because the steps are not
/// independent: the coupon depends on the subtotal, the payment warning
/// depends on the total, and the submit button depends on all of it. Split
/// across providers, keeping them consistent would be the bulk of the code.
final class CheckoutNotifierProvider
    extends $NotifierProvider<CheckoutNotifier, CheckoutState> {
  /// The place-order flow.
  ///
  /// Holds the whole of checkout as one value because the steps are not
  /// independent: the coupon depends on the subtotal, the payment warning
  /// depends on the total, and the submit button depends on all of it. Split
  /// across providers, keeping them consistent would be the bulk of the code.
  CheckoutNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkoutProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkoutNotifierHash();

  @$internal
  @override
  CheckoutNotifier create() => CheckoutNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckoutState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckoutState>(value),
    );
  }
}

String _$checkoutNotifierHash() => r'e5b30f6d76d790936c4d5bda5cd6b31ed68ccdf6';

/// The place-order flow.
///
/// Holds the whole of checkout as one value because the steps are not
/// independent: the coupon depends on the subtotal, the payment warning
/// depends on the total, and the submit button depends on all of it. Split
/// across providers, keeping them consistent would be the bulk of the code.

abstract class _$CheckoutNotifier extends $Notifier<CheckoutState> {
  CheckoutState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CheckoutState, CheckoutState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CheckoutState, CheckoutState>,
              CheckoutState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The coupons on offer for the current subtotal.
///
/// A separate provider because the coupon sheet is opened on demand — folding
/// it into [CheckoutNotifier] would fetch a list most customers never look at
/// on every checkout.

@ProviderFor(availableCoupons)
final availableCouponsProvider = AvailableCouponsProvider._();

/// The coupons on offer for the current subtotal.
///
/// A separate provider because the coupon sheet is opened on demand — folding
/// it into [CheckoutNotifier] would fetch a list most customers never look at
/// on every checkout.

final class AvailableCouponsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AvailableCoupon>>,
          List<AvailableCoupon>,
          FutureOr<List<AvailableCoupon>>
        >
    with
        $FutureModifier<List<AvailableCoupon>>,
        $FutureProvider<List<AvailableCoupon>> {
  /// The coupons on offer for the current subtotal.
  ///
  /// A separate provider because the coupon sheet is opened on demand — folding
  /// it into [CheckoutNotifier] would fetch a list most customers never look at
  /// on every checkout.
  AvailableCouponsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availableCouponsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availableCouponsHash();

  @$internal
  @override
  $FutureProviderElement<List<AvailableCoupon>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AvailableCoupon>> create(Ref ref) {
    return availableCoupons(ref);
  }
}

String _$availableCouponsHash() => r'dc344cefa6e6393635c6843b11ea9b73072a07c6';
