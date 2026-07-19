import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Typed view over `.env`.
///
/// Every value is read once at startup and validated here rather than at the
/// call site, so a missing or malformed key fails loudly during boot instead
/// of surfacing as a confusing socket error on the first request.
abstract final class AppConfig {
  const AppConfig._();

  /// Loads and validates `.env`. Call before `runApp`.
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

  /// Includes the `/api/v1` prefix. Never ends in a slash.
  static String get apiBaseUrl {
    final raw = _string('API_BASE_URL');
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }

  /// Origin the backend embeds in uploaded image URLs. See [mediaOrigin].
  static String get mediaOriginOverride => _string('MEDIA_ORIGIN_OVERRIDE');

  /// The origin [apiBaseUrl] points at — `http://10.0.2.2:5000` for
  /// `http://10.0.2.2:5000/api/v1`. Image URLs are rewritten onto this.
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
