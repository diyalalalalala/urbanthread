import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.failure,
    this.isSubmitting = false,
  });

  const AuthState.unknown() : this();

  const AuthState.authenticated(User user)
      : this(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated({Failure? failure})
      : this(status: AuthStatus.unauthenticated, failure: failure);

  final AuthStatus status;
  final User? user;

  final Failure? failure;

  final bool isSubmitting;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isResolved => status != AuthStatus.unknown;

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
