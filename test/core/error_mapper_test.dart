import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbanthread/core/errors/exceptions.dart';
import 'package:urbanthread/core/errors/failures.dart';
import 'package:urbanthread/core/network/error_mapper.dart';

/// `ErrorMapper` is the single place HTTP vocabulary becomes domain
/// vocabulary, so every screen's error handling inherits whatever it decides.
/// These tests pin the two behaviours the rest of the app relies on: that the
/// backend's own message survives to the user, and that a status maps to the
/// failure type screens branch on.
void main() {
  Response<dynamic> response(int status, Object? body) => Response<dynamic>(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: status,
        data: body,
      );

  DioException badResponse(int status, Object? body) => DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: response(status, body),
        type: DioExceptionType.badResponse,
      );

  group('fromDio', () {
    test('keeps the backend message rather than inventing one', () {
      final exception = ErrorMapper.fromDio(
        badResponse(422, {
          'success': false,
          'message': 'Insufficient stock',
          'errors': <dynamic>[],
        }),
      );

      expect(exception, isA<ServerException>());
      expect(exception.message, 'Insufficient stock');
    });

    test('collects field errors so forms can show them inline', () {
      final exception = ErrorMapper.fromDio(
            badResponse(422, {
              'success': false,
              'message': 'Validation failed',
              'errors': [
                {'field': 'email', 'message': 'Email already registered'},
                {'field': 'password', 'message': 'Too short'},
              ],
            }),
          ) as ServerException;

      expect(exception.errors, hasLength(2));
      expect(exception.errors.first.field, 'email');
      expect(exception.errors.first.message, 'Email already registered');
    });

    test('drops error entries with no message', () {
      final exception = ErrorMapper.fromDio(
            badResponse(400, {
              'message': 'Bad request',
              'errors': [
                {'field': 'a', 'message': ''},
                {'field': 'b', 'message': 'Real problem'},
              ],
            }),
          ) as ServerException;

      expect(exception.errors, hasLength(1));
      expect(exception.errors.single.field, 'b');
    });

    test('falls back to a status message when the body is not the envelope', () {
      // A proxy returning an HTML error page must not be shown as markup.
      final exception = ErrorMapper.fromDio(
        badResponse(503, '<html><body>Bad Gateway</body></html>'),
      );

      expect(exception.message, isNot(contains('<html>')));
      expect(exception.message, contains('our end'));
    });

    test('maps every timeout variant to TimeoutException', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        final exception = ErrorMapper.fromDio(
          DioException(
            requestOptions: RequestOptions(path: '/test'),
            type: type,
          ),
        );
        expect(exception, isA<TimeoutException>(), reason: '$type');
      }
    });

    test('maps a connection error to NetworkException', () {
      final exception = ErrorMapper.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(exception, isA<NetworkException>());
    });
  });

  group('toFailure', () {
    test('maps statuses to the failure types screens branch on', () {
      final cases = <int, Matcher>{
        401: isA<UnauthorizedFailure>(),
        403: isA<ForbiddenFailure>(),
        404: isA<NotFoundFailure>(),
        409: isA<ConflictFailure>(),
        429: isA<RateLimitFailure>(),
        400: isA<ValidationFailure>(),
        422: isA<ValidationFailure>(),
        500: isA<ServerFailure>(),
      };

      cases.forEach((status, matcher) {
        final failure = ErrorMapper.toFailure(
          ServerException(message: 'x', statusCode: status),
        );
        expect(failure, matcher, reason: 'status $status');
      });
    });

    test('exposes field errors through ValidationFailure.forField', () {
      final failure = ErrorMapper.toFailure(
        const ServerException(
          message: 'Validation failed',
          statusCode: 422,
          errors: [FieldError(field: 'code', message: 'Coupon expired')],
        ),
      ) as ValidationFailure;

      expect(failure.forField('code'), 'Coupon expired');
      expect(failure.forField('missing'), isNull);
    });

    test('distinguishes an empty cache from a broken one', () {
      // Repositories branch on this: empty means "offline and never
      // downloaded", broken means storage itself failed.
      expect(
        ErrorMapper.toFailure(const EmptyCacheException()),
        isA<EmptyCacheFailure>(),
      );
      expect(
        ErrorMapper.toFailure(const CacheException()),
        isA<CacheFailure>(),
      );
    });

    test('unwraps a raw DioException without a separate call', () {
      final failure = ErrorMapper.toFailure(
        badResponse(404, {'message': 'Product not found'}),
      );

      expect(failure, isA<NotFoundFailure>());
      expect(failure.message, 'Product not found');
    });

    test('never leaks an unrecognised error to the user', () {
      final failure = ErrorMapper.toFailure(ArgumentError('internal detail'));

      expect(failure, isA<UnexpectedFailure>());
      expect(failure.message, isNot(contains('internal detail')));
    });
  });
}
