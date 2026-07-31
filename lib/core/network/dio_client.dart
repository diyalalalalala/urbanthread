import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'interceptors/auth_interceptor.dart';

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
