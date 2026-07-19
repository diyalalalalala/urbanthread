// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_detail_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads a product page by slug and tracks the variant selection on it.

@ProviderFor(ProductDetailNotifier)
final productDetailProvider = ProductDetailNotifierFamily._();

/// Loads a product page by slug and tracks the variant selection on it.
final class ProductDetailNotifierProvider
    extends $NotifierProvider<ProductDetailNotifier, ProductDetailState> {
  /// Loads a product page by slug and tracks the variant selection on it.
  ProductDetailNotifierProvider._({
    required ProductDetailNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'productDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productDetailNotifierHash();

  @override
  String toString() {
    return r'productDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProductDetailNotifier create() => ProductDetailNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductDetailState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProductDetailNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productDetailNotifierHash() =>
    r'ff1b55be096161787489f1afc8f2e369c9c84e73';

/// Loads a product page by slug and tracks the variant selection on it.

final class ProductDetailNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ProductDetailNotifier,
          ProductDetailState,
          ProductDetailState,
          ProductDetailState,
          String
        > {
  ProductDetailNotifierFamily._()
    : super(
        retry: null,
        name: r'productDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Loads a product page by slug and tracks the variant selection on it.

  ProductDetailNotifierProvider call(String slug) =>
      ProductDetailNotifierProvider._(argument: slug, from: this);

  @override
  String toString() => r'productDetailProvider';
}

/// Loads a product page by slug and tracks the variant selection on it.

abstract class _$ProductDetailNotifier extends $Notifier<ProductDetailState> {
  late final _$args = ref.$arg as String;
  String get slug => _$args;

  ProductDetailState build(String slug);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ProductDetailState, ProductDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProductDetailState, ProductDetailState>,
              ProductDetailState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
