import 'failures.dart';

/// Thrown by data sources. Never escapes the data layer — repositories catch
/// these and return a [Failure] instead, which is what the domain speaks.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// A non-2xx response carrying the backend's error envelope.
class ServerException extends AppException {
  const ServerException({
    required String message,
    required this.statusCode,
    this.errors = const [],
  }) : super(message);

  final int? statusCode;
  final List<FieldError> errors;
}

/// The request could not be sent or no response arrived — DNS failure,
/// connection refused, socket dropped.
class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection.']);
}

/// A connect/send/receive timeout elapsed.
class TimeoutException extends AppException {
  const TimeoutException([super.message = 'The request timed out.']);
}

/// A Hive box or SharedPreferences operation failed.
class CacheException extends AppException {
  const CacheException([super.message = 'Local storage is unavailable.']);
}

/// A read found no cached value where one was required.
class EmptyCacheException extends AppException {
  const EmptyCacheException([super.message = 'Nothing is cached yet.']);
}

/// The response parsed as JSON but did not match the expected shape. Worth
/// distinguishing from [ServerException]: this one means the client and the
/// API have drifted apart, not that the request was rejected.
class ParseException extends AppException {
  const ParseException([super.message = 'Unexpected response from the server.']);
}
