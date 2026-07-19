// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_reviews_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads reviews for one product.
///
/// Kept separate from [ProductDetailNotifier] so a filter change on the
/// review list — "4 stars only" — does not re-render the gallery, the variant
/// selector and the recommendations above it.

@ProviderFor(ProductReviewsNotifier)
final productReviewsProvider = ProductReviewsNotifierFamily._();

/// Loads reviews for one product.
///
/// Kept separate from [ProductDetailNotifier] so a filter change on the
/// review list — "4 stars only" — does not re-render the gallery, the variant
/// selector and the recommendations above it.
final class ProductReviewsNotifierProvider
    extends $NotifierProvider<ProductReviewsNotifier, ProductReviewsState> {
  /// Loads reviews for one product.
  ///
  /// Kept separate from [ProductDetailNotifier] so a filter change on the
  /// review list — "4 stars only" — does not re-render the gallery, the variant
  /// selector and the recommendations above it.
  ProductReviewsNotifierProvider._({
    required ProductReviewsNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'productReviewsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productReviewsNotifierHash();

  @override
  String toString() {
    return r'productReviewsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProductReviewsNotifier create() => ProductReviewsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductReviewsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductReviewsState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProductReviewsNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productReviewsNotifierHash() =>
    r'55acacda94873b19830b151e019525fab9fec1cc';

/// Loads reviews for one product.
///
/// Kept separate from [ProductDetailNotifier] so a filter change on the
/// review list — "4 stars only" — does not re-render the gallery, the variant
/// selector and the recommendations above it.

final class ProductReviewsNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ProductReviewsNotifier,
          ProductReviewsState,
          ProductReviewsState,
          ProductReviewsState,
          String
        > {
  ProductReviewsNotifierFamily._()
    : super(
        retry: null,
        name: r'productReviewsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Loads reviews for one product.
  ///
  /// Kept separate from [ProductDetailNotifier] so a filter change on the
  /// review list — "4 stars only" — does not re-render the gallery, the variant
  /// selector and the recommendations above it.

  ProductReviewsNotifierProvider call(String productId) =>
      ProductReviewsNotifierProvider._(argument: productId, from: this);

  @override
  String toString() => r'productReviewsProvider';
}

/// Loads reviews for one product.
///
/// Kept separate from [ProductDetailNotifier] so a filter change on the
/// review list — "4 stars only" — does not re-render the gallery, the variant
/// selector and the recommendations above it.

abstract class _$ProductReviewsNotifier extends $Notifier<ProductReviewsState> {
  late final _$args = ref.$arg as String;
  String get productId => _$args;

  ProductReviewsState build(String productId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ProductReviewsState, ProductReviewsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProductReviewsState, ProductReviewsState>,
              ProductReviewsState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
