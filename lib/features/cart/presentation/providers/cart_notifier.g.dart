// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CartNotifier)
final cartProvider = CartNotifierProvider._();

final class CartNotifierProvider
    extends $NotifierProvider<CartNotifier, CartState> {
  CartNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartNotifierHash();

  @$internal
  @override
  CartNotifier create() => CartNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CartState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CartState>(value),
    );
  }
}

String _$cartNotifierHash() => r'743d6ffe4fe659c0342aca726368b7076b57725c';

abstract class _$CartNotifier extends $Notifier<CartState> {
  CartState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CartState, CartState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CartState, CartState>,
              CartState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(cartItemCount)
final cartItemCountProvider = CartItemCountProvider._();

final class CartItemCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  CartItemCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartItemCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartItemCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return cartItemCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$cartItemCountHash() => r'c1f60d7fd70765685ef66f1c39afe6cef8ad1a2f';

@ProviderFor(cartGrandTotal)
final cartGrandTotalProvider = CartGrandTotalProvider._();

final class CartGrandTotalProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  CartGrandTotalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartGrandTotalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartGrandTotalHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return cartGrandTotal(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$cartGrandTotalHash() => r'f5602d4ff60433deaba23e76899c34bc37808dac';

@ProviderFor(isInCart)
final isInCartProvider = IsInCartFamily._();

final class IsInCartProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  IsInCartProvider._({
    required IsInCartFamily super.from,
    required ({String productId, String variantId}) super.argument,
  }) : super(
         retry: null,
         name: r'isInCartProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isInCartHash();

  @override
  String toString() {
    return r'isInCartProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as ({String productId, String variantId});
    return isInCart(
      ref,
      productId: argument.productId,
      variantId: argument.variantId,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsInCartProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isInCartHash() => r'c7edde1e93694ee83cee6a0b7c1e9753bbf06d98';

final class IsInCartFamily extends $Family
    with
        $FunctionalFamilyOverride<
          bool,
          ({String productId, String variantId})
        > {
  IsInCartFamily._()
    : super(
        retry: null,
        name: r'isInCartProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IsInCartProvider call({
    required String productId,
    required String variantId,
  }) => IsInCartProvider._(
    argument: (productId: productId, variantId: variantId),
    from: this,
  );

  @override
  String toString() => r'isInCartProvider';
}
