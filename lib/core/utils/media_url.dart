import '../config/app_config.dart';

abstract final class MediaUrl {
  const MediaUrl._();

  static String? resolve(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return null;

    if (value.startsWith('/')) return '${AppConfig.mediaOrigin}$value';

    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) return value;

    final origin =
        Uri(scheme: uri.scheme, host: uri.host, port: uri.port).toString();
    final isOwnBackend = origin == AppConfig.mediaOriginOverride ||
        uri.path.startsWith('/uploads/');
    if (!isOwnBackend) return value;

    final rebased = Uri.parse(AppConfig.mediaOrigin);
    return uri
        .replace(
          scheme: rebased.scheme,
          host: rebased.host,
          port: rebased.hasPort ? rebased.port : null,
        )
        .toString();
  }

  static String? firstOf(Iterable<String?> candidates) {
    for (final candidate in candidates) {
      final resolved = resolve(candidate);
      if (resolved != null) return resolved;
    }
    return null;
  }
}
