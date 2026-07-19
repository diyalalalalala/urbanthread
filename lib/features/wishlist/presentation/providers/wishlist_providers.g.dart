// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Wiring for the wishlist feature.
///
/// The one edge that points at another feature is [cartLocalDataSourceProvider]:
/// move-to-cart answers with both halves, and the cart half is written to the
/// cart's own cache so the two never disagree on disk. The dependency runs
/// wishlist → cart only.

@ProviderFor(wishlistRemoteDataSource)
final wishlistRemoteDataSourceProvider = WishlistRemoteDataSourceProvider._();

/// Wiring for the wishlist feature.
///
/// The one edge that points at another feature is [cartLocalDataSourceProvider]:
/// move-to-cart answers with both halves, and the cart half is written to the
/// cart's own cache so the two never disagree on disk. The dependency runs
/// wishlist → cart only.

final class WishlistRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          WishlistRemoteDataSource,
          WishlistRemoteDataSource,
          WishlistRemoteDataSource
        >
    with $Provider<WishlistRemoteDataSource> {
  /// Wiring for the wishlist feature.
  ///
  /// The one edge that points at another feature is [cartLocalDataSourceProvider]:
  /// move-to-cart answers with both halves, and the cart half is written to the
  /// cart's own cache so the two never disagree on disk. The dependency runs
  /// wishlist → cart only.
  WishlistRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wishlistRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wishlistRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<WishlistRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WishlistRemoteDataSource create(Ref ref) {
    return wishlistRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WishlistRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WishlistRemoteDataSource>(value),
    );
  }
}

String _$wishlistRemoteDataSourceHash() =>
    r'20659cda1cf7818b12057737f2ba7313f89fe5f6';

@ProviderFor(wishlistLocalDataSource)
final wishlistLocalDataSourceProvider = WishlistLocalDataSourceProvider._();

final class WishlistLocalDataSourceProvider
    extends
        $FunctionalProvider<
          WishlistLocalDataSource,
          WishlistLocalDataSource,
          WishlistLocalDataSource
        >
    with $Provider<WishlistLocalDataSource> {
  WishlistLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wishlistLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wishlistLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<WishlistLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WishlistLocalDataSource create(Ref ref) {
    return wishlistLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WishlistLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WishlistLocalDataSource>(value),
    );
  }
}

String _$wishlistLocalDataSourceHash() =>
    r'49f42a6c30fe59571b1df303ae8c7c76310f1ebc';

/// The wishlist's slice of the shared `outbox` box.

@ProviderFor(wishlistOutbox)
final wishlistOutboxProvider = WishlistOutboxProvider._();

/// The wishlist's slice of the shared `outbox` box.

final class WishlistOutboxProvider
    extends $FunctionalProvider<OutboxQueue, OutboxQueue, OutboxQueue>
    with $Provider<OutboxQueue> {
  /// The wishlist's slice of the shared `outbox` box.
  WishlistOutboxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wishlistOutboxProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wishlistOutboxHash();

  @$internal
  @override
  $ProviderElement<OutboxQueue> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OutboxQueue create(Ref ref) {
    return wishlistOutbox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OutboxQueue value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OutboxQueue>(value),
    );
  }
}

String _$wishlistOutboxHash() => r'1227f27112d2ed672fe7b88ea2923d66afaf56cf';

@ProviderFor(wishlistRepository)
final wishlistRepositoryProvider = WishlistRepositoryProvider._();

final class WishlistRepositoryProvider
    extends
        $FunctionalProvider<
          WishlistRepository,
          WishlistRepository,
          WishlistRepository
        >
    with $Provider<WishlistRepository> {
  WishlistRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wishlistRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wishlistRepositoryHash();

  @$internal
  @override
  $ProviderElement<WishlistRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WishlistRepository create(Ref ref) {
    return wishlistRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WishlistRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WishlistRepository>(value),
    );
  }
}

String _$wishlistRepositoryHash() =>
    r'a509321679390fde59d87c2e6bdc3bd39166d33a';

@ProviderFor(getWishlistUseCase)
final getWishlistUseCaseProvider = GetWishlistUseCaseProvider._();

final class GetWishlistUseCaseProvider
    extends
        $FunctionalProvider<
          GetWishlistUseCase,
          GetWishlistUseCase,
          GetWishlistUseCase
        >
    with $Provider<GetWishlistUseCase> {
  GetWishlistUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getWishlistUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getWishlistUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetWishlistUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetWishlistUseCase create(Ref ref) {
    return getWishlistUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetWishlistUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetWishlistUseCase>(value),
    );
  }
}

String _$getWishlistUseCaseHash() =>
    r'c15f297ee7c067ef6dbb482c0d335ff4ea72fa2e';

@ProviderFor(addToWishlistUseCase)
final addToWishlistUseCaseProvider = AddToWishlistUseCaseProvider._();

final class AddToWishlistUseCaseProvider
    extends
        $FunctionalProvider<
          AddToWishlistUseCase,
          AddToWishlistUseCase,
          AddToWishlistUseCase
        >
    with $Provider<AddToWishlistUseCase> {
  AddToWishlistUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addToWishlistUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addToWishlistUseCaseHash();

  @$internal
  @override
  $ProviderElement<AddToWishlistUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AddToWishlistUseCase create(Ref ref) {
    return addToWishlistUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddToWishlistUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddToWishlistUseCase>(value),
    );
  }
}

String _$addToWishlistUseCaseHash() =>
    r'2457de118217e80a236c6bdd5dc6004d103636c4';

@ProviderFor(removeFromWishlistUseCase)
final removeFromWishlistUseCaseProvider = RemoveFromWishlistUseCaseProvider._();

final class RemoveFromWishlistUseCaseProvider
    extends
        $FunctionalProvider<
          RemoveFromWishlistUseCase,
          RemoveFromWishlistUseCase,
          RemoveFromWishlistUseCase
        >
    with $Provider<RemoveFromWishlistUseCase> {
  RemoveFromWishlistUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'removeFromWishlistUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$removeFromWishlistUseCaseHash();

  @$internal
  @override
  $ProviderElement<RemoveFromWishlistUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RemoveFromWishlistUseCase create(Ref ref) {
    return removeFromWishlistUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoveFromWishlistUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoveFromWishlistUseCase>(value),
    );
  }
}

String _$removeFromWishlistUseCaseHash() =>
    r'53bb552d552fa2b01cab0ba3485b9e38cfc13cd3';

@ProviderFor(clearWishlistUseCase)
final clearWishlistUseCaseProvider = ClearWishlistUseCaseProvider._();

final class ClearWishlistUseCaseProvider
    extends
        $FunctionalProvider<
          ClearWishlistUseCase,
          ClearWishlistUseCase,
          ClearWishlistUseCase
        >
    with $Provider<ClearWishlistUseCase> {
  ClearWishlistUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clearWishlistUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clearWishlistUseCaseHash();

  @$internal
  @override
  $ProviderElement<ClearWishlistUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClearWishlistUseCase create(Ref ref) {
    return clearWishlistUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClearWishlistUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClearWishlistUseCase>(value),
    );
  }
}

String _$clearWishlistUseCaseHash() =>
    r'bb20f0770c90b8d3d6ab78a90e244ef5004fc0c1';

@ProviderFor(moveWishlistItemToCartUseCase)
final moveWishlistItemToCartUseCaseProvider =
    MoveWishlistItemToCartUseCaseProvider._();

final class MoveWishlistItemToCartUseCaseProvider
    extends
        $FunctionalProvider<
          MoveWishlistItemToCartUseCase,
          MoveWishlistItemToCartUseCase,
          MoveWishlistItemToCartUseCase
        >
    with $Provider<MoveWishlistItemToCartUseCase> {
  MoveWishlistItemToCartUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moveWishlistItemToCartUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moveWishlistItemToCartUseCaseHash();

  @$internal
  @override
  $ProviderElement<MoveWishlistItemToCartUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MoveWishlistItemToCartUseCase create(Ref ref) {
    return moveWishlistItemToCartUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MoveWishlistItemToCartUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MoveWishlistItemToCartUseCase>(
        value,
      ),
    );
  }
}

String _$moveWishlistItemToCartUseCaseHash() =>
    r'129fccbef7869dc2e7f082813eee9f3ca2d59d8e';

@ProviderFor(checkWishlistUseCase)
final checkWishlistUseCaseProvider = CheckWishlistUseCaseProvider._();

final class CheckWishlistUseCaseProvider
    extends
        $FunctionalProvider<
          CheckWishlistUseCase,
          CheckWishlistUseCase,
          CheckWishlistUseCase
        >
    with $Provider<CheckWishlistUseCase> {
  CheckWishlistUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkWishlistUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkWishlistUseCaseHash();

  @$internal
  @override
  $ProviderElement<CheckWishlistUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CheckWishlistUseCase create(Ref ref) {
    return checkWishlistUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckWishlistUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckWishlistUseCase>(value),
    );
  }
}

String _$checkWishlistUseCaseHash() =>
    r'1e62ebe1d54fd9ba2621295537461a686aa2e5bf';

@ProviderFor(syncWishlistUseCase)
final syncWishlistUseCaseProvider = SyncWishlistUseCaseProvider._();

final class SyncWishlistUseCaseProvider
    extends
        $FunctionalProvider<
          SyncWishlistUseCase,
          SyncWishlistUseCase,
          SyncWishlistUseCase
        >
    with $Provider<SyncWishlistUseCase> {
  SyncWishlistUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncWishlistUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncWishlistUseCaseHash();

  @$internal
  @override
  $ProviderElement<SyncWishlistUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SyncWishlistUseCase create(Ref ref) {
    return syncWishlistUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncWishlistUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncWishlistUseCase>(value),
    );
  }
}

String _$syncWishlistUseCaseHash() =>
    r'477d826c3cce505da296e05bd184bf5782a96959';
