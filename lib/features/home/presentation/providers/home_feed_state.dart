import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/home_feed.dart';

class HomeFeedState extends Equatable {
  const HomeFeedState({
    this.feed = const HomeFeed.empty(),
    this.isLoading = false,
    this.isRefreshing = false,
    this.isFromCache = false,
  });

  const HomeFeedState.loading()
      : feed = const HomeFeed.empty(),
        isLoading = true,
        isRefreshing = false,
        isFromCache = false;

  const HomeFeedState.fromCache(this.feed)
      : isLoading = false,
        isRefreshing = true,
        isFromCache = true;

  final HomeFeed feed;

  final bool isLoading;

  final bool isRefreshing;

  final bool isFromCache;

  bool get hasContent => feed.hasContent;

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
