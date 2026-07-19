// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_feed_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The single source of truth for the storefront.
///
/// Read as `homeFeedProvider` — the generator strips the `Notifier` suffix.
///
/// One provider for six endpoints, rather than six providers the page
/// composes. The rails have to load *together* (`Future.wait`, inside
/// [GetHomeFeedUseCase]) and they have to degrade *independently*, and both
/// properties are much easier to guarantee in one place than to reconstruct
/// from six `AsyncValue`s that each know only about themselves.
///
/// The sequence on every launch:
///
/// 1. Read the whole feed off disk synchronously and return it — the screen's
///    first frame is already populated, or shows a skeleton only if this is
///    genuinely the first ever launch.
/// 2. Fire all six requests concurrently in the background.
/// 3. Merge what came back over what was showing, keeping the old contents of
///    any section that failed.
///
/// Offline, step 2 fails fast (the repositories do not attempt a request
/// without a connection) and step 3 is a no-op, so the cached storefront just
/// stays on screen. That is the product requirement, implemented rather than
/// approximated.

@ProviderFor(HomeFeedNotifier)
final homeFeedProvider = HomeFeedNotifierProvider._();

/// The single source of truth for the storefront.
///
/// Read as `homeFeedProvider` — the generator strips the `Notifier` suffix.
///
/// One provider for six endpoints, rather than six providers the page
/// composes. The rails have to load *together* (`Future.wait`, inside
/// [GetHomeFeedUseCase]) and they have to degrade *independently*, and both
/// properties are much easier to guarantee in one place than to reconstruct
/// from six `AsyncValue`s that each know only about themselves.
///
/// The sequence on every launch:
///
/// 1. Read the whole feed off disk synchronously and return it — the screen's
///    first frame is already populated, or shows a skeleton only if this is
///    genuinely the first ever launch.
/// 2. Fire all six requests concurrently in the background.
/// 3. Merge what came back over what was showing, keeping the old contents of
///    any section that failed.
///
/// Offline, step 2 fails fast (the repositories do not attempt a request
/// without a connection) and step 3 is a no-op, so the cached storefront just
/// stays on screen. That is the product requirement, implemented rather than
/// approximated.
final class HomeFeedNotifierProvider
    extends $NotifierProvider<HomeFeedNotifier, HomeFeedState> {
  /// The single source of truth for the storefront.
  ///
  /// Read as `homeFeedProvider` — the generator strips the `Notifier` suffix.
  ///
  /// One provider for six endpoints, rather than six providers the page
  /// composes. The rails have to load *together* (`Future.wait`, inside
  /// [GetHomeFeedUseCase]) and they have to degrade *independently*, and both
  /// properties are much easier to guarantee in one place than to reconstruct
  /// from six `AsyncValue`s that each know only about themselves.
  ///
  /// The sequence on every launch:
  ///
  /// 1. Read the whole feed off disk synchronously and return it — the screen's
  ///    first frame is already populated, or shows a skeleton only if this is
  ///    genuinely the first ever launch.
  /// 2. Fire all six requests concurrently in the background.
  /// 3. Merge what came back over what was showing, keeping the old contents of
  ///    any section that failed.
  ///
  /// Offline, step 2 fails fast (the repositories do not attempt a request
  /// without a connection) and step 3 is a no-op, so the cached storefront just
  /// stays on screen. That is the product requirement, implemented rather than
  /// approximated.
  HomeFeedNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeFeedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeFeedNotifierHash();

  @$internal
  @override
  HomeFeedNotifier create() => HomeFeedNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeFeedState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeFeedState>(value),
    );
  }
}

String _$homeFeedNotifierHash() => r'445bd89a9a2089ca24e9e2ba7091088a3121923d';

/// The single source of truth for the storefront.
///
/// Read as `homeFeedProvider` — the generator strips the `Notifier` suffix.
///
/// One provider for six endpoints, rather than six providers the page
/// composes. The rails have to load *together* (`Future.wait`, inside
/// [GetHomeFeedUseCase]) and they have to degrade *independently*, and both
/// properties are much easier to guarantee in one place than to reconstruct
/// from six `AsyncValue`s that each know only about themselves.
///
/// The sequence on every launch:
///
/// 1. Read the whole feed off disk synchronously and return it — the screen's
///    first frame is already populated, or shows a skeleton only if this is
///    genuinely the first ever launch.
/// 2. Fire all six requests concurrently in the background.
/// 3. Merge what came back over what was showing, keeping the old contents of
///    any section that failed.
///
/// Offline, step 2 fails fast (the repositories do not attempt a request
/// without a connection) and step 3 is a no-op, so the cached storefront just
/// stays on screen. That is the product requirement, implemented rather than
/// approximated.

abstract class _$HomeFeedNotifier extends $Notifier<HomeFeedState> {
  HomeFeedState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HomeFeedState, HomeFeedState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HomeFeedState, HomeFeedState>,
              HomeFeedState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Whether the storefront currently has nothing but cached content.
///
/// A derived provider rather than a `.select()` — Riverpod 3 does not offer
/// `select` on a generated notifier provider, and since [HomeFeedState] is
/// Equatable an unchanged value already does not rebuild.

@ProviderFor(isHomeFeedStale)
final isHomeFeedStaleProvider = IsHomeFeedStaleProvider._();

/// Whether the storefront currently has nothing but cached content.
///
/// A derived provider rather than a `.select()` — Riverpod 3 does not offer
/// `select` on a generated notifier provider, and since [HomeFeedState] is
/// Equatable an unchanged value already does not rebuild.

final class IsHomeFeedStaleProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the storefront currently has nothing but cached content.
  ///
  /// A derived provider rather than a `.select()` — Riverpod 3 does not offer
  /// `select` on a generated notifier provider, and since [HomeFeedState] is
  /// Equatable an unchanged value already does not rebuild.
  IsHomeFeedStaleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isHomeFeedStaleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isHomeFeedStaleHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isHomeFeedStale(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isHomeFeedStaleHash() => r'17b609ac9e5928af638b52a5fcf6c6e6e4a088d5';
