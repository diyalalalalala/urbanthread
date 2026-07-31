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

  Future<Failure?> updateProfile({String? name, String? phone}) =>
      _mutate(
        () => ref.read(updateProfileUseCaseProvider)(
          UpdateProfileParams(name: name, phone: phone),
        ),
      );

  Future<Failure?> uploadAvatar(String filePath) =>
      _mutate(() => ref.read(uploadAvatarUseCaseProvider)(filePath));

  Future<Failure?> removeAvatar() =>
      _mutate(() => ref.read(removeAvatarUseCaseProvider)(const NoParams()));

  Future<Failure?> _mutate(Future<Result<User>> Function() request) async {
    final result = await request();

    return result.fold(
      onSuccess: (user) {
        state = AsyncData(user);
        unawaited(ref.read(authProvider.notifier).refreshUser());
        return null;
      },
      onFailure: (failure) => failure,
    );
  }
}
