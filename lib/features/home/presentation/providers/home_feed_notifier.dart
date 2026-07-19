import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../domain/entities/home_feed.dart';
import '../../domain/entities/home_product.dart';
import '../../domain/usecases/get_home_feed_usecase.dart';
import 'home_feed_state.dart';
import 'home_providers.dart';

part 'home_feed_notifier.g.dart';

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
@riverpod
class HomeFeedNotifier extends _$HomeFeedNotifier {
  /// Cards per rail. Ten is the server default and fills a horizontal strip
  /// on every supported width.
  static const railSize = 10;

  /// Set from `ref.onDispose`. Six requests can still be in flight when the
  /// user navigates away, and assigning to `state` afterwards throws.
  bool _disposed = false;

  @override
  HomeFeedState build() {
    ref.onDispose(() => _disposed = true);

    final cached = ref.watch(readCachedHomeFeedUseCaseProvider)();

    // Not awaited, and careful to touch `state` only after its first
    // suspension — reading `state` while `build` is still running is an
    // error.
    unawaited(_fetch());

    return cached.hasContent
        ? HomeFeedState.fromCache(cached)
        : const HomeFeedState.loading();
  }

  /// Re-fetches every rail. Wired to pull-to-refresh.
  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true);
    await _fetch();
  }

  /// Reloads a single rail, for the retry affordance on a section that failed
  /// while its neighbours succeeded. Refreshing all six to fix one would
  /// visibly reshuffle the rest of the screen.
  Future<void> refreshRail(HomeCollection collection) async {
    final result = await ref.read(getProductCollectionUseCaseProvider)(
      ProductCollectionParams(collection, limit: railSize),
    );
    if (_disposed) return;

    final section = switch (result) {
      Success(:final value) => HomeSection<HomeProduct>(items: value),
      FailureResult(:final failure) =>
        state.feed.rail(collection).copyWith(failure: failure),
    };

    state = state.copyWith(
      feed: switch (collection) {
        HomeCollection.newArrivals => state.feed.copyWith(newArrivals: section),
        HomeCollection.trending => state.feed.copyWith(trending: section),
        HomeCollection.featured => state.feed.copyWith(featured: section),
        HomeCollection.bestSellers => state.feed.copyWith(bestSellers: section),
      },
    );
  }

  Future<void> _fetch() async {
    final result = await ref.read(getHomeFeedUseCaseProvider)(
      const HomeFeedParams(productLimit: railSize),
    );
    if (_disposed) return;

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          // Merge rather than replace: a section that failed keeps whatever
          // it was already showing instead of blanking.
          feed: state.feed.mergeWith(value),
          isLoading: false,
          isRefreshing: false,
          isFromCache: false,
        );
      case FailureResult(:final failure):
        // Every section of the *fresh* feed came back empty. That does not
        // mean the screen should empty: the use case only sees this request,
        // while `state` may still be holding a perfectly good cached feed
        // from step 1. Blanking it here would turn "the refresh failed" into
        // "your storefront is gone", which is precisely the regression the
        // offline requirement is about.
        if (state.hasContent) {
          state = state.copyWith(isLoading: false, isRefreshing: false);
          return;
        }
        state = HomeFeedState(
          feed: HomeFeed(
            newArrivals: HomeSection<HomeProduct>.failed(failure),
          ),
        );
    }
  }
}

/// Whether the storefront currently has nothing but cached content.
///
/// A derived provider rather than a `.select()` — Riverpod 3 does not offer
/// `select` on a generated notifier provider, and since [HomeFeedState] is
/// Equatable an unchanged value already does not rebuild.
@riverpod
bool isHomeFeedStale(Ref ref) => ref.watch(homeFeedProvider).isFromCache;
