// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Wiring for the storefront.
///
/// The feed use cases depend on the taxonomy feature's repository as well as
/// this one — the featured category and brand strips are that feature's data,
/// and pointing at its repository rather than re-fetching the same two
/// endpoints keeps one cache for those rows instead of two that drift.

@ProviderFor(homeRemoteDataSource)
final homeRemoteDataSourceProvider = HomeRemoteDataSourceProvider._();

/// Wiring for the storefront.
///
/// The feed use cases depend on the taxonomy feature's repository as well as
/// this one — the featured category and brand strips are that feature's data,
/// and pointing at its repository rather than re-fetching the same two
/// endpoints keeps one cache for those rows instead of two that drift.

final class HomeRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          HomeRemoteDataSource,
          HomeRemoteDataSource,
          HomeRemoteDataSource
        >
    with $Provider<HomeRemoteDataSource> {
  /// Wiring for the storefront.
  ///
  /// The feed use cases depend on the taxonomy feature's repository as well as
  /// this one — the featured category and brand strips are that feature's data,
  /// and pointing at its repository rather than re-fetching the same two
  /// endpoints keeps one cache for those rows instead of two that drift.
  HomeRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<HomeRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HomeRemoteDataSource create(Ref ref) {
    return homeRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeRemoteDataSource>(value),
    );
  }
}

String _$homeRemoteDataSourceHash() =>
    r'1c359eb5e598aceb3462cbda90e61bae806f6c34';

@ProviderFor(homeLocalDataSource)
final homeLocalDataSourceProvider = HomeLocalDataSourceProvider._();

final class HomeLocalDataSourceProvider
    extends
        $FunctionalProvider<
          HomeLocalDataSource,
          HomeLocalDataSource,
          HomeLocalDataSource
        >
    with $Provider<HomeLocalDataSource> {
  HomeLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<HomeLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HomeLocalDataSource create(Ref ref) {
    return homeLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeLocalDataSource>(value),
    );
  }
}

String _$homeLocalDataSourceHash() =>
    r'c4351998d1a4dfdd56404cdd4604a2da5f2460fa';

@ProviderFor(homeRepository)
final homeRepositoryProvider = HomeRepositoryProvider._();

final class HomeRepositoryProvider
    extends $FunctionalProvider<HomeRepository, HomeRepository, HomeRepository>
    with $Provider<HomeRepository> {
  HomeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeRepositoryHash();

  @$internal
  @override
  $ProviderElement<HomeRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HomeRepository create(Ref ref) {
    return homeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeRepository>(value),
    );
  }
}

String _$homeRepositoryHash() => r'0698417ac2eb821eb9407b8578b54a9d59fb9b2a';

@ProviderFor(getProductCollectionUseCase)
final getProductCollectionUseCaseProvider =
    GetProductCollectionUseCaseProvider._();

final class GetProductCollectionUseCaseProvider
    extends
        $FunctionalProvider<
          GetProductCollectionUseCase,
          GetProductCollectionUseCase,
          GetProductCollectionUseCase
        >
    with $Provider<GetProductCollectionUseCase> {
  GetProductCollectionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getProductCollectionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getProductCollectionUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetProductCollectionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetProductCollectionUseCase create(Ref ref) {
    return getProductCollectionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetProductCollectionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetProductCollectionUseCase>(value),
    );
  }
}

String _$getProductCollectionUseCaseHash() =>
    r'89789b3fb6941eca47012c841fa624339d8b6cca';

@ProviderFor(getHomeFeedUseCase)
final getHomeFeedUseCaseProvider = GetHomeFeedUseCaseProvider._();

final class GetHomeFeedUseCaseProvider
    extends
        $FunctionalProvider<
          GetHomeFeedUseCase,
          GetHomeFeedUseCase,
          GetHomeFeedUseCase
        >
    with $Provider<GetHomeFeedUseCase> {
  GetHomeFeedUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getHomeFeedUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getHomeFeedUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetHomeFeedUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetHomeFeedUseCase create(Ref ref) {
    return getHomeFeedUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetHomeFeedUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetHomeFeedUseCase>(value),
    );
  }
}

String _$getHomeFeedUseCaseHash() =>
    r'31a4472cf5938e55d816c658bfa4a4e1c35a36c9';

@ProviderFor(readCachedHomeFeedUseCase)
final readCachedHomeFeedUseCaseProvider = ReadCachedHomeFeedUseCaseProvider._();

final class ReadCachedHomeFeedUseCaseProvider
    extends
        $FunctionalProvider<
          ReadCachedHomeFeedUseCase,
          ReadCachedHomeFeedUseCase,
          ReadCachedHomeFeedUseCase
        >
    with $Provider<ReadCachedHomeFeedUseCase> {
  ReadCachedHomeFeedUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readCachedHomeFeedUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readCachedHomeFeedUseCaseHash();

  @$internal
  @override
  $ProviderElement<ReadCachedHomeFeedUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadCachedHomeFeedUseCase create(Ref ref) {
    return readCachedHomeFeedUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadCachedHomeFeedUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadCachedHomeFeedUseCase>(value),
    );
  }
}

String _$readCachedHomeFeedUseCaseHash() =>
    r'cadb082733cfbaa4635ab379c7c9d184b25cb720';
