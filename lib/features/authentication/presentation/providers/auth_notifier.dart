import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import 'auth_providers.dart';
import 'auth_state.dart';

part 'auth_notifier.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    final repository = ref.watch(authRepositoryProvider);

    final subscription = repository.onSessionExpired.listen((_) {
      state = const AuthState.unauthenticated(
        failure: UnauthorizedFailure(),
      );
    });
    ref.onDispose(subscription.cancel);

    if (!repository.hasSession) return const AuthState.unauthenticated();

    final cached = repository.cachedUser;
    unawaited(_refreshSession());

    return cached == null
        ? const AuthState.unknown()
        : AuthState.authenticated(cached);
  }

  Future<void> _refreshSession() async {
    final result = await ref.read(getCurrentUserUseCaseProvider)(
      const NoParams(),
    );

    switch (result) {
      case Success(:final value):
        state = AuthState.authenticated(value);
      case FailureResult(:final failure):
        final isTransient = failure is NetworkFailure ||
            failure is TimeoutFailure ||
            failure is ServerFailure;
        if (isTransient && state.user != null) return;
        state = AuthState.unauthenticated(failure: failure);
    }
  }

  Future<bool> login({required String email, required String password}) =>
      _submit(
        () => ref.read(loginUseCaseProvider)(
          LoginParams(email: email, password: password),
        ),
      );

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) =>
      _submit(
        () => ref.read(registerUseCaseProvider)(
          RegisterParams(
            name: name,
            email: email,
            password: password,
            phone: phone,
          ),
        ),
      );

  Future<bool> _submit(Future<Result<User>> Function() request) async {
    state = state.copyWith(isSubmitting: true, clearFailure: true);
    final result = await request();

    switch (result) {
      case Success(:final value):
        state = AuthState.authenticated(value);
        return true;
      case FailureResult(:final failure):
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
          failure: failure,
          isSubmitting: false,
        );
        return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isSubmitting: true);
    await ref.read(logoutUseCaseProvider)(const NoParams());
    state = const AuthState.unauthenticated();
  }

  Future<Failure?> logoutEverywhere() async {
    state = state.copyWith(isSubmitting: true, clearFailure: true);
    final result = await ref.read(logoutAllUseCaseProvider)(const NoParams());

    return result.fold(
      onSuccess: (_) {
        state = const AuthState.unauthenticated();
        return null;
      },
      onFailure: (failure) {
        state = state.copyWith(isSubmitting: false, failure: failure);
        return failure;
      },
    );
  }

  Future<void> refreshUser() async {
    final result = await ref.read(getCurrentUserUseCaseProvider)(
      const NoParams(),
    );
    if (result case Success(:final value)) {
      state = AuthState.authenticated(value);
    }
  }

  Future<Result<String>> resetPassword({
    required String token,
    required String password,
  }) async {
    final result = await ref.read(resetPasswordUseCaseProvider)(
      ResetPasswordParams(token: token, password: password),
    );
    if (result.isSuccess) state = const AuthState.unauthenticated();
    return result;
  }

  void clearFailure() => state = state.copyWith(clearFailure: true);
}

@riverpod
User? currentUser(Ref ref) => ref.watch(authProvider).user;

@riverpod
bool isAuthenticated(Ref ref) => ref.watch(authProvider).isAuthenticated;
