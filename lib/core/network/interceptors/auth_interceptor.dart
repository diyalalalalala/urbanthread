import 'package:dio/dio.dart';

import '../../constants/api_endpoints.dart';
import '../../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStorage tokenStorage,
    required Future<void> Function() onSessionExpired,
  })  : _tokenStorage = tokenStorage,
        _onSessionExpired = onSessionExpired;

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
      _onSessionExpired().catchError((Object _) {});
    }

    handler.next(err);
  }
}
