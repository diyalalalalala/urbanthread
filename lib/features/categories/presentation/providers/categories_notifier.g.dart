// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CategoriesNotifier)
final categoriesProvider = CategoriesNotifierProvider._();

final class CategoriesNotifierProvider
    extends $NotifierProvider<CategoriesNotifier, CategoriesState> {
  CategoriesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriesNotifierHash();

  @$internal
  @override
  CategoriesNotifier create() => CategoriesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoriesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoriesState>(value),
    );
  }
}

String _$categoriesNotifierHash() =>
    r'c2d484ea2ab8489db97a66e2f403416abcf2ab10';

abstract class _$CategoriesNotifier extends $Notifier<CategoriesState> {
  CategoriesState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CategoriesState, CategoriesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CategoriesState, CategoriesState>,
              CategoriesState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(featuredCategoryNodes)
final featuredCategoryNodesProvider = FeaturedCategoryNodesProvider._();

final class FeaturedCategoryNodesProvider
    extends $FunctionalProvider<List<Category>, List<Category>, List<Category>>
    with $Provider<List<Category>> {
  FeaturedCategoryNodesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'featuredCategoryNodesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$featuredCategoryNodesHash();

  @$internal
  @override
  $ProviderElement<List<Category>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Category> create(Ref ref) {
    return featuredCategoryNodes(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Category> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Category>>(value),
    );
  }
}

String _$featuredCategoryNodesHash() =>
    r'a606bd65b7561c03f1d6424bd8830e864a642065';

@ProviderFor(featuredBrandsFromDirectory)
final featuredBrandsFromDirectoryProvider =
    FeaturedBrandsFromDirectoryProvider._();

final class FeaturedBrandsFromDirectoryProvider
    extends $FunctionalProvider<List<Brand>, List<Brand>, List<Brand>>
    with $Provider<List<Brand>> {
  FeaturedBrandsFromDirectoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'featuredBrandsFromDirectoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$featuredBrandsFromDirectoryHash();

  @$internal
  @override
  $ProviderElement<List<Brand>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Brand> create(Ref ref) {
    return featuredBrandsFromDirectory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Brand> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Brand>>(value),
    );
  }
}

String _$featuredBrandsFromDirectoryHash() =>
    r'8b309663402a21414e3d74a5e5d851dac3ea86b2';
