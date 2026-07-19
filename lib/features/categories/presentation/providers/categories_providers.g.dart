// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Wiring for the taxonomy feature.
///
/// The datasources and repository are kept alive: the tree and the brand list
/// are read by both the categories screen and the home feed, and letting them
/// dispose between tab switches would rebuild the Retrofit client and re-open
/// the cache handle for no gain.

@ProviderFor(categoriesRemoteDataSource)
final categoriesRemoteDataSourceProvider =
    CategoriesRemoteDataSourceProvider._();

/// Wiring for the taxonomy feature.
///
/// The datasources and repository are kept alive: the tree and the brand list
/// are read by both the categories screen and the home feed, and letting them
/// dispose between tab switches would rebuild the Retrofit client and re-open
/// the cache handle for no gain.

final class CategoriesRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          CategoriesRemoteDataSource,
          CategoriesRemoteDataSource,
          CategoriesRemoteDataSource
        >
    with $Provider<CategoriesRemoteDataSource> {
  /// Wiring for the taxonomy feature.
  ///
  /// The datasources and repository are kept alive: the tree and the brand list
  /// are read by both the categories screen and the home feed, and letting them
  /// dispose between tab switches would rebuild the Retrofit client and re-open
  /// the cache handle for no gain.
  CategoriesRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriesRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriesRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<CategoriesRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CategoriesRemoteDataSource create(Ref ref) {
    return categoriesRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoriesRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoriesRemoteDataSource>(value),
    );
  }
}

String _$categoriesRemoteDataSourceHash() =>
    r'ce0f9ad895e28c0b8ea320d9be124b6121e49db1';

@ProviderFor(categoriesLocalDataSource)
final categoriesLocalDataSourceProvider = CategoriesLocalDataSourceProvider._();

final class CategoriesLocalDataSourceProvider
    extends
        $FunctionalProvider<
          CategoriesLocalDataSource,
          CategoriesLocalDataSource,
          CategoriesLocalDataSource
        >
    with $Provider<CategoriesLocalDataSource> {
  CategoriesLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriesLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriesLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<CategoriesLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CategoriesLocalDataSource create(Ref ref) {
    return categoriesLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoriesLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoriesLocalDataSource>(value),
    );
  }
}

String _$categoriesLocalDataSourceHash() =>
    r'cddaa29de7af9f0d984131c119a15a6b6d5afedf';

@ProviderFor(categoriesRepository)
final categoriesRepositoryProvider = CategoriesRepositoryProvider._();

final class CategoriesRepositoryProvider
    extends
        $FunctionalProvider<
          CategoriesRepository,
          CategoriesRepository,
          CategoriesRepository
        >
    with $Provider<CategoriesRepository> {
  CategoriesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriesRepositoryHash();

  @$internal
  @override
  $ProviderElement<CategoriesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CategoriesRepository create(Ref ref) {
    return categoriesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoriesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoriesRepository>(value),
    );
  }
}

String _$categoriesRepositoryHash() =>
    r'26baa2191885465dbb2a166f83958a7b411fab43';

@ProviderFor(getCategoriesUseCase)
final getCategoriesUseCaseProvider = GetCategoriesUseCaseProvider._();

final class GetCategoriesUseCaseProvider
    extends
        $FunctionalProvider<
          GetCategoriesUseCase,
          GetCategoriesUseCase,
          GetCategoriesUseCase
        >
    with $Provider<GetCategoriesUseCase> {
  GetCategoriesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getCategoriesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getCategoriesUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCategoriesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetCategoriesUseCase create(Ref ref) {
    return getCategoriesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCategoriesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCategoriesUseCase>(value),
    );
  }
}

String _$getCategoriesUseCaseHash() =>
    r'6f81ec56038f811c980c981121b8c60827fe77ba';

@ProviderFor(getCategoryTreeUseCase)
final getCategoryTreeUseCaseProvider = GetCategoryTreeUseCaseProvider._();

final class GetCategoryTreeUseCaseProvider
    extends
        $FunctionalProvider<
          GetCategoryTreeUseCase,
          GetCategoryTreeUseCase,
          GetCategoryTreeUseCase
        >
    with $Provider<GetCategoryTreeUseCase> {
  GetCategoryTreeUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getCategoryTreeUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getCategoryTreeUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCategoryTreeUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetCategoryTreeUseCase create(Ref ref) {
    return getCategoryTreeUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCategoryTreeUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCategoryTreeUseCase>(value),
    );
  }
}

String _$getCategoryTreeUseCaseHash() =>
    r'210ee0be9f99f930cc2043f0c5e8712e1e2003f0';

@ProviderFor(getCategoryUseCase)
final getCategoryUseCaseProvider = GetCategoryUseCaseProvider._();

final class GetCategoryUseCaseProvider
    extends
        $FunctionalProvider<
          GetCategoryUseCase,
          GetCategoryUseCase,
          GetCategoryUseCase
        >
    with $Provider<GetCategoryUseCase> {
  GetCategoryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getCategoryUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getCategoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCategoryUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetCategoryUseCase create(Ref ref) {
    return getCategoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCategoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCategoryUseCase>(value),
    );
  }
}

String _$getCategoryUseCaseHash() =>
    r'1de5bb62a9f607ec340208a85e193acc13e6ed16';

@ProviderFor(getFeaturedCategoriesUseCase)
final getFeaturedCategoriesUseCaseProvider =
    GetFeaturedCategoriesUseCaseProvider._();

final class GetFeaturedCategoriesUseCaseProvider
    extends
        $FunctionalProvider<
          GetFeaturedCategoriesUseCase,
          GetFeaturedCategoriesUseCase,
          GetFeaturedCategoriesUseCase
        >
    with $Provider<GetFeaturedCategoriesUseCase> {
  GetFeaturedCategoriesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getFeaturedCategoriesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getFeaturedCategoriesUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetFeaturedCategoriesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetFeaturedCategoriesUseCase create(Ref ref) {
    return getFeaturedCategoriesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetFeaturedCategoriesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetFeaturedCategoriesUseCase>(value),
    );
  }
}

String _$getFeaturedCategoriesUseCaseHash() =>
    r'a1c00b2ce989a8f7bc1410419b509c938ed6e181';

@ProviderFor(getBrandsUseCase)
final getBrandsUseCaseProvider = GetBrandsUseCaseProvider._();

final class GetBrandsUseCaseProvider
    extends
        $FunctionalProvider<
          GetBrandsUseCase,
          GetBrandsUseCase,
          GetBrandsUseCase
        >
    with $Provider<GetBrandsUseCase> {
  GetBrandsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getBrandsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getBrandsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetBrandsUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetBrandsUseCase create(Ref ref) {
    return getBrandsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetBrandsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetBrandsUseCase>(value),
    );
  }
}

String _$getBrandsUseCaseHash() => r'88e9fecb61e29b24f0691fa0e176eec4a29fe085';

@ProviderFor(getFeaturedBrandsUseCase)
final getFeaturedBrandsUseCaseProvider = GetFeaturedBrandsUseCaseProvider._();

final class GetFeaturedBrandsUseCaseProvider
    extends
        $FunctionalProvider<
          GetFeaturedBrandsUseCase,
          GetFeaturedBrandsUseCase,
          GetFeaturedBrandsUseCase
        >
    with $Provider<GetFeaturedBrandsUseCase> {
  GetFeaturedBrandsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getFeaturedBrandsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getFeaturedBrandsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetFeaturedBrandsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetFeaturedBrandsUseCase create(Ref ref) {
    return getFeaturedBrandsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetFeaturedBrandsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetFeaturedBrandsUseCase>(value),
    );
  }
}

String _$getFeaturedBrandsUseCaseHash() =>
    r'72f286752cda34627c8f46794fa8363fafa5e3fc';

@ProviderFor(getBrandUseCase)
final getBrandUseCaseProvider = GetBrandUseCaseProvider._();

final class GetBrandUseCaseProvider
    extends
        $FunctionalProvider<GetBrandUseCase, GetBrandUseCase, GetBrandUseCase>
    with $Provider<GetBrandUseCase> {
  GetBrandUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getBrandUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getBrandUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetBrandUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetBrandUseCase create(Ref ref) {
    return getBrandUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetBrandUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetBrandUseCase>(value),
    );
  }
}

String _$getBrandUseCaseHash() => r'1d6899947e4025b396791250f4e2bc1564ea9644';

/// One category with its immediate children, for a category landing screen.
///
/// Keyed on the slug-or-id the caller holds; the backend resolves either, so
/// there is no need for two providers.
///
/// One-shot detail reads surface as [AsyncValue], so the [Failure] is thrown
/// rather than returned. It stays a `Failure` on the way out — the UI matches
/// on `error is Failure` and hands it straight to `FailureView`, so nothing is
/// lost by the trip through the error channel.

@ProviderFor(categoryDetail)
final categoryDetailProvider = CategoryDetailFamily._();

/// One category with its immediate children, for a category landing screen.
///
/// Keyed on the slug-or-id the caller holds; the backend resolves either, so
/// there is no need for two providers.
///
/// One-shot detail reads surface as [AsyncValue], so the [Failure] is thrown
/// rather than returned. It stays a `Failure` on the way out — the UI matches
/// on `error is Failure` and hands it straight to `FailureView`, so nothing is
/// lost by the trip through the error channel.

final class CategoryDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<CategoryNode>,
          CategoryNode,
          FutureOr<CategoryNode>
        >
    with $FutureModifier<CategoryNode>, $FutureProvider<CategoryNode> {
  /// One category with its immediate children, for a category landing screen.
  ///
  /// Keyed on the slug-or-id the caller holds; the backend resolves either, so
  /// there is no need for two providers.
  ///
  /// One-shot detail reads surface as [AsyncValue], so the [Failure] is thrown
  /// rather than returned. It stays a `Failure` on the way out — the UI matches
  /// on `error is Failure` and hands it straight to `FailureView`, so nothing is
  /// lost by the trip through the error channel.
  CategoryDetailProvider._({
    required CategoryDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'categoryDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryDetailHash();

  @override
  String toString() {
    return r'categoryDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CategoryNode> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CategoryNode> create(Ref ref) {
    final argument = this.argument as String;
    return categoryDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryDetailHash() => r'6ca177b7b95e0bad1f6b621aebb4c0248f13b4c9';

/// One category with its immediate children, for a category landing screen.
///
/// Keyed on the slug-or-id the caller holds; the backend resolves either, so
/// there is no need for two providers.
///
/// One-shot detail reads surface as [AsyncValue], so the [Failure] is thrown
/// rather than returned. It stays a `Failure` on the way out — the UI matches
/// on `error is Failure` and hands it straight to `FailureView`, so nothing is
/// lost by the trip through the error channel.

final class CategoryDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CategoryNode>, String> {
  CategoryDetailFamily._()
    : super(
        retry: null,
        name: r'categoryDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One category with its immediate children, for a category landing screen.
  ///
  /// Keyed on the slug-or-id the caller holds; the backend resolves either, so
  /// there is no need for two providers.
  ///
  /// One-shot detail reads surface as [AsyncValue], so the [Failure] is thrown
  /// rather than returned. It stays a `Failure` on the way out — the UI matches
  /// on `error is Failure` and hands it straight to `FailureView`, so nothing is
  /// lost by the trip through the error channel.

  CategoryDetailProvider call(String slugOrId) =>
      CategoryDetailProvider._(argument: slugOrId, from: this);

  @override
  String toString() => r'categoryDetailProvider';
}

@ProviderFor(brandDetail)
final brandDetailProvider = BrandDetailFamily._();

final class BrandDetailProvider
    extends $FunctionalProvider<AsyncValue<Brand>, Brand, FutureOr<Brand>>
    with $FutureModifier<Brand>, $FutureProvider<Brand> {
  BrandDetailProvider._({
    required BrandDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'brandDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$brandDetailHash();

  @override
  String toString() {
    return r'brandDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Brand> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Brand> create(Ref ref) {
    final argument = this.argument as String;
    return brandDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BrandDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$brandDetailHash() => r'c721e16a253bdda4ebf9675d389e38225f4abff8';

final class BrandDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Brand>, String> {
  BrandDetailFamily._()
    : super(
        retry: null,
        name: r'brandDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BrandDetailProvider call(String slugOrId) =>
      BrandDetailProvider._(argument: slugOrId, from: this);

  @override
  String toString() => r'brandDetailProvider';
}

/// The direct children of a category, paged.
///
/// Used by the two-pane browser when a branch is deep enough that the tree
/// response alone would be an awkward amount to render at once.

@ProviderFor(categoryChildren)
final categoryChildrenProvider = CategoryChildrenFamily._();

/// The direct children of a category, paged.
///
/// Used by the two-pane browser when a branch is deep enough that the tree
/// response alone would be an awkward amount to render at once.

final class CategoryChildrenProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Category>>,
          List<Category>,
          FutureOr<List<Category>>
        >
    with $FutureModifier<List<Category>>, $FutureProvider<List<Category>> {
  /// The direct children of a category, paged.
  ///
  /// Used by the two-pane browser when a branch is deep enough that the tree
  /// response alone would be an awkward amount to render at once.
  CategoryChildrenProvider._({
    required CategoryChildrenFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'categoryChildrenProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryChildrenHash();

  @override
  String toString() {
    return r'categoryChildrenProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Category>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Category>> create(Ref ref) {
    final argument = this.argument as String;
    return categoryChildren(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryChildrenProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryChildrenHash() => r'62dfc2eb6601b973cb751806b2eb5c02555f2be5';

/// The direct children of a category, paged.
///
/// Used by the two-pane browser when a branch is deep enough that the tree
/// response alone would be an awkward amount to render at once.

final class CategoryChildrenFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Category>>, String> {
  CategoryChildrenFamily._()
    : super(
        retry: null,
        name: r'categoryChildrenProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The direct children of a category, paged.
  ///
  /// Used by the two-pane browser when a branch is deep enough that the tree
  /// response alone would be an awkward amount to render at once.

  CategoryChildrenProvider call(String parentId) =>
      CategoryChildrenProvider._(argument: parentId, from: this);

  @override
  String toString() => r'categoryChildrenProvider';
}
