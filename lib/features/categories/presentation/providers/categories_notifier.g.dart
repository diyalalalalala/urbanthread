// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the categories screen: the taxonomy tree and the brand directory.
///
/// The generator strips the `Notifier` suffix, so this is read as
/// `categoriesProvider`.
///
/// Two loads, one await. They are independent endpoints and neither depends
/// on the other's result, so running them serially would double the time to
/// first paint for no benefit — and would let a slow `/brands` hold the
/// taxonomy hostage.

@ProviderFor(CategoriesNotifier)
final categoriesProvider = CategoriesNotifierProvider._();

/// Drives the categories screen: the taxonomy tree and the brand directory.
///
/// The generator strips the `Notifier` suffix, so this is read as
/// `categoriesProvider`.
///
/// Two loads, one await. They are independent endpoints and neither depends
/// on the other's result, so running them serially would double the time to
/// first paint for no benefit — and would let a slow `/brands` hold the
/// taxonomy hostage.
final class CategoriesNotifierProvider
    extends $NotifierProvider<CategoriesNotifier, CategoriesState> {
  /// Drives the categories screen: the taxonomy tree and the brand directory.
  ///
  /// The generator strips the `Notifier` suffix, so this is read as
  /// `categoriesProvider`.
  ///
  /// Two loads, one await. They are independent endpoints and neither depends
  /// on the other's result, so running them serially would double the time to
  /// first paint for no benefit — and would let a slow `/brands` hold the
  /// taxonomy hostage.
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

/// Drives the categories screen: the taxonomy tree and the brand directory.
///
/// The generator strips the `Notifier` suffix, so this is read as
/// `categoriesProvider`.
///
/// Two loads, one await. They are independent endpoints and neither depends
/// on the other's result, so running them serially would double the time to
/// first paint for no benefit — and would let a slow `/brands` hold the
/// taxonomy hostage.

abstract class _$CategoriesNotifier extends $Notifier<CategoriesState> {
  CategoriesState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CategoriesState, CategoriesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CategoriesState, CategoriesState>,
              CategoriesState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The featured slice of the taxonomy, derived rather than re-fetched.
///
/// A separate `@riverpod` function instead of a `.select()` on the notifier:
/// Riverpod 3 does not offer `select` on a generated notifier provider, and a
/// derived provider only re-emits when its own output changes, which is the
/// same rebuild saving with less ceremony.

@ProviderFor(featuredCategoryNodes)
final featuredCategoryNodesProvider = FeaturedCategoryNodesProvider._();

/// The featured slice of the taxonomy, derived rather than re-fetched.
///
/// A separate `@riverpod` function instead of a `.select()` on the notifier:
/// Riverpod 3 does not offer `select` on a generated notifier provider, and a
/// derived provider only re-emits when its own output changes, which is the
/// same rebuild saving with less ceremony.

final class FeaturedCategoryNodesProvider
    extends $FunctionalProvider<List<Category>, List<Category>, List<Category>>
    with $Provider<List<Category>> {
  /// The featured slice of the taxonomy, derived rather than re-fetched.
  ///
  /// A separate `@riverpod` function instead of a `.select()` on the notifier:
  /// Riverpod 3 does not offer `select` on a generated notifier provider, and a
  /// derived provider only re-emits when its own output changes, which is the
  /// same rebuild saving with less ceremony.
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

/// Brands flagged as featured, off the already-loaded directory.

@ProviderFor(featuredBrandsFromDirectory)
final featuredBrandsFromDirectoryProvider =
    FeaturedBrandsFromDirectoryProvider._();

/// Brands flagged as featured, off the already-loaded directory.

final class FeaturedBrandsFromDirectoryProvider
    extends $FunctionalProvider<List<Brand>, List<Brand>, List<Brand>>
    with $Provider<List<Brand>> {
  /// Brands flagged as featured, off the already-loaded directory.
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
