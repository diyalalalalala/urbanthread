// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_feed_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HomeFeedNotifier)
final homeFeedProvider = HomeFeedNotifierProvider._();

final class HomeFeedNotifierProvider
    extends $NotifierProvider<HomeFeedNotifier, HomeFeedState> {
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

abstract class _$HomeFeedNotifier extends $Notifier<HomeFeedState> {
  HomeFeedState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<HomeFeedState, HomeFeedState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HomeFeedState, HomeFeedState>,
              HomeFeedState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(isHomeFeedStale)
final isHomeFeedStaleProvider = IsHomeFeedStaleProvider._();

final class IsHomeFeedStaleProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
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
