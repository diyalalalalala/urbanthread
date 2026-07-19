import 'dart:io';

import 'package:dio/dio.dart';

import '../errors/exceptions.dart';
import '../errors/failures.dart';

/// Translates transport errors into [AppException]s, and those into
/// [Failure]s.
///
/// Two hops rather than one on purpose: data sources throw exceptions
/// (idiomatic for a layer that can fail mid-parse), repositories return
/// failures (so use cases handle errors as values instead of try/catch). This
/// is the only file that needs to know both vocabularies.
abstract final class ErrorMapper {
  const ErrorMapper._();

  /// Normalises anything Dio throws into an [AppException].
  static AppException fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.cancel:
        // A cancelled request is usually a superseded search keystroke. It is
        // not a user-facing error, but it still has to be *some* exception.
        return const NetworkException('The request was cancelled.');

      case DioExceptionType.badCertificate:
        return const NetworkException(
          'Could not establish a secure connection.',
        );

      case DioExceptionType.badResponse:
        return _fromResponse(error.response);

      case DioExceptionType.unknown:
        if (error.error is SocketException) return const NetworkException();
        return ServerException(
          message: error.message ?? 'Unexpected network error.',
          statusCode: error.response?.statusCode,
        );
    }
  }

  static ServerException _fromResponse(Response<dynamic>? response) {
    final status = response?.statusCode;
    final body = response?.data;

    // The error envelope is `{ success: false, message, errors: [...] }`.
    // Anything else (an HTML error page from a proxy, a truncated body) falls
    // back to a status-derived message rather than showing the user markup.
    if (body is Map<String, dynamic>) {
      final message = body['message'];
      return ServerException(
        message: message is String && message.isNotEmpty
            ? message
            : _defaultMessage(status),
        statusCode: status,
        errors: _fieldErrors(body['errors']),
      );
    }

    return ServerException(
      message: _defaultMessage(status),
      statusCode: status,
    );
  }

  static List<FieldError> _fieldErrors(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(
          (entry) => FieldError(
            field: entry['field'] as String? ?? '',
            message: entry['message'] as String? ?? '',
          ),
        )
        .where((error) => error.message.isNotEmpty)
        .toList(growable: false);
  }

  static String _defaultMessage(int? status) => switch (status) {
        400 => 'That request could not be processed.',
        401 => 'Your session has expired. Please log in again.',
        403 => 'You do not have permission to do that.',
        404 => 'We could not find that.',
        409 => 'That conflicts with existing data.',
        422 => 'Some of the details provided were not accepted.',
        429 => 'Too many attempts. Please wait a moment and try again.',
        _ when status != null && status >= 500 =>
          'Something went wrong on our end. Please try again.',
        _ => 'Something unexpected happened. Please try again.',
      };

  /// Converts a data-layer exception into the domain's [Failure].
  static Failure toFailure(Object error) {
    if (error is ServerException) {
      return switch (error.statusCode) {
        401 => UnauthorizedFailure(error.message),
        403 => ForbiddenFailure(error.message),
        404 => NotFoundFailure(error.message),
        409 => ConflictFailure(error.message),
        429 => RateLimitFailure(error.message),
        400 || 422 => ValidationFailure(error.message, errors: error.errors),
        _ => ServerFailure(error.message),
      };
    }

    return switch (error) {
      NetworkException() => NetworkFailure(error.message),
      TimeoutException() => TimeoutFailure(error.message),
      EmptyCacheException() => EmptyCacheFailure(error.message),
      CacheException() => CacheFailure(error.message),
      ParseException() => ServerFailure(error.message),
      DioException() => toFailure(fromDio(error)),
      _ => const UnexpectedFailure(),
    };
  }
}
