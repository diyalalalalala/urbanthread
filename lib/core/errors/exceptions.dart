import 'failures.dart';

sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class ServerException extends AppException {
  const ServerException({
    required String message,
    required this.statusCode,
    this.errors = const [],
  }) : super(message);

  final int? statusCode;
  final List<FieldError> errors;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection.']);
}

class TimeoutException extends AppException {
  const TimeoutException([super.message = 'The request timed out.']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Local storage is unavailable.']);
}

class EmptyCacheException extends AppException {
  const EmptyCacheException([super.message = 'Nothing is cached yet.']);
}

class ParseException extends AppException {
  const ParseException([super.message = 'Unexpected response from the server.']);
}
