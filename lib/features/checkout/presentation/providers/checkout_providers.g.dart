// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Wiring for the checkout feature.
///
/// One datasource serves three route families — cart reads, coupons and the
/// address book — because checkout is the only screen that needs all three at
/// once, and splitting them would mean three Dio-backed objects for six
/// endpoints.

@ProviderFor(checkoutRemoteDataSource)
final checkoutRemoteDataSourceProvider = CheckoutRemoteDataSourceProvider._();

/// Wiring for the checkout feature.
///
/// One datasource serves three route families — cart reads, coupons and the
/// address book — because checkout is the only screen that needs all three at
/// once, and splitting them would mean three Dio-backed objects for six
/// endpoints.

final class CheckoutRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          CheckoutRemoteDataSource,
          CheckoutRemoteDataSource,
          CheckoutRemoteDataSource
        >
    with $Provider<CheckoutRemoteDataSource> {
  /// Wiring for the checkout feature.
  ///
  /// One datasource serves three route families — cart reads, coupons and the
  /// address book — because checkout is the only screen that needs all three at
  /// once, and splitting them would mean three Dio-backed objects for six
  /// endpoints.
  CheckoutRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkoutRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkoutRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<CheckoutRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CheckoutRemoteDataSource create(Ref ref) {
    return checkoutRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckoutRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckoutRemoteDataSource>(value),
    );
  }
}

String _$checkoutRemoteDataSourceHash() =>
    r'98598e9682b93818ac91bfbfe62c8595a8d65f61';

@ProviderFor(checkoutRepository)
final checkoutRepositoryProvider = CheckoutRepositoryProvider._();

final class CheckoutRepositoryProvider
    extends
        $FunctionalProvider<
          CheckoutRepository,
          CheckoutRepository,
          CheckoutRepository
        >
    with $Provider<CheckoutRepository> {
  CheckoutRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkoutRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkoutRepositoryHash();

  @$internal
  @override
  $ProviderElement<CheckoutRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CheckoutRepository create(Ref ref) {
    return checkoutRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckoutRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckoutRepository>(value),
    );
  }
}

String _$checkoutRepositoryHash() =>
    r'1f04f2d9b4369f95d929372df1027f560b740f9d';

@ProviderFor(addressRepository)
final addressRepositoryProvider = AddressRepositoryProvider._();

final class AddressRepositoryProvider
    extends
        $FunctionalProvider<
          AddressRepository,
          AddressRepository,
          AddressRepository
        >
    with $Provider<AddressRepository> {
  AddressRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addressRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addressRepositoryHash();

  @$internal
  @override
  $ProviderElement<AddressRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AddressRepository create(Ref ref) {
    return addressRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddressRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddressRepository>(value),
    );
  }
}

String _$addressRepositoryHash() => r'cfd022ccb58a8d53a87c9082313afb91103b5ba6';

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
    r'281733a12f35cbc0a488d57f8bdad731c584e4f6';

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
    r'107b6847f337d04395fec78cc80fb156990ef638';

@ProviderFor(getAvailableCouponsUseCase)
final getAvailableCouponsUseCaseProvider =
    GetAvailableCouponsUseCaseProvider._();

final class GetAvailableCouponsUseCaseProvider
    extends
        $FunctionalProvider<
          GetAvailableCouponsUseCase,
          GetAvailableCouponsUseCase,
          GetAvailableCouponsUseCase
        >
    with $Provider<GetAvailableCouponsUseCase> {
  GetAvailableCouponsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getAvailableCouponsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getAvailableCouponsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetAvailableCouponsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetAvailableCouponsUseCase create(Ref ref) {
    return getAvailableCouponsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetAvailableCouponsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetAvailableCouponsUseCase>(value),
    );
  }
}

String _$getAvailableCouponsUseCaseHash() =>
    r'1a246e1ed596293e5f8214ff7db7a36bd23414c0';

@ProviderFor(validateCouponUseCase)
final validateCouponUseCaseProvider = ValidateCouponUseCaseProvider._();

final class ValidateCouponUseCaseProvider
    extends
        $FunctionalProvider<
          ValidateCouponUseCase,
          ValidateCouponUseCase,
          ValidateCouponUseCase
        >
    with $Provider<ValidateCouponUseCase> {
  ValidateCouponUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'validateCouponUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$validateCouponUseCaseHash();

  @$internal
  @override
  $ProviderElement<ValidateCouponUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ValidateCouponUseCase create(Ref ref) {
    return validateCouponUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ValidateCouponUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ValidateCouponUseCase>(value),
    );
  }
}

String _$validateCouponUseCaseHash() =>
    r'6b3af06ec2d5f9be859dbae17d1761d0f1eede69';

@ProviderFor(getAddressesUseCase)
final getAddressesUseCaseProvider = GetAddressesUseCaseProvider._();

final class GetAddressesUseCaseProvider
    extends
        $FunctionalProvider<
          GetAddressesUseCase,
          GetAddressesUseCase,
          GetAddressesUseCase
        >
    with $Provider<GetAddressesUseCase> {
  GetAddressesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getAddressesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getAddressesUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetAddressesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetAddressesUseCase create(Ref ref) {
    return getAddressesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetAddressesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetAddressesUseCase>(value),
    );
  }
}

String _$getAddressesUseCaseHash() =>
    r'6011f953082765858963ce3465d8f6ed3621e384';

@ProviderFor(addAddressUseCase)
final addAddressUseCaseProvider = AddAddressUseCaseProvider._();

final class AddAddressUseCaseProvider
    extends
        $FunctionalProvider<
          AddAddressUseCase,
          AddAddressUseCase,
          AddAddressUseCase
        >
    with $Provider<AddAddressUseCase> {
  AddAddressUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addAddressUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addAddressUseCaseHash();

  @$internal
  @override
  $ProviderElement<AddAddressUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AddAddressUseCase create(Ref ref) {
    return addAddressUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddAddressUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddAddressUseCase>(value),
    );
  }
}

String _$addAddressUseCaseHash() => r'8e9396ab7670111460a56bf972ea109e7040dcde';

@ProviderFor(updateAddressUseCase)
final updateAddressUseCaseProvider = UpdateAddressUseCaseProvider._();

final class UpdateAddressUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateAddressUseCase,
          UpdateAddressUseCase,
          UpdateAddressUseCase
        >
    with $Provider<UpdateAddressUseCase> {
  UpdateAddressUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateAddressUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateAddressUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateAddressUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateAddressUseCase create(Ref ref) {
    return updateAddressUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateAddressUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateAddressUseCase>(value),
    );
  }
}

String _$updateAddressUseCaseHash() =>
    r'3f64d4854fc735e72efb828151b797394938526e';

@ProviderFor(deleteAddressUseCase)
final deleteAddressUseCaseProvider = DeleteAddressUseCaseProvider._();

final class DeleteAddressUseCaseProvider
    extends
        $FunctionalProvider<
          DeleteAddressUseCase,
          DeleteAddressUseCase,
          DeleteAddressUseCase
        >
    with $Provider<DeleteAddressUseCase> {
  DeleteAddressUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteAddressUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteAddressUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteAddressUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteAddressUseCase create(Ref ref) {
    return deleteAddressUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteAddressUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteAddressUseCase>(value),
    );
  }
}

String _$deleteAddressUseCaseHash() =>
    r'a6aa4d7f8c0450ae339185c8f9706d61294fdacb';

@ProviderFor(setDefaultAddressUseCase)
final setDefaultAddressUseCaseProvider = SetDefaultAddressUseCaseProvider._();

final class SetDefaultAddressUseCaseProvider
    extends
        $FunctionalProvider<
          SetDefaultAddressUseCase,
          SetDefaultAddressUseCase,
          SetDefaultAddressUseCase
        >
    with $Provider<SetDefaultAddressUseCase> {
  SetDefaultAddressUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setDefaultAddressUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setDefaultAddressUseCaseHash();

  @$internal
  @override
  $ProviderElement<SetDefaultAddressUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SetDefaultAddressUseCase create(Ref ref) {
    return setDefaultAddressUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SetDefaultAddressUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SetDefaultAddressUseCase>(value),
    );
  }
}

String _$setDefaultAddressUseCaseHash() =>
    r'19c8851383c0a9b1fc0d9fa8aedcd2e196ea435d';
