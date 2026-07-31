import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class AppConfig {
  const AppConfig._();

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');

    final base = apiBaseUrl;
    if (base.isEmpty) {
      throw StateError('API_BASE_URL is missing from .env');
    }
    if (Uri.tryParse(base)?.hasScheme != true) {
      throw StateError('API_BASE_URL must be an absolute URL, got "$base"');
    }
  }

  static String _string(String key, {String fallback = ''}) =>
      dotenv.env[key]?.trim() ?? fallback;

  static int _int(String key, {required int fallback}) =>
      int.tryParse(_string(key)) ?? fallback;

  static bool _bool(String key, {required bool fallback}) =>
      switch (_string(key).toLowerCase()) {
        'true' || '1' || 'yes' => true,
        'false' || '0' || 'no' => false,
        _ => fallback,
      };

  static String get apiBaseUrl {
    final raw = _string('API_BASE_URL');
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }

  static String get mediaOriginOverride => _string('MEDIA_ORIGIN_OVERRIDE');

  static String get mediaOrigin {
    final uri = Uri.parse(apiBaseUrl);
    return Uri(scheme: uri.scheme, host: uri.host, port: uri.port).toString();
  }

  static Duration get connectTimeout =>
      Duration(seconds: _int('CONNECT_TIMEOUT', fallback: 15));

  static Duration get receiveTimeout =>
      Duration(seconds: _int('RECEIVE_TIMEOUT', fallback: 30));

  static bool get enableHttpLogging =>
      _bool('ENABLE_HTTP_LOGGING', fallback: false);
}
