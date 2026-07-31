import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/recently_viewed_item.dart';
import 'profile_providers.dart';

part 'recently_viewed_notifier.g.dart';

@riverpod
class RecentlyViewedNotifier extends _$RecentlyViewedNotifier {
  @override
  Future<List<RecentlyViewedItem>> build() => _load();

  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

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
      FailureResult(:final failure) => throw failure,
    };
  }
}
