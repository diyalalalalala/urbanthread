import 'package:equatable/equatable.dart';

/// A field-scoped validation message, mirroring one entry of the backend's
/// `errors: [{ field, message }]` array.
class FieldError extends Equatable {
  const FieldError({required this.field, required this.message});

  final String field;
  final String message;

  @override
  List<Object?> get props => [field, message];
}

/// Domain-level description of "what went wrong", free of any HTTP or Dio
/// vocabulary so use cases and notifiers never import the network layer.
///
/// Sealed so a `switch` over a failure is checked for exhaustiveness — adding
/// a new variant surfaces every place that must decide how to present it.
sealed class Failure extends Equatable {
  const Failure(this.message);

  /// Safe to show a user as-is. The backend's operational errors are already
  /// customer-facing; unexpected ones are replaced with a generic string by
  /// the mapper rather than leaking internals.
  final String message;

  @override
  List<Object?> get props => [message];
}

/// The device has no usable connection, or the request never reached the host.
///
/// Repositories treat this specially: it is the signal to fall back to the
/// Hive cache rather than to surface an error.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

/// The request reached the server but it took too long to answer.
class TimeoutFailure extends Failure {
  const TimeoutFailure([
    super.message = 'The server took too long to respond. Please try again.',
  ]);
}

/// 401 — the token is missing, expired, or was revoked by a `tokenVersion`
/// bump (logout-all, password change/reset).
///
/// There is no refresh token in this API, so this is always terminal: the
/// session is cleared and the user is sent to login.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'Your session has expired. Please log in again.',
  ]);
}

/// 403 — authenticated but not permitted.
class ForbiddenFailure extends Failure {
  const ForbiddenFailure([
    super.message = 'You do not have permission to do that.',
  ]);
}

/// 404 — the resource does not exist.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'We could not find that.']);
}

/// 400 and 422 — a malformed request or a rejected business rule.
///
/// The backend uses 422 for things the user can act on (coupon expired, out
/// of stock, "shippingAddressId not in your address book") and attaches the
/// offending fields, so [errors] drives inline form messages.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {this.errors = const []});

  final List<FieldError> errors;

  /// Message for [field], if the backend flagged it.
  String? forField(String field) {
    for (final error in errors) {
      if (error.field == field) return error.message;
    }
    return null;
  }

  @override
  List<Object?> get props => [message, errors];
}

/// 409 — conflicts with existing state (email taken, product already
/// reviewed, coupon already applied).
class ConflictFailure extends Failure {
  const ConflictFailure([super.message = 'That conflicts with existing data.']);
}

/// 429 — rate limited. Auth and password-reset routes are the strict ones.
class RateLimitFailure extends Failure {
  const RateLimitFailure([
    super.message = 'Too many attempts. Please wait a moment and try again.',
  ]);
}

/// 5xx, or a response we could not parse.
class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Something went wrong on our end. Please try again.',
  ]);
}

/// Reading or writing local storage failed.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not read saved data.']);
}

/// Nothing is cached for a request made while offline. Distinct from
/// [CacheFailure]: storage worked, it is simply empty.
class EmptyCacheFailure extends Failure {
  const EmptyCacheFailure([
    super.message = 'You are offline and this has not been downloaded yet.',
  ]);
}

/// Anything not otherwise classified.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'Something unexpected happened. Please try again.',
  ]);
}
