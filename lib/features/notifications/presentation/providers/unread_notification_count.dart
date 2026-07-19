import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../../../authentication/presentation/providers/auth_notifier.dart';
import 'notification_providers.dart';

part 'unread_notification_count.g.dart';

/// The number behind the app-bar bell badge.
///
/// Kept alive because it is read from the persistent app shell: letting it
/// dispose would re-fetch the count every time the last screen showing a badge
/// was popped. The class is named without a `Notifier` suffix on purpose —
/// the generator strips that suffix, and `unreadNotificationCountProvider` is
/// the name the shell expects.
///
/// Anything that changes read state must call [refresh] (or [setCount] when
/// the server already told it the new value), because there is no push
/// channel — the count only moves when the app asks.
@Riverpod(keepAlive: true)
class UnreadNotificationCount extends _$UnreadNotificationCount {
  @override
  Future<int> build() async {
    // No session, no notifications. Watching this also clears the badge the
    // moment a sign-out lands, without anyone having to remember to.
    if (!ref.watch(isAuthenticatedProvider)) return 0;

    final result = await ref.watch(getUnreadCountUseCaseProvider)(
      const NoParams(),
    );

    // A failed count is not worth an error state: the badge is decoration,
    // and showing none is better than showing a broken app bar. The
    // repository already falls back to the cached count when offline.
    return result.fold(onSuccess: (count) => count, onFailure: (_) => 0);
  }

  /// Re-reads the count from the server.
  Future<void> refresh() async {
    final result = await ref.read(getUnreadCountUseCaseProvider)(
      const NoParams(),
    );
    if (result case Success(:final value)) state = AsyncData(value);
  }

  /// Adopts a count the caller already knows — after `read-all` returns the
  /// number it changed, or after one row is marked read — so the badge updates
  /// without a second round trip.
  void setCount(int count) => state = AsyncData(count < 0 ? 0 : count);

  /// Decrements by one, floored at zero. For marking a single row read.
  void decrement() {
    final current = state.valueOrNull ?? 0;
    setCount(current - 1);
  }
}
