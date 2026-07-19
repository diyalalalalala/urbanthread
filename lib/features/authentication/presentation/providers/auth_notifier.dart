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

/// The session, and the only thing allowed to change it.
///
/// Kept alive for the app's lifetime: the router watches it to guard routes,
/// so letting it dispose would sign the user out whenever no screen happened
/// to be listening.
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    final repository = ref.watch(authRepositoryProvider);

    // A 401 anywhere in the app lands here. There is no refresh token, so the
    // only correct reaction is to drop to signed-out and let the router
    // redirect.
    final subscription = repository.onSessionExpired.listen((_) {
      state = const AuthState.unauthenticated(
        failure: UnauthorizedFailure(),
      );
    });
    ref.onDispose(subscription.cancel);

    if (!repository.hasSession) return const AuthState.unauthenticated();

    // A token exists. Show the cached profile immediately so the app opens on
    // the right screen, then confirm with the server in the background —
    // rendering a spinner over a session that is almost certainly valid would
    // cost a visible delay on every cold start.
    final cached = repository.cachedUser;
    unawaited(_refreshSession());

    return cached == null
        ? const AuthState.unknown()
        : AuthState.authenticated(cached);
  }

  /// Verifies the stored token against `/auth/me`.
  Future<void> _refreshSession() async {
    final result = await ref.read(getCurrentUserUseCaseProvider)(
      const NoParams(),
    );

    switch (result) {
      case Success(:final value):
        state = AuthState.authenticated(value);
      case FailureResult(:final failure):
        // Offline with a cached profile: stay signed in. The token is very
        // likely still good, and forcing a re-login the moment someone walks
        // into a lift would be hostile.
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

  /// Runs a credential request, managing the submitting flag and the error.
  ///
  /// Returns whether it succeeded, so a form can navigate on true without
  /// having to re-inspect the state it just triggered.
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

  /// Signs out on this device. Always succeeds locally.
  Future<void> logout() async {
    state = state.copyWith(isSubmitting: true);
    await ref.read(logoutUseCaseProvider)(const NoParams());
    state = const AuthState.unauthenticated();
  }

  /// Signs out everywhere by bumping `tokenVersion`. Can fail — it is only
  /// meaningful if the server received it.
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

  /// Re-reads the profile, after an avatar upload or an address change.
  Future<void> refreshUser() async {
    final result = await ref.read(getCurrentUserUseCaseProvider)(
      const NoParams(),
    );
    if (result case Success(:final value)) {
      state = AuthState.authenticated(value);
    }
  }

  /// Confirms an email from a deep-linked token.
  Future<Failure?> verifyEmail(String token) async {
    final result = await ref.read(verifyEmailUseCaseProvider)(token);
    return result.fold(
      onSuccess: (user) {
        // Only promote to authenticated if there is a live session; the link
        // can be opened while signed out, in which case verifying is all it
        // does and the user still has to log in.
        if (state.isAuthenticated) state = AuthState.authenticated(user);
        return null;
      },
      onFailure: (failure) => failure,
    );
  }

  /// Sets a new password from an emailed token. Every session dies, including
  /// this one, so the caller must route to login on success.
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

  /// Drops a stale error so a form does not reopen showing it.
  void clearFailure() => state = state.copyWith(clearFailure: true);
}

/// The signed-in user, or null. The common read for screens that need
/// identity but not the rest of the auth state.
///
/// These derive from the whole state rather than a `.select` on it —
/// [AuthState] is an Equatable value, so an unchanged state is already
/// filtered out, and a derived provider only re-emits when its own output
/// differs. The rebuild savings are the same without the ceremony.
@riverpod
User? currentUser(Ref ref) => ref.watch(authProvider).user;

@riverpod
bool isAuthenticated(Ref ref) => ref.watch(authProvider).isAuthenticated;
