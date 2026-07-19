import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../authentication/presentation/providers/auth_notifier.dart';
import '../../domain/usecases/profile_usecases.dart';
import 'profile_providers.dart';

part 'profile_notifier.g.dart';

/// The profile screen's copy of `/users/me`.
///
/// Distinct from `authProvider`, which owns the *session*. This one owns the
/// screen: it can be refreshed, it can be in a failed state, and it can be
/// mutated — none of which should be able to sign anyone out. After a
/// successful mutation the session is told to re-read itself, so the app
/// shell (avatar in the app bar, name in the drawer) follows along.
@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  Future<User> build() async {
    final result = await ref.watch(getProfileUseCaseProvider)(const NoParams());
    return switch (result) {
      Success(:final value) => value,
      FailureResult(:final failure) => throw failure,
    };
  }

  /// Re-reads the profile, showing the previous value while it loads rather
  /// than blanking the screen.
  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      final result = await ref.read(getProfileUseCaseProvider)(
        const NoParams(),
      );
      return switch (result) {
        Success(:final value) => value,
        FailureResult(:final failure) => throw failure,
      };
    });
  }

  /// `PATCH /users/me`. Returns the failure, or null on success, so a form
  /// can decide whether to pop.
  Future<Failure?> updateProfile({String? name, String? phone}) =>
      _mutate(
        () => ref.read(updateProfileUseCaseProvider)(
          UpdateProfileParams(name: name, phone: phone),
        ),
      );

  /// Uploads [filePath] as the new avatar. Size and MIME checks happen in the
  /// repository, before anything leaves the device.
  Future<Failure?> uploadAvatar(String filePath) =>
      _mutate(() => ref.read(uploadAvatarUseCaseProvider)(filePath));

  /// Removes the current avatar. The backend answers 400 when there was none,
  /// so callers should only offer this when one is set.
  Future<Failure?> removeAvatar() =>
      _mutate(() => ref.read(removeAvatarUseCaseProvider)(const NoParams()));

  /// Shared tail of every mutation: adopt the returned user, then resync the
  /// session.
  ///
  /// The state is *not* flipped to loading — every one of these has its own
  /// in-place progress indicator, and dropping the profile to a spinner would
  /// make the whole screen jump while an avatar uploads.
  Future<Failure?> _mutate(Future<Result<User>> Function() request) async {
    final result = await request();

    return result.fold(
      onSuccess: (user) {
        state = AsyncData(user);
        // Fire-and-forget: the profile screen already shows the new value, and
        // the session refresh only matters for other screens.
        unawaited(ref.read(authProvider.notifier).refreshUser());
        return null;
      },
      onFailure: (failure) => failure,
    );
  }
}
