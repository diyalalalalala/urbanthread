// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Wiring for search.
///
/// The search *results* come from the catalogue's own
/// `SearchProductsUseCase` — this feature owns the screen and the history,
/// not a second copy of the product API. Only the history has its own
/// repository here.

@ProviderFor(searchHistoryRepository)
final searchHistoryRepositoryProvider = SearchHistoryRepositoryProvider._();

/// Wiring for search.
///
/// The search *results* come from the catalogue's own
/// `SearchProductsUseCase` — this feature owns the screen and the history,
/// not a second copy of the product API. Only the history has its own
/// repository here.

final class SearchHistoryRepositoryProvider
    extends
        $FunctionalProvider<
          SearchHistoryRepository,
          SearchHistoryRepository,
          SearchHistoryRepository
        >
    with $Provider<SearchHistoryRepository> {
  /// Wiring for search.
  ///
  /// The search *results* come from the catalogue's own
  /// `SearchProductsUseCase` — this feature owns the screen and the history,
  /// not a second copy of the product API. Only the history has its own
  /// repository here.
  SearchHistoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchHistoryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchHistoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<SearchHistoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SearchHistoryRepository create(Ref ref) {
    return searchHistoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchHistoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchHistoryRepository>(value),
    );
  }
}

String _$searchHistoryRepositoryHash() =>
    r'416cbc7c0ec236807361a42737a400cbde24be12';

@ProviderFor(getSearchHistoryUseCase)
final getSearchHistoryUseCaseProvider = GetSearchHistoryUseCaseProvider._();

final class GetSearchHistoryUseCaseProvider
    extends
        $FunctionalProvider<
          GetSearchHistoryUseCase,
          GetSearchHistoryUseCase,
          GetSearchHistoryUseCase
        >
    with $Provider<GetSearchHistoryUseCase> {
  GetSearchHistoryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getSearchHistoryUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getSearchHistoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetSearchHistoryUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetSearchHistoryUseCase create(Ref ref) {
    return getSearchHistoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetSearchHistoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetSearchHistoryUseCase>(value),
    );
  }
}

String _$getSearchHistoryUseCaseHash() =>
    r'e2d35b6884f96d35d8d3f16719a9266bdeccb489';

@ProviderFor(addSearchTermUseCase)
final addSearchTermUseCaseProvider = AddSearchTermUseCaseProvider._();

final class AddSearchTermUseCaseProvider
    extends
        $FunctionalProvider<
          AddSearchTermUseCase,
          AddSearchTermUseCase,
          AddSearchTermUseCase
        >
    with $Provider<AddSearchTermUseCase> {
  AddSearchTermUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addSearchTermUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addSearchTermUseCaseHash();

  @$internal
  @override
  $ProviderElement<AddSearchTermUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AddSearchTermUseCase create(Ref ref) {
    return addSearchTermUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddSearchTermUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddSearchTermUseCase>(value),
    );
  }
}

String _$addSearchTermUseCaseHash() =>
    r'd05171cf2c19b7e0f87fe2d2d9517aad0bf98033';

@ProviderFor(removeSearchTermUseCase)
final removeSearchTermUseCaseProvider = RemoveSearchTermUseCaseProvider._();

final class RemoveSearchTermUseCaseProvider
    extends
        $FunctionalProvider<
          RemoveSearchTermUseCase,
          RemoveSearchTermUseCase,
          RemoveSearchTermUseCase
        >
    with $Provider<RemoveSearchTermUseCase> {
  RemoveSearchTermUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'removeSearchTermUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$removeSearchTermUseCaseHash();

  @$internal
  @override
  $ProviderElement<RemoveSearchTermUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RemoveSearchTermUseCase create(Ref ref) {
    return removeSearchTermUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoveSearchTermUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoveSearchTermUseCase>(value),
    );
  }
}

String _$removeSearchTermUseCaseHash() =>
    r'08cc15298499728889c74f396e818cb817e46083';

@ProviderFor(clearSearchHistoryUseCase)
final clearSearchHistoryUseCaseProvider = ClearSearchHistoryUseCaseProvider._();

final class ClearSearchHistoryUseCaseProvider
    extends
        $FunctionalProvider<
          ClearSearchHistoryUseCase,
          ClearSearchHistoryUseCase,
          ClearSearchHistoryUseCase
        >
    with $Provider<ClearSearchHistoryUseCase> {
  ClearSearchHistoryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clearSearchHistoryUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clearSearchHistoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<ClearSearchHistoryUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClearSearchHistoryUseCase create(Ref ref) {
    return clearSearchHistoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClearSearchHistoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClearSearchHistoryUseCase>(value),
    );
  }
}

String _$clearSearchHistoryUseCaseHash() =>
    r'fa489fafc3137f84fb478d8d51f3bed049e88c9d';
