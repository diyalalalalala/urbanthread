import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/home_feed.dart';

/// What the storefront renders, plus how it got there.
///
/// The feed itself already carries per-section failures; this wrapper adds
/// only the three things the *screen* needs and the feed does not: whether
/// this is a cold first load, whether a refresh is running behind visible
/// content, and whether what is on screen came off disk.
class HomeFeedState extends Equatable {
  const HomeFeedState({
    this.feed = const HomeFeed.empty(),
    this.isLoading = false,
    this.isRefreshing = false,
    this.isFromCache = false,
  });

  /// A cold start: nothing cached, nothing to show but a skeleton.
  const HomeFeedState.loading()
      : feed = const HomeFeed.empty(),
        isLoading = true,
        isRefreshing = false,
        isFromCache = false;

  /// Opening straight from the cache while the network catches up. This is
  /// the normal path on every launch after the first, and the only path when
  /// the device is offline.
  const HomeFeedState.fromCache(this.feed)
      : isLoading = false,
        isRefreshing = true,
        isFromCache = true;

  final HomeFeed feed;

  /// A first load with nothing underneath it.
  final bool isLoading;

  /// A refresh running behind content that is already drawn.
  final bool isRefreshing;

  /// True while the visible content came from disk rather than the network.
  final bool isFromCache;

  bool get hasContent => feed.hasContent;

  /// The failure worth taking over the screen — null whenever anything at all
  /// is renderable.
  Failure? get blockingFailure => feed.blockingFailure;

  HomeFeedState copyWith({
    HomeFeed? feed,
    bool? isLoading,
    bool? isRefreshing,
    bool? isFromCache,
  }) =>
      HomeFeedState(
        feed: feed ?? this.feed,
        isLoading: isLoading ?? this.isLoading,
        isRefreshing: isRefreshing ?? this.isRefreshing,
        isFromCache: isFromCache ?? this.isFromCache,
      );

  @override
  List<Object?> get props => [feed, isLoading, isRefreshing, isFromCache];
}
