import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/recently_viewed_item.dart';
import 'profile_providers.dart';

part 'recently_viewed_notifier.g.dart';

/// The last 20 products the customer opened.
///
/// There is no pagination to manage: the endpoint returns a bare, server-
/// capped array, so the whole list is one load.
@riverpod
class RecentlyViewedNotifier extends _$RecentlyViewedNotifier {
  @override
  Future<List<RecentlyViewedItem>> build() => _load();

  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

  /// Empties the history. Returns the failure, or null on success.
  ///
  /// The list is cleared locally first because the endpoint answers 204 with
  /// no body — there is no updated list to adopt, only a status.
  Future<Failure?> clear() async {
    final result = await ref.read(clearRecentlyViewedUseCaseProvider)(
      const NoParams(),
    );

    return result.fold(
      onSuccess: (_) {
        state = const AsyncData([]);
        return null;
      },
      onFailure: (failure) => failure,
    );
  }

  Future<List<RecentlyViewedItem>> _load() async {
    final result = await ref.read(getRecentlyViewedUseCaseProvider)(
      const NoParams(),
    );
    return switch (result) {
      Success(:final value) => value,
      // An empty cache while offline is a real, presentable state rather than
      // an empty list — the screen must say "not downloaded", not "nothing
      // viewed".
      FailureResult(:final failure) => throw failure,
    };
  }
}
