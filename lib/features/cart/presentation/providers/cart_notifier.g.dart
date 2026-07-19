// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The cart, and the only thing allowed to change it.
///
/// Kept alive for the app's lifetime: the bottom-nav badge reads it from every
/// tab, and letting it dispose when the cart page closes would drop the badge
/// to zero and re-fetch on the next visit.
///
/// Mutations are optimistic. The previous snapshot is captured before the
/// request, the change is applied locally, and the captured copy is restored
/// if the server disagrees — a stepper that waits on a round trip before
/// moving feels broken, and the rollback is what makes that safe.

@ProviderFor(CartNotifier)
final cartProvider = CartNotifierProvider._();

/// The cart, and the only thing allowed to change it.
///
/// Kept alive for the app's lifetime: the bottom-nav badge reads it from every
/// tab, and letting it dispose when the cart page closes would drop the badge
/// to zero and re-fetch on the next visit.
///
/// Mutations are optimistic. The previous snapshot is captured before the
/// request, the change is applied locally, and the captured copy is restored
/// if the server disagrees — a stepper that waits on a round trip before
/// moving feels broken, and the rollback is what makes that safe.
final class CartNotifierProvider
    extends $NotifierProvider<CartNotifier, CartState> {
  /// The cart, and the only thing allowed to change it.
  ///
  /// Kept alive for the app's lifetime: the bottom-nav badge reads it from every
  /// tab, and letting it dispose when the cart page closes would drop the badge
  /// to zero and re-fetch on the next visit.
  ///
  /// Mutations are optimistic. The previous snapshot is captured before the
  /// request, the change is applied locally, and the captured copy is restored
  /// if the server disagrees — a stepper that waits on a round trip before
  /// moving feels broken, and the rollback is what makes that safe.
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

String _$cartNotifierHash() => r'0f4637c7df2c0193db5f718c2d7d360dcb175f96';

/// The cart, and the only thing allowed to change it.
///
/// Kept alive for the app's lifetime: the bottom-nav badge reads it from every
/// tab, and letting it dispose when the cart page closes would drop the badge
/// to zero and re-fetch on the next visit.
///
/// Mutations are optimistic. The previous snapshot is captured before the
/// request, the change is applied locally, and the captured copy is restored
/// if the server disagrees — a stepper that waits on a round trip before
/// moving feels broken, and the rollback is what makes that safe.

abstract class _$CartNotifier extends $Notifier<CartState> {
  CartState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CartState, CartState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CartState, CartState>,
              CartState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Units in the cart, for the bottom-nav badge.
///
/// Kept alive and derived rather than `.select`-ed off [cartProvider] —
/// `.select` is unavailable on a generated notifier provider in Riverpod 3,
/// and a derived provider only re-emits when the count itself changes, which
/// is the same saving without the ceremony.

@ProviderFor(cartItemCount)
final cartItemCountProvider = CartItemCountProvider._();

/// Units in the cart, for the bottom-nav badge.
///
/// Kept alive and derived rather than `.select`-ed off [cartProvider] —
/// `.select` is unavailable on a generated notifier provider in Riverpod 3,
/// and a derived provider only re-emits when the count itself changes, which
/// is the same saving without the ceremony.

final class CartItemCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Units in the cart, for the bottom-nav badge.
  ///
  /// Kept alive and derived rather than `.select`-ed off [cartProvider] —
  /// `.select` is unavailable on a generated notifier provider in Riverpod 3,
  /// and a derived provider only re-emits when the count itself changes, which
  /// is the same saving without the ceremony.
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

/// The payable total, for a persistent checkout bar.

@ProviderFor(cartGrandTotal)
final cartGrandTotalProvider = CartGrandTotalProvider._();

/// The payable total, for a persistent checkout bar.

final class CartGrandTotalProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  /// The payable total, for a persistent checkout bar.
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

/// Whether a product/variant pair is already in the cart, so a product page
/// can offer "view cart" instead of adding a second time.

@ProviderFor(isInCart)
final isInCartProvider = IsInCartFamily._();

/// Whether a product/variant pair is already in the cart, so a product page
/// can offer "view cart" instead of adding a second time.

final class IsInCartProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether a product/variant pair is already in the cart, so a product page
  /// can offer "view cart" instead of adding a second time.
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

/// Whether a product/variant pair is already in the cart, so a product page
/// can offer "view cart" instead of adding a second time.

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

  /// Whether a product/variant pair is already in the cart, so a product page
  /// can offer "view cart" instead of adding a second time.

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
