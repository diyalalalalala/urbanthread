// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recently_viewed_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The last 20 products the customer opened.
///
/// There is no pagination to manage: the endpoint returns a bare, server-
/// capped array, so the whole list is one load.

@ProviderFor(RecentlyViewedNotifier)
final recentlyViewedProvider = RecentlyViewedNotifierProvider._();

/// The last 20 products the customer opened.
///
/// There is no pagination to manage: the endpoint returns a bare, server-
/// capped array, so the whole list is one load.
final class RecentlyViewedNotifierProvider
    extends
        $AsyncNotifierProvider<
          RecentlyViewedNotifier,
          List<RecentlyViewedItem>
        > {
  /// The last 20 products the customer opened.
  ///
  /// There is no pagination to manage: the endpoint returns a bare, server-
  /// capped array, so the whole list is one load.
  RecentlyViewedNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentlyViewedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentlyViewedNotifierHash();

  @$internal
  @override
  RecentlyViewedNotifier create() => RecentlyViewedNotifier();
}

String _$recentlyViewedNotifierHash() =>
    r'99b9ac347749a07f8f48a528fe2ffd50f1082c55';

/// The last 20 products the customer opened.
///
/// There is no pagination to manage: the endpoint returns a bare, server-
/// capped array, so the whole list is one load.

abstract class _$RecentlyViewedNotifier
    extends $AsyncNotifier<List<RecentlyViewedItem>> {
  FutureOr<List<RecentlyViewedItem>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<RecentlyViewedItem>>,
              List<RecentlyViewedItem>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<RecentlyViewedItem>>,
                List<RecentlyViewedItem>
              >,
              AsyncValue<List<RecentlyViewedItem>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
