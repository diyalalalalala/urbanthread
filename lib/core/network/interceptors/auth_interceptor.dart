import 'package:dio/dio.dart';

import '../../constants/api_endpoints.dart';
import '../../storage/token_storage.dart';

/// Attaches the bearer token, and turns an unrecoverable 401 into a logout.
///
/// There is no refresh token in this API, so a 401 can never be retried — the
/// only correct response is to drop the session and send the user to login.
/// That mirrors the web client exactly (`client/src/services/apiClient.js`).
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStorage tokenStorage,
    required Future<void> Function() onSessionExpired,
  })  : _tokenStorage = tokenStorage,
        _onSessionExpired = onSessionExpired;

  /// Routes where a 401 is a *failed credential check*, not an expired
  /// session. Signing the user out because they mistyped a password would be
  /// both wrong and confusing.
  static const _sessionExempt = {ApiEndpoints.login, ApiEndpoints.register};

  final TokenStorage _tokenStorage;
  final Future<void> Function() _onSessionExpired;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final token = _tokenStorage.token;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Let Dio compute the multipart boundary itself. Setting a bare
    // `application/json` default on the client would otherwise override it
    // and the upload would be rejected.
    if (options.data is FormData) {
      options.headers.remove('Content-Type');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final isUnauthorized = err.response?.statusCode == 401;
    final path = err.requestOptions.path;
    final isExempt = _sessionExempt.any(path.endsWith);

    if (isUnauthorized && !isExempt) {
      // Fire-and-forget: the error still propagates to the caller, which
      // shows the message while the router reacts to the cleared session.
      // Swallowing failures here is deliberate — if clearing the token fails
      // there is nothing useful to report on top of the 401 already in play.
      _onSessionExpired().catchError((Object _) {});
    }

    handler.next(err);
  }
}
