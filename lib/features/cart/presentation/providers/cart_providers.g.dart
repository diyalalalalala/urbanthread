// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Wiring for the cart feature.
///
/// The repository is kept alive: it owns the offline write queue, and a
/// disposed instance would mean a queued mutation losing the object that knows
/// how to replay it.

@ProviderFor(cartRemoteDataSource)
final cartRemoteDataSourceProvider = CartRemoteDataSourceProvider._();

/// Wiring for the cart feature.
///
/// The repository is kept alive: it owns the offline write queue, and a
/// disposed instance would mean a queued mutation losing the object that knows
/// how to replay it.

final class CartRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          CartRemoteDataSource,
          CartRemoteDataSource,
          CartRemoteDataSource
        >
    with $Provider<CartRemoteDataSource> {
  /// Wiring for the cart feature.
  ///
  /// The repository is kept alive: it owns the offline write queue, and a
  /// disposed instance would mean a queued mutation losing the object that knows
  /// how to replay it.
  CartRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<CartRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CartRemoteDataSource create(Ref ref) {
    return cartRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CartRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CartRemoteDataSource>(value),
    );
  }
}

String _$cartRemoteDataSourceHash() =>
    r'754a3c9f9e3ec93c7dc409d723e87e7bf2cd00c5';

@ProviderFor(cartLocalDataSource)
final cartLocalDataSourceProvider = CartLocalDataSourceProvider._();

final class CartLocalDataSourceProvider
    extends
        $FunctionalProvider<
          CartLocalDataSource,
          CartLocalDataSource,
          CartLocalDataSource
        >
    with $Provider<CartLocalDataSource> {
  CartLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<CartLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CartLocalDataSource create(Ref ref) {
    return cartLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CartLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CartLocalDataSource>(value),
    );
  }
}

String _$cartLocalDataSourceHash() =>
    r'9487d89be56d66211b12082a8c1009c07c0e951d';

/// The cart's slice of the shared `outbox` box.

@ProviderFor(cartOutbox)
final cartOutboxProvider = CartOutboxProvider._();

/// The cart's slice of the shared `outbox` box.

final class CartOutboxProvider
    extends $FunctionalProvider<OutboxQueue, OutboxQueue, OutboxQueue>
    with $Provider<OutboxQueue> {
  /// The cart's slice of the shared `outbox` box.
  CartOutboxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartOutboxProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartOutboxHash();

  @$internal
  @override
  $ProviderElement<OutboxQueue> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OutboxQueue create(Ref ref) {
    return cartOutbox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OutboxQueue value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OutboxQueue>(value),
    );
  }
}

String _$cartOutboxHash() => r'4a59c5ea300607b4c741ad00866c00a51480bc69';

@ProviderFor(cartRepository)
final cartRepositoryProvider = CartRepositoryProvider._();

final class CartRepositoryProvider
    extends $FunctionalProvider<CartRepository, CartRepository, CartRepository>
    with $Provider<CartRepository> {
  CartRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartRepositoryHash();

  @$internal
  @override
  $ProviderElement<CartRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CartRepository create(Ref ref) {
    return cartRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CartRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CartRepository>(value),
    );
  }
}

String _$cartRepositoryHash() => r'70f14a2b48de947081b87f9d1d9ef72d8646c2fe';

@ProviderFor(getCartUseCase)
final getCartUseCaseProvider = GetCartUseCaseProvider._();

final class GetCartUseCaseProvider
    extends $FunctionalProvider<GetCartUseCase, GetCartUseCase, GetCartUseCase>
    with $Provider<GetCartUseCase> {
  GetCartUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getCartUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getCartUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCartUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetCartUseCase create(Ref ref) {
    return getCartUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCartUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCartUseCase>(value),
    );
  }
}

String _$getCartUseCaseHash() => r'd1cfef4789eeafb7328c9266cebf0e9c31aafa2c';

@ProviderFor(getCartSummaryUseCase)
final getCartSummaryUseCaseProvider = GetCartSummaryUseCaseProvider._();

final class GetCartSummaryUseCaseProvider
    extends
        $FunctionalProvider<
          GetCartSummaryUseCase,
          GetCartSummaryUseCase,
          GetCartSummaryUseCase
        >
    with $Provider<GetCartSummaryUseCase> {
  GetCartSummaryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getCartSummaryUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getCartSummaryUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCartSummaryUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetCartSummaryUseCase create(Ref ref) {
    return getCartSummaryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCartSummaryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCartSummaryUseCase>(value),
    );
  }
}

String _$getCartSummaryUseCaseHash() =>
    r'71d39e4f4ff0dfa162cd3e90b0beaa4efff648cb';

@ProviderFor(validateCartUseCase)
final validateCartUseCaseProvider = ValidateCartUseCaseProvider._();

final class ValidateCartUseCaseProvider
    extends
        $FunctionalProvider<
          ValidateCartUseCase,
          ValidateCartUseCase,
          ValidateCartUseCase
        >
    with $Provider<ValidateCartUseCase> {
  ValidateCartUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'validateCartUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$validateCartUseCaseHash();

  @$internal
  @override
  $ProviderElement<ValidateCartUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ValidateCartUseCase create(Ref ref) {
    return validateCartUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ValidateCartUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ValidateCartUseCase>(value),
    );
  }
}

String _$validateCartUseCaseHash() =>
    r'1305be2efbb2e9bb4c8e5f9eda27662afa662e6f';

@ProviderFor(addToCartUseCase)
final addToCartUseCaseProvider = AddToCartUseCaseProvider._();

final class AddToCartUseCaseProvider
    extends
        $FunctionalProvider<
          AddToCartUseCase,
          AddToCartUseCase,
          AddToCartUseCase
        >
    with $Provider<AddToCartUseCase> {
  AddToCartUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addToCartUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addToCartUseCaseHash();

  @$internal
  @override
  $ProviderElement<AddToCartUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AddToCartUseCase create(Ref ref) {
    return addToCartUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddToCartUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddToCartUseCase>(value),
    );
  }
}

String _$addToCartUseCaseHash() => r'6db2430b313ef0c19bf8249e4bdaf1fbebfbecd7';

@ProviderFor(updateCartItemQuantityUseCase)
final updateCartItemQuantityUseCaseProvider =
    UpdateCartItemQuantityUseCaseProvider._();

final class UpdateCartItemQuantityUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateCartItemQuantityUseCase,
          UpdateCartItemQuantityUseCase,
          UpdateCartItemQuantityUseCase
        >
    with $Provider<UpdateCartItemQuantityUseCase> {
  UpdateCartItemQuantityUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateCartItemQuantityUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateCartItemQuantityUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateCartItemQuantityUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateCartItemQuantityUseCase create(Ref ref) {
    return updateCartItemQuantityUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateCartItemQuantityUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateCartItemQuantityUseCase>(
        value,
      ),
    );
  }
}

String _$updateCartItemQuantityUseCaseHash() =>
    r'61c3424995e96324c165f97722f25f3f314cea85';

@ProviderFor(removeCartItemUseCase)
final removeCartItemUseCaseProvider = RemoveCartItemUseCaseProvider._();

final class RemoveCartItemUseCaseProvider
    extends
        $FunctionalProvider<
          RemoveCartItemUseCase,
          RemoveCartItemUseCase,
          RemoveCartItemUseCase
        >
    with $Provider<RemoveCartItemUseCase> {
  RemoveCartItemUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'removeCartItemUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$removeCartItemUseCaseHash();

  @$internal
  @override
  $ProviderElement<RemoveCartItemUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RemoveCartItemUseCase create(Ref ref) {
    return removeCartItemUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoveCartItemUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoveCartItemUseCase>(value),
    );
  }
}

String _$removeCartItemUseCaseHash() =>
    r'c428c1d0c8f25024be0c02c9d4504b5a6389721f';

@ProviderFor(saveForLaterUseCase)
final saveForLaterUseCaseProvider = SaveForLaterUseCaseProvider._();

final class SaveForLaterUseCaseProvider
    extends
        $FunctionalProvider<
          SaveForLaterUseCase,
          SaveForLaterUseCase,
          SaveForLaterUseCase
        >
    with $Provider<SaveForLaterUseCase> {
  SaveForLaterUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveForLaterUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveForLaterUseCaseHash();

  @$internal
  @override
  $ProviderElement<SaveForLaterUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaveForLaterUseCase create(Ref ref) {
    return saveForLaterUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveForLaterUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveForLaterUseCase>(value),
    );
  }
}

String _$saveForLaterUseCaseHash() =>
    r'2aee2eccd5abfc8c52b262a3907a9c5af503e552';

@ProviderFor(moveToCartUseCase)
final moveToCartUseCaseProvider = MoveToCartUseCaseProvider._();

final class MoveToCartUseCaseProvider
    extends
        $FunctionalProvider<
          MoveToCartUseCase,
          MoveToCartUseCase,
          MoveToCartUseCase
        >
    with $Provider<MoveToCartUseCase> {
  MoveToCartUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moveToCartUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moveToCartUseCaseHash();

  @$internal
  @override
  $ProviderElement<MoveToCartUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MoveToCartUseCase create(Ref ref) {
    return moveToCartUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MoveToCartUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MoveToCartUseCase>(value),
    );
  }
}

String _$moveToCartUseCaseHash() => r'9b4153edce294c2c922d9bd294ab1270ae076bf5';

@ProviderFor(applyCouponUseCase)
final applyCouponUseCaseProvider = ApplyCouponUseCaseProvider._();

final class ApplyCouponUseCaseProvider
    extends
        $FunctionalProvider<
          ApplyCouponUseCase,
          ApplyCouponUseCase,
          ApplyCouponUseCase
        >
    with $Provider<ApplyCouponUseCase> {
  ApplyCouponUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'applyCouponUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$applyCouponUseCaseHash();

  @$internal
  @override
  $ProviderElement<ApplyCouponUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ApplyCouponUseCase create(Ref ref) {
    return applyCouponUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApplyCouponUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApplyCouponUseCase>(value),
    );
  }
}

String _$applyCouponUseCaseHash() =>
    r'c856b12083b3b4b2a39e30561f930c495a161116';

@ProviderFor(removeCouponUseCase)
final removeCouponUseCaseProvider = RemoveCouponUseCaseProvider._();

final class RemoveCouponUseCaseProvider
    extends
        $FunctionalProvider<
          RemoveCouponUseCase,
          RemoveCouponUseCase,
          RemoveCouponUseCase
        >
    with $Provider<RemoveCouponUseCase> {
  RemoveCouponUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'removeCouponUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$removeCouponUseCaseHash();

  @$internal
  @override
  $ProviderElement<RemoveCouponUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RemoveCouponUseCase create(Ref ref) {
    return removeCouponUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoveCouponUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoveCouponUseCase>(value),
    );
  }
}

String _$removeCouponUseCaseHash() =>
    r'e1f954aeab81496cff14f54eb779d7c329b9eaa9';

@ProviderFor(clearCartUseCase)
final clearCartUseCaseProvider = ClearCartUseCaseProvider._();

final class ClearCartUseCaseProvider
    extends
        $FunctionalProvider<
          ClearCartUseCase,
          ClearCartUseCase,
          ClearCartUseCase
        >
    with $Provider<ClearCartUseCase> {
  ClearCartUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clearCartUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clearCartUseCaseHash();

  @$internal
  @override
  $ProviderElement<ClearCartUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ClearCartUseCase create(Ref ref) {
    return clearCartUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClearCartUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClearCartUseCase>(value),
    );
  }
}

String _$clearCartUseCaseHash() => r'f79e9d78f711dd14be39664b96a0d54695c080d7';

@ProviderFor(syncCartUseCase)
final syncCartUseCaseProvider = SyncCartUseCaseProvider._();

final class SyncCartUseCaseProvider
    extends
        $FunctionalProvider<SyncCartUseCase, SyncCartUseCase, SyncCartUseCase>
    with $Provider<SyncCartUseCase> {
  SyncCartUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncCartUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncCartUseCaseHash();

  @$internal
  @override
  $ProviderElement<SyncCartUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncCartUseCase create(Ref ref) {
    return syncCartUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncCartUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncCartUseCase>(value),
    );
  }
}

String _$syncCartUseCaseHash() => r'a6a854eadb409eea9c04e9276f5db3d3961d6686';
