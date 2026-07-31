import 'package:equatable/equatable.dart';

class FieldError extends Equatable {
  const FieldError({required this.field, required this.message});

  final String field;
  final String message;

  @override
  List<Object?> get props => [field, message];
}

sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([
    super.message = 'The server took too long to respond. Please try again.',
  ]);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'Your session has expired. Please log in again.',
  ]);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure([
    super.message = 'You do not have permission to do that.',
  ]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'We could not find that.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {this.errors = const []});

  final List<FieldError> errors;

  String? forField(String field) {
    for (final error in errors) {
      if (error.field == field) return error.message;
    }
    return null;
  }

  @override
  List<Object?> get props => [message, errors];
}

class ConflictFailure extends Failure {
  const ConflictFailure([super.message = 'That conflicts with existing data.']);
}

class RateLimitFailure extends Failure {
  const RateLimitFailure([
    super.message = 'Too many attempts. Please wait a moment and try again.',
  ]);
}

class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Something went wrong on our end. Please try again.',
  ]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not read saved data.']);
}

class EmptyCacheFailure extends Failure {
  const EmptyCacheFailure([
    super.message = 'You are offline and this has not been downloaded yet.',
  ]);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'Something unexpected happened. Please try again.',
  ]);
}
