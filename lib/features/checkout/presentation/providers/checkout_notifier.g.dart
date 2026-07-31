// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CheckoutNotifier)
final checkoutProvider = CheckoutNotifierProvider._();

final class CheckoutNotifierProvider
    extends $NotifierProvider<CheckoutNotifier, CheckoutState> {
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

String _$checkoutNotifierHash() => r'402e2cfc105621aac2834396a156b0f53d6b7919';

abstract class _$CheckoutNotifier extends $Notifier<CheckoutState> {
  CheckoutState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CheckoutState, CheckoutState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CheckoutState, CheckoutState>,
              CheckoutState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(availableCoupons)
final availableCouponsProvider = AvailableCouponsProvider._();

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
