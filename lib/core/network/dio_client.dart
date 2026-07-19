import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'interceptors/auth_interceptor.dart';

/// Builds the single [Dio] the whole app shares.
///
/// One instance matters: the auth interceptor holds the session, and a second
/// client would silently issue unauthenticated requests.
abstract final class DioClient {
  const DioClient._();

  static Dio create({
    required TokenStorage tokenStorage,
    required Future<void> Function() onSessionExpired,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.connectTimeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        // `validateStatus` is left at its default (2xx only). A 4xx must
        // raise a DioException so Retrofit never attempts to decode an error
        // envelope into a success model — the body is still reachable via
        // `DioException.response`, which is where ErrorMapper reads the
        // backend's `message` and `errors` from.
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokenStorage,
        onSessionExpired: onSessionExpired,
      ),
    );

    if (AppConfig.enableHttpLogging) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          compact: false,
          maxWidth: 120,
        ),
      );
    }

    return dio;
  }
}
