import '../config/app_config.dart';

/// Repairs image URLs so they resolve from a phone.
///
/// The backend stores **absolute** URLs built from its own `SERVER_URL`
/// (`src/middleware/upload.js`), e.g. `http://localhost:5000/uploads/products/
/// 1737-ab12.jpg`. On a browser served from the same machine that works. On a
/// device or emulator, `localhost` is the phone itself and the image silently
/// fails to load.
///
/// So every URL is re-based onto the origin implied by `API_BASE_URL`. The
/// path is preserved; only scheme/host/port change. Externally hosted images
/// (a CDN, a seeded Unsplash link) are passed through untouched — rewriting
/// those would break them.
abstract final class MediaUrl {
  const MediaUrl._();

  /// Returns a loadable absolute URL, or null when [raw] is empty.
  ///
  /// Empty is the API's "no image" sentinel: `avatar.url`, `image.url` and
  /// `logo.url` all default to `""` rather than null.
  static String? resolve(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return null;

    // Server-relative ("/uploads/...") — attach our origin.
    if (value.startsWith('/')) return '${AppConfig.mediaOrigin}$value';

    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) return value;

    // Only re-base URLs that came from this backend. Two signals: the origin
    // matches the configured override, or the path is under /uploads.
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

  /// First non-empty resolved URL in [candidates].
  ///
  /// List responses omit the `primaryImage` virtual, so a card typically has
  /// to fall back through `primaryImage → images[0].url → null`.
  static String? firstOf(Iterable<String?> candidates) {
    for (final candidate in candidates) {
      final resolved = resolve(candidate);
      if (resolved != null) return resolved;
    }
    return null;
  }
}
