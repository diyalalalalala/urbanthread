import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';

/// Where the session stands.
///
/// [unknown] is distinct from [unauthenticated] on purpose: at launch the app
/// has a token but has not yet confirmed it. Collapsing the two would bounce
/// a signed-in user to the login screen for a frame before redirecting back.
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.failure,
    this.isSubmitting = false,
  });

  /// Boot state, before the token has been checked.
  const AuthState.unknown() : this();

  const AuthState.authenticated(User user)
      : this(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated({Failure? failure})
      : this(status: AuthStatus.unauthenticated, failure: failure);

  final AuthStatus status;
  final User? user;

  /// The last error, for inline form messages. Cleared on the next attempt.
  final Failure? failure;

  /// True while a credential request is in flight, so the form can disable
  /// its submit button. Separate from [status] because a failed login must
  /// not change whether the user is signed in.
  final bool isSubmitting;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isResolved => status != AuthStatus.unknown;

  /// Field-level messages from a 422, keyed by field name.
  ValidationFailure? get validationFailure =>
      failure is ValidationFailure ? failure! as ValidationFailure : null;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    bool clearUser = false,
    Failure? failure,
    bool clearFailure = false,
    bool? isSubmitting,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: clearUser ? null : (user ?? this.user),
        failure: clearFailure ? null : (failure ?? this.failure),
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );

  @override
  List<Object?> get props => [status, user, failure, isSubmitting];
}
