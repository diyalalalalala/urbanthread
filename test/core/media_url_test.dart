import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbanthread/core/utils/media_url.dart';

/// The backend bakes its own `SERVER_URL` into every uploaded image URL, so
/// a stock install hands the phone `http://localhost:5000/uploads/...` —
/// which on a device resolves to the phone itself and silently fails to
/// load. `MediaUrl` re-bases those onto the configured API origin. Getting
/// this wrong means an app with no images and no error, so it is worth
/// pinning precisely.
void main() {
  setUp(() {
    dotenv.loadFromString(
      envString: '''
API_BASE_URL=http://10.0.2.2:5000/api/v1
MEDIA_ORIGIN_OVERRIDE=http://localhost:5000
''',
    );
  });

  group('resolve', () {
    test('re-bases a localhost URL onto the reachable origin', () {
      expect(
        MediaUrl.resolve('http://localhost:5000/uploads/products/tee.jpg'),
        'http://10.0.2.2:5000/uploads/products/tee.jpg',
      );
    });

    test('re-bases any /uploads URL even from an unexpected origin', () {
      // Covers a backend whose SERVER_URL was changed without the app's
      // override being updated to match.
      expect(
        MediaUrl.resolve('http://192.168.1.50:5000/uploads/avatars/a.png'),
        'http://10.0.2.2:5000/uploads/avatars/a.png',
      );
    });

    test('attaches the origin to a server-relative path', () {
      expect(
        MediaUrl.resolve('/uploads/categories/men.jpg'),
        'http://10.0.2.2:5000/uploads/categories/men.jpg',
      );
    });

    test('leaves an external URL untouched', () {
      // Seed data points at Unsplash; re-basing those would break them.
      const external = 'https://images.unsplash.com/photo-123?w=800';
      expect(MediaUrl.resolve(external), external);
    });

    test('treats the empty string as no image', () {
      // The API spells "unset" as "" inside an always-present object, not
      // as null — avatar.url, image.url and logo.url all do this.
      expect(MediaUrl.resolve(''), isNull);
      expect(MediaUrl.resolve('   '), isNull);
      expect(MediaUrl.resolve(null), isNull);
    });

    test('preserves the query string when re-basing', () {
      expect(
        MediaUrl.resolve('http://localhost:5000/uploads/p/t.jpg?v=2'),
        'http://10.0.2.2:5000/uploads/p/t.jpg?v=2',
      );
    });
  });

  group('firstOf', () {
    test('returns the first resolvable candidate', () {
      // List endpoints omit the primaryImage virtual, so cards fall through
      // primaryImage → images[0].url → null.
      expect(
        MediaUrl.firstOf(['', null, '/uploads/products/a.jpg']),
        'http://10.0.2.2:5000/uploads/products/a.jpg',
      );
    });

    test('returns null when nothing resolves', () {
      expect(MediaUrl.firstOf(['', null]), isNull);
      expect(MediaUrl.firstOf([]), isNull);
    });
  });
}
