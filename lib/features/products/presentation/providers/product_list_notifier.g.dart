// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_list_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProductListNotifier)
final productListProvider = ProductListNotifierFamily._();

final class ProductListNotifierProvider
    extends $NotifierProvider<ProductListNotifier, ProductListState> {
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

  ProductListNotifierProvider call(ProductQuery initialQuery) =>
      ProductListNotifierProvider._(argument: initialQuery, from: this);

  @override
  String toString() => r'productListProvider';
}

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
