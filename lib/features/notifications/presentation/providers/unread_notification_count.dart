import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../../../authentication/presentation/providers/auth_notifier.dart';
import 'notification_providers.dart';

part 'unread_notification_count.g.dart';

@Riverpod(keepAlive: true)
class UnreadNotificationCount extends _$UnreadNotificationCount {
  @override
  Future<int> build() async {
    if (!ref.watch(isAuthenticatedProvider)) return 0;

    final result = await ref.watch(getUnreadCountUseCaseProvider)(
      const NoParams(),
    );

    return result.fold(onSuccess: (count) => count, onFailure: (_) => 0);
  }

  Future<void> refresh() async {
    final result = await ref.read(getUnreadCountUseCaseProvider)(
      const NoParams(),
    );
    if (result case Success(:final value)) state = AsyncData(value);
  }

  void setCount(int count) => state = AsyncData(count < 0 ? 0 : count);

  void decrement() {
    final current = state.value ?? 0;
    setCount(current - 1);
  }
}
