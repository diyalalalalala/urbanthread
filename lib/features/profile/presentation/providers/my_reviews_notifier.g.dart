// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_reviews_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MyReviewsNotifier)
final myReviewsProvider = MyReviewsNotifierProvider._();

final class MyReviewsNotifierProvider
    extends $AsyncNotifierProvider<MyReviewsNotifier, MyReviewsState> {
  MyReviewsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myReviewsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myReviewsNotifierHash();

  @$internal
  @override
  MyReviewsNotifier create() => MyReviewsNotifier();
}

String _$myReviewsNotifierHash() => r'f4ce72e40e6293e3b99a5e4b6a0c2fc2df51bd71';

abstract class _$MyReviewsNotifier extends $AsyncNotifier<MyReviewsState> {
  FutureOr<MyReviewsState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<MyReviewsState>, MyReviewsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MyReviewsState>, MyReviewsState>,
              AsyncValue<MyReviewsState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Delivered items the customer has not reviewed yet — the entry point to
/// `WriteReviewPage`.
///
/// Never paginated: the endpoint caps at 50 and returns a bare array.

@ProviderFor(ReviewableProductsNotifier)
final reviewableProductsProvider = ReviewableProductsNotifierProvider._();

/// Delivered items the customer has not reviewed yet — the entry point to
/// `WriteReviewPage`.
///
/// Never paginated: the endpoint caps at 50 and returns a bare array.
final class ReviewableProductsNotifierProvider
    extends
        $AsyncNotifierProvider<
          ReviewableProductsNotifier,
          List<ReviewableProduct>
        > {
  /// Delivered items the customer has not reviewed yet — the entry point to
  /// `WriteReviewPage`.
  ///
  /// Never paginated: the endpoint caps at 50 and returns a bare array.
  ReviewableProductsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewableProductsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewableProductsNotifierHash();

  @$internal
  @override
  ReviewableProductsNotifier create() => ReviewableProductsNotifier();
}

String _$reviewableProductsNotifierHash() =>
    r'c1338aa4d5bcc5649d20271afaec4119fb0e9775';

/// Delivered items the customer has not reviewed yet — the entry point to
/// `WriteReviewPage`.
///
/// Never paginated: the endpoint caps at 50 and returns a bare array.

abstract class _$ReviewableProductsNotifier
    extends $AsyncNotifier<List<ReviewableProduct>> {
  FutureOr<List<ReviewableProduct>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<ReviewableProduct>>,
              List<ReviewableProduct>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ReviewableProduct>>,
                List<ReviewableProduct>
              >,
              AsyncValue<List<ReviewableProduct>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
