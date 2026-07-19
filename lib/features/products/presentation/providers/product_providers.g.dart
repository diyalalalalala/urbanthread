// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Wiring for the catalogue, kept apart from the notifiers so the object
/// graph reads in one place and a test can override a single edge — usually
/// [productRepositoryProvider].

@ProviderFor(productRemoteDataSource)
final productRemoteDataSourceProvider = ProductRemoteDataSourceProvider._();

/// Wiring for the catalogue, kept apart from the notifiers so the object
/// graph reads in one place and a test can override a single edge — usually
/// [productRepositoryProvider].

final class ProductRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          ProductRemoteDataSource,
          ProductRemoteDataSource,
          ProductRemoteDataSource
        >
    with $Provider<ProductRemoteDataSource> {
  /// Wiring for the catalogue, kept apart from the notifiers so the object
  /// graph reads in one place and a test can override a single edge — usually
  /// [productRepositoryProvider].
  ProductRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<ProductRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProductRemoteDataSource create(Ref ref) {
    return productRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductRemoteDataSource>(value),
    );
  }
}

String _$productRemoteDataSourceHash() =>
    r'804ca2442f25d7be4486d56c7ef9117141830f85';

@ProviderFor(reviewRemoteDataSource)
final reviewRemoteDataSourceProvider = ReviewRemoteDataSourceProvider._();

final class ReviewRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          ReviewRemoteDataSource,
          ReviewRemoteDataSource,
          ReviewRemoteDataSource
        >
    with $Provider<ReviewRemoteDataSource> {
  ReviewRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<ReviewRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReviewRemoteDataSource create(Ref ref) {
    return reviewRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReviewRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReviewRemoteDataSource>(value),
    );
  }
}

String _$reviewRemoteDataSourceHash() =>
    r'6cc1e8134ceabde424c943f8348f9e67c21a1176';

@ProviderFor(productLocalDataSource)
final productLocalDataSourceProvider = ProductLocalDataSourceProvider._();

final class ProductLocalDataSourceProvider
    extends
        $FunctionalProvider<
          ProductLocalDataSource,
          ProductLocalDataSource,
          ProductLocalDataSource
        >
    with $Provider<ProductLocalDataSource> {
  ProductLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<ProductLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProductLocalDataSource create(Ref ref) {
    return productLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductLocalDataSource>(value),
    );
  }
}

String _$productLocalDataSourceHash() =>
    r'a19d9b578bb985e11a33b69b016efba01100adad';

@ProviderFor(productRepository)
final productRepositoryProvider = ProductRepositoryProvider._();

final class ProductRepositoryProvider
    extends
        $FunctionalProvider<
          ProductRepository,
          ProductRepository,
          ProductRepository
        >
    with $Provider<ProductRepository> {
  ProductRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProductRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProductRepository create(Ref ref) {
    return productRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductRepository>(value),
    );
  }
}

String _$productRepositoryHash() => r'7ee030ae790b3b3e38991b83c9d9c1135d619006';

@ProviderFor(reviewRepository)
final reviewRepositoryProvider = ReviewRepositoryProvider._();

final class ReviewRepositoryProvider
    extends
        $FunctionalProvider<
          ReviewRepository,
          ReviewRepository,
          ReviewRepository
        >
    with $Provider<ReviewRepository> {
  ReviewRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReviewRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReviewRepository create(Ref ref) {
    return reviewRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReviewRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReviewRepository>(value),
    );
  }
}

String _$reviewRepositoryHash() => r'a07e5e1fef616b5c41eb249cd78b21ad07b0a922';

@ProviderFor(getProductsUseCase)
final getProductsUseCaseProvider = GetProductsUseCaseProvider._();

final class GetProductsUseCaseProvider
    extends
        $FunctionalProvider<
          GetProductsUseCase,
          GetProductsUseCase,
          GetProductsUseCase
        >
    with $Provider<GetProductsUseCase> {
  GetProductsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getProductsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getProductsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetProductsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetProductsUseCase create(Ref ref) {
    return getProductsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetProductsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetProductsUseCase>(value),
    );
  }
}

String _$getProductsUseCaseHash() =>
    r'0a0e0df9a5469dccdeba1936930f2b81df7d5ce1';

@ProviderFor(searchProductsUseCase)
final searchProductsUseCaseProvider = SearchProductsUseCaseProvider._();

final class SearchProductsUseCaseProvider
    extends
        $FunctionalProvider<
          SearchProductsUseCase,
          SearchProductsUseCase,
          SearchProductsUseCase
        >
    with $Provider<SearchProductsUseCase> {
  SearchProductsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchProductsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchProductsUseCaseHash();

  @$internal
  @override
  $ProviderElement<SearchProductsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SearchProductsUseCase create(Ref ref) {
    return searchProductsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchProductsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchProductsUseCase>(value),
    );
  }
}

String _$searchProductsUseCaseHash() =>
    r'a32a6b026f4e704c6783277ff1e0ec0091262c1f';

@ProviderFor(getProductFiltersUseCase)
final getProductFiltersUseCaseProvider = GetProductFiltersUseCaseProvider._();

final class GetProductFiltersUseCaseProvider
    extends
        $FunctionalProvider<
          GetProductFiltersUseCase,
          GetProductFiltersUseCase,
          GetProductFiltersUseCase
        >
    with $Provider<GetProductFiltersUseCase> {
  GetProductFiltersUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getProductFiltersUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getProductFiltersUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetProductFiltersUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetProductFiltersUseCase create(Ref ref) {
    return getProductFiltersUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetProductFiltersUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetProductFiltersUseCase>(value),
    );
  }
}

String _$getProductFiltersUseCaseHash() =>
    r'361432184f852acd6ee8c0a7b5c04e69f8f70275';

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
    r'26d63dbf1e0a6f1b8e02c3a1e9c4d492e3f2d3b2';

@ProviderFor(getProductDetailUseCase)
final getProductDetailUseCaseProvider = GetProductDetailUseCaseProvider._();

final class GetProductDetailUseCaseProvider
    extends
        $FunctionalProvider<
          GetProductDetailUseCase,
          GetProductDetailUseCase,
          GetProductDetailUseCase
        >
    with $Provider<GetProductDetailUseCase> {
  GetProductDetailUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getProductDetailUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getProductDetailUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetProductDetailUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetProductDetailUseCase create(Ref ref) {
    return getProductDetailUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetProductDetailUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetProductDetailUseCase>(value),
    );
  }
}

String _$getProductDetailUseCaseHash() =>
    r'aae166ee1a4432b24706635732e2433bb56966cb';

@ProviderFor(getRelatedProductsUseCase)
final getRelatedProductsUseCaseProvider = GetRelatedProductsUseCaseProvider._();

final class GetRelatedProductsUseCaseProvider
    extends
        $FunctionalProvider<
          GetRelatedProductsUseCase,
          GetRelatedProductsUseCase,
          GetRelatedProductsUseCase
        >
    with $Provider<GetRelatedProductsUseCase> {
  GetRelatedProductsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getRelatedProductsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getRelatedProductsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetRelatedProductsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetRelatedProductsUseCase create(Ref ref) {
    return getRelatedProductsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetRelatedProductsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetRelatedProductsUseCase>(value),
    );
  }
}

String _$getRelatedProductsUseCaseHash() =>
    r'29162e72e92d3d5cc50cc8118219cdbe5e793c38';

@ProviderFor(getFrequentlyBoughtTogetherUseCase)
final getFrequentlyBoughtTogetherUseCaseProvider =
    GetFrequentlyBoughtTogetherUseCaseProvider._();

final class GetFrequentlyBoughtTogetherUseCaseProvider
    extends
        $FunctionalProvider<
          GetFrequentlyBoughtTogetherUseCase,
          GetFrequentlyBoughtTogetherUseCase,
          GetFrequentlyBoughtTogetherUseCase
        >
    with $Provider<GetFrequentlyBoughtTogetherUseCase> {
  GetFrequentlyBoughtTogetherUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getFrequentlyBoughtTogetherUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$getFrequentlyBoughtTogetherUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetFrequentlyBoughtTogetherUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetFrequentlyBoughtTogetherUseCase create(Ref ref) {
    return getFrequentlyBoughtTogetherUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetFrequentlyBoughtTogetherUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetFrequentlyBoughtTogetherUseCase>(
        value,
      ),
    );
  }
}

String _$getFrequentlyBoughtTogetherUseCaseHash() =>
    r'c6901b32aed61d3041cb443207daa3c2433a6c7a';

@ProviderFor(refreshCatalogueUseCase)
final refreshCatalogueUseCaseProvider = RefreshCatalogueUseCaseProvider._();

final class RefreshCatalogueUseCaseProvider
    extends
        $FunctionalProvider<
          RefreshCatalogueUseCase,
          RefreshCatalogueUseCase,
          RefreshCatalogueUseCase
        >
    with $Provider<RefreshCatalogueUseCase> {
  RefreshCatalogueUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'refreshCatalogueUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$refreshCatalogueUseCaseHash();

  @$internal
  @override
  $ProviderElement<RefreshCatalogueUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RefreshCatalogueUseCase create(Ref ref) {
    return refreshCatalogueUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RefreshCatalogueUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RefreshCatalogueUseCase>(value),
    );
  }
}

String _$refreshCatalogueUseCaseHash() =>
    r'0cb27d6c5495f5ee129101f1f4f7cffeaf1cbf27';

@ProviderFor(getProductReviewsUseCase)
final getProductReviewsUseCaseProvider = GetProductReviewsUseCaseProvider._();

final class GetProductReviewsUseCaseProvider
    extends
        $FunctionalProvider<
          GetProductReviewsUseCase,
          GetProductReviewsUseCase,
          GetProductReviewsUseCase
        >
    with $Provider<GetProductReviewsUseCase> {
  GetProductReviewsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getProductReviewsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getProductReviewsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetProductReviewsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetProductReviewsUseCase create(Ref ref) {
    return getProductReviewsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetProductReviewsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetProductReviewsUseCase>(value),
    );
  }
}

String _$getProductReviewsUseCaseHash() =>
    r'32446186d63205bf6e30fe07d3846f42ce6dd399';

@ProviderFor(getProductReviewStatsUseCase)
final getProductReviewStatsUseCaseProvider =
    GetProductReviewStatsUseCaseProvider._();

final class GetProductReviewStatsUseCaseProvider
    extends
        $FunctionalProvider<
          GetProductReviewStatsUseCase,
          GetProductReviewStatsUseCase,
          GetProductReviewStatsUseCase
        >
    with $Provider<GetProductReviewStatsUseCase> {
  GetProductReviewStatsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getProductReviewStatsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getProductReviewStatsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetProductReviewStatsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetProductReviewStatsUseCase create(Ref ref) {
    return getProductReviewStatsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetProductReviewStatsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetProductReviewStatsUseCase>(value),
    );
  }
}

String _$getProductReviewStatsUseCaseHash() =>
    r'36a4d4a83cbbf66842b9eabd8eb4023df51fac96';

/// Facets for the filter sheet. Kept alive because the sheet is opened
/// repeatedly and the facet lists change on the scale of hours, not seconds.

@ProviderFor(productFilterFacets)
final productFilterFacetsProvider = ProductFilterFacetsProvider._();

/// Facets for the filter sheet. Kept alive because the sheet is opened
/// repeatedly and the facet lists change on the scale of hours, not seconds.

final class ProductFilterFacetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProductFilters>,
          ProductFilters,
          FutureOr<ProductFilters>
        >
    with $FutureModifier<ProductFilters>, $FutureProvider<ProductFilters> {
  /// Facets for the filter sheet. Kept alive because the sheet is opened
  /// repeatedly and the facet lists change on the scale of hours, not seconds.
  ProductFilterFacetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productFilterFacetsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productFilterFacetsHash();

  @$internal
  @override
  $FutureProviderElement<ProductFilters> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProductFilters> create(Ref ref) {
    return productFilterFacets(ref);
  }
}

String _$productFilterFacetsHash() =>
    r'010b4c11d36fa1a201b28d289f9b14a60a06d72d';

/// One curated collection. Family-keyed so the home page can mount all four
/// without them sharing a cache entry.

@ProviderFor(productCollection)
final productCollectionProvider = ProductCollectionFamily._();

/// One curated collection. Family-keyed so the home page can mount all four
/// without them sharing a cache entry.

final class ProductCollectionProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Product>>,
          List<Product>,
          FutureOr<List<Product>>
        >
    with $FutureModifier<List<Product>>, $FutureProvider<List<Product>> {
  /// One curated collection. Family-keyed so the home page can mount all four
  /// without them sharing a cache entry.
  ProductCollectionProvider._({
    required ProductCollectionFamily super.from,
    required (ProductCollection, {int limit}) super.argument,
  }) : super(
         retry: null,
         name: r'productCollectionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productCollectionHash();

  @override
  String toString() {
    return r'productCollectionProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Product>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Product>> create(Ref ref) {
    final argument = this.argument as (ProductCollection, {int limit});
    return productCollection(ref, argument.$1, limit: argument.limit);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductCollectionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productCollectionHash() => r'bd1b5c789d675ade034db2f5697a44188c6146cd';

/// One curated collection. Family-keyed so the home page can mount all four
/// without them sharing a cache entry.

final class ProductCollectionFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Product>>,
          (ProductCollection, {int limit})
        > {
  ProductCollectionFamily._()
    : super(
        retry: null,
        name: r'productCollectionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One curated collection. Family-keyed so the home page can mount all four
  /// without them sharing a cache entry.

  ProductCollectionProvider call(
    ProductCollection collection, {
    int limit = 10,
  }) => ProductCollectionProvider._(
    argument: (collection, limit: limit),
    from: this,
  );

  @override
  String toString() => r'productCollectionProvider';
}

/// Similar products for the detail page. Takes the product **id**, not the
/// slug — this route is id-based even though detail is not.

@ProviderFor(relatedProducts)
final relatedProductsProvider = RelatedProductsFamily._();

/// Similar products for the detail page. Takes the product **id**, not the
/// slug — this route is id-based even though detail is not.

final class RelatedProductsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Product>>,
          List<Product>,
          FutureOr<List<Product>>
        >
    with $FutureModifier<List<Product>>, $FutureProvider<List<Product>> {
  /// Similar products for the detail page. Takes the product **id**, not the
  /// slug — this route is id-based even though detail is not.
  RelatedProductsProvider._({
    required RelatedProductsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'relatedProductsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$relatedProductsHash();

  @override
  String toString() {
    return r'relatedProductsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Product>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Product>> create(Ref ref) {
    final argument = this.argument as String;
    return relatedProducts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RelatedProductsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$relatedProductsHash() => r'81b4aa45b03116c7c4a03bc0cac380f1eed3e33d';

/// Similar products for the detail page. Takes the product **id**, not the
/// slug — this route is id-based even though detail is not.

final class RelatedProductsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Product>>, String> {
  RelatedProductsFamily._()
    : super(
        retry: null,
        name: r'relatedProductsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Similar products for the detail page. Takes the product **id**, not the
  /// slug — this route is id-based even though detail is not.

  RelatedProductsProvider call(String productId) =>
      RelatedProductsProvider._(argument: productId, from: this);

  @override
  String toString() => r'relatedProductsProvider';
}

@ProviderFor(frequentlyBoughtTogether)
final frequentlyBoughtTogetherProvider = FrequentlyBoughtTogetherFamily._();

final class FrequentlyBoughtTogetherProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FrequentlyBoughtTogether>>,
          List<FrequentlyBoughtTogether>,
          FutureOr<List<FrequentlyBoughtTogether>>
        >
    with
        $FutureModifier<List<FrequentlyBoughtTogether>>,
        $FutureProvider<List<FrequentlyBoughtTogether>> {
  FrequentlyBoughtTogetherProvider._({
    required FrequentlyBoughtTogetherFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'frequentlyBoughtTogetherProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$frequentlyBoughtTogetherHash();

  @override
  String toString() {
    return r'frequentlyBoughtTogetherProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<FrequentlyBoughtTogether>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FrequentlyBoughtTogether>> create(Ref ref) {
    final argument = this.argument as String;
    return frequentlyBoughtTogether(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FrequentlyBoughtTogetherProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$frequentlyBoughtTogetherHash() =>
    r'd0dcbaab9e041186a203a0ead2d1906b3538be16';

final class FrequentlyBoughtTogetherFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<FrequentlyBoughtTogether>>,
          String
        > {
  FrequentlyBoughtTogetherFamily._()
    : super(
        retry: null,
        name: r'frequentlyBoughtTogetherProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FrequentlyBoughtTogetherProvider call(String productId) =>
      FrequentlyBoughtTogetherProvider._(argument: productId, from: this);

  @override
  String toString() => r'frequentlyBoughtTogetherProvider';
}

/// The live rating summary. Preferred over `product.rating`, which is a
/// denormalised copy that can lag a just-posted review.

@ProviderFor(productReviewStats)
final productReviewStatsProvider = ProductReviewStatsFamily._();

/// The live rating summary. Preferred over `product.rating`, which is a
/// denormalised copy that can lag a just-posted review.

final class ProductReviewStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReviewStats>,
          ReviewStats,
          FutureOr<ReviewStats>
        >
    with $FutureModifier<ReviewStats>, $FutureProvider<ReviewStats> {
  /// The live rating summary. Preferred over `product.rating`, which is a
  /// denormalised copy that can lag a just-posted review.
  ProductReviewStatsProvider._({
    required ProductReviewStatsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'productReviewStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productReviewStatsHash();

  @override
  String toString() {
    return r'productReviewStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ReviewStats> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReviewStats> create(Ref ref) {
    final argument = this.argument as String;
    return productReviewStats(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductReviewStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productReviewStatsHash() =>
    r'f8cbe6134b1bb7ab7cecf4e981203b2e80a6096a';

/// The live rating summary. Preferred over `product.rating`, which is a
/// denormalised copy that can lag a just-posted review.

final class ProductReviewStatsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ReviewStats>, String> {
  ProductReviewStatsFamily._()
    : super(
        retry: null,
        name: r'productReviewStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The live rating summary. Preferred over `product.rating`, which is a
  /// denormalised copy that can lag a just-posted review.

  ProductReviewStatsProvider call(String productId) =>
      ProductReviewStatsProvider._(argument: productId, from: this);

  @override
  String toString() => r'productReviewStatsProvider';
}
