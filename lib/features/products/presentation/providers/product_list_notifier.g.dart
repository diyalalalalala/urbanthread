// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_list_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives [ProductListPage] and any other infinite catalogue grid.
///
/// Keyed by the query it starts from, so a category page, a brand page and
/// the all-products page are three independent instances that do not fight
/// over one another's scroll position. Changing sort or filters mutates the
/// query *inside* one instance rather than creating another — otherwise every
/// filter tweak would leak a provider that is never read again.

@ProviderFor(ProductListNotifier)
final productListProvider = ProductListNotifierFamily._();

/// Drives [ProductListPage] and any other infinite catalogue grid.
///
/// Keyed by the query it starts from, so a category page, a brand page and
/// the all-products page are three independent instances that do not fight
/// over one another's scroll position. Changing sort or filters mutates the
/// query *inside* one instance rather than creating another — otherwise every
/// filter tweak would leak a provider that is never read again.
final class ProductListNotifierProvider
    extends $NotifierProvider<ProductListNotifier, ProductListState> {
  /// Drives [ProductListPage] and any other infinite catalogue grid.
  ///
  /// Keyed by the query it starts from, so a category page, a brand page and
  /// the all-products page are three independent instances that do not fight
  /// over one another's scroll position. Changing sort or filters mutates the
  /// query *inside* one instance rather than creating another — otherwise every
  /// filter tweak would leak a provider that is never read again.
  ProductListNotifierProvider._({
    required ProductListNotifierFamily super.from,
    required ProductQuery super.argument,
  }) : super(
         retry: null,
         name: r'productListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productListNotifierHash();

  @override
  String toString() {
    return r'productListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProductListNotifier create() => ProductListNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductListState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProductListNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productListNotifierHash() =>
    r'edc26555b6759990c8f17aa529ec1759217ef407';

/// Drives [ProductListPage] and any other infinite catalogue grid.
///
/// Keyed by the query it starts from, so a category page, a brand page and
/// the all-products page are three independent instances that do not fight
/// over one another's scroll position. Changing sort or filters mutates the
/// query *inside* one instance rather than creating another — otherwise every
/// filter tweak would leak a provider that is never read again.

final class ProductListNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ProductListNotifier,
          ProductListState,
          ProductListState,
          ProductListState,
          ProductQuery
        > {
  ProductListNotifierFamily._()
    : super(
        retry: null,
        name: r'productListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Drives [ProductListPage] and any other infinite catalogue grid.
  ///
  /// Keyed by the query it starts from, so a category page, a brand page and
  /// the all-products page are three independent instances that do not fight
  /// over one another's scroll position. Changing sort or filters mutates the
  /// query *inside* one instance rather than creating another — otherwise every
  /// filter tweak would leak a provider that is never read again.

  ProductListNotifierProvider call(ProductQuery initialQuery) =>
      ProductListNotifierProvider._(argument: initialQuery, from: this);

  @override
  String toString() => r'productListProvider';
}

/// Drives [ProductListPage] and any other infinite catalogue grid.
///
/// Keyed by the query it starts from, so a category page, a brand page and
/// the all-products page are three independent instances that do not fight
/// over one another's scroll position. Changing sort or filters mutates the
/// query *inside* one instance rather than creating another — otherwise every
/// filter tweak would leak a provider that is never read again.

abstract class _$ProductListNotifier extends $Notifier<ProductListState> {
  late final _$args = ref.$arg as ProductQuery;
  ProductQuery get initialQuery => _$args;

  ProductListState build(ProductQuery initialQuery);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ProductListState, ProductListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProductListState, ProductListState>,
              ProductListState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
