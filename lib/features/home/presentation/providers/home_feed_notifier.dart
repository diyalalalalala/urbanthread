import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../domain/entities/home_feed.dart';
import '../../domain/entities/home_product.dart';
import '../../domain/usecases/get_home_feed_usecase.dart';
import '../../domain/usecases/get_product_collection_usecase.dart';
import 'home_feed_state.dart';
import 'home_providers.dart';

part 'home_feed_notifier.g.dart';

@riverpod
class HomeFeedNotifier extends _$HomeFeedNotifier {
  static const railSize = 10;

  bool _disposed = false;

  @override
  HomeFeedState build() {
    ref.onDispose(() => _disposed = true);

    final cached = ref.watch(readCachedHomeFeedUseCaseProvider)();

    unawaited(_fetch());

    return cached.hasContent
        ? HomeFeedState.fromCache(cached)
        : const HomeFeedState.loading();
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true);
    await _fetch();
  }

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
          feed: state.feed.mergeWith(value),
          isLoading: false,
          isRefreshing: false,
          isFromCache: false,
        );
      case FailureResult(:final failure):
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

@riverpod
bool isHomeFeedStale(Ref ref) => ref.watch(homeFeedProvider).isFromCache;
