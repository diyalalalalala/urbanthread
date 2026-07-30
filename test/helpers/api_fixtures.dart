import 'package:dio/dio.dart';
import 'package:urbanthread/core/network/api_envelope.dart';

/// Builders for the wire shapes a repository has to read correctly.
///
/// Failures are constructed as real [DioException]s rather than as the
/// `AppException`s `ErrorMapper` would have produced from them, so the mapping
/// from "HTTP said 409" to "the domain saw a ConflictFailure" stays inside what
/// the test exercises. That hop is where a status code silently becoming a
/// generic `ServerFailure` would hide.

/// The `{ success, message, data, meta? }` envelope every endpoint answers
/// with. `meta` is omitted unless the route is paginated.
ApiEnvelope<T> envelope<T>(
  T data, {
  String message = 'Success',
  PaginationMeta? meta,
}) =>
    ApiEnvelope<T>(success: true, message: message, data: data, meta: meta);

/// A pagination block with the derived flags filled in consistently — the
/// backend never sends `hasNextPage: true` on the last page, so a fixture that
/// could would be testing a response the API cannot produce.
PaginationMeta paginationMeta({
  int page = 1,
  int limit = 10,
  int total = 1,
  int totalPages = 1,
}) =>
    PaginationMeta(
      page: page,
      limit: limit,
      total: total,
      totalPages: totalPages,
      hasNextPage: page < totalPages,
      hasPrevPage: page > 1,
      nextPage: page < totalPages ? page + 1 : null,
      prevPage: page > 1 ? page - 1 : null,
    );

/// What Retrofit surfaces for a non-2xx: a [DioException] carrying the
/// backend's error envelope, `{ success: false, message, errors }`.
///
/// [errors] is the 422 field list that drives inline form messages.
DioException httpError(
  int status, {
  String message = 'That request was rejected.',
  List<Map<String, dynamic>> errors = const [],
}) {
  final request = RequestOptions(path: '/test');
  return DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: request,
      statusCode: status,
      data: <String, dynamic>{
        'success': false,
        'message': message,
        if (errors.isNotEmpty) 'errors': errors,
      },
    ),
  );
}

/// The request never reached the server. This is the case every offline
/// fallback hangs off, so it is distinct from a 5xx on purpose.
DioException connectionError() => DioException(
      requestOptions: RequestOptions(path: '/test'),
      type: DioExceptionType.connectionError,
    );

/// The request arrived but the answer did not.
DioException timeoutError() => DioException(
      requestOptions: RequestOptions(path: '/test'),
      type: DioExceptionType.receiveTimeout,
    );
