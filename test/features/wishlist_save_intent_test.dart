import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbanthread/features/wishlist/presentation/providers/pending_wishlist_save.dart';

/// The heart on the product page is the only way into the wishlist, and the
/// whole `/wishlist` API is behind `authenticate`. A guest's tap therefore has
/// to survive a trip through the login screen — which finishes with
/// `context.go`, replacing the stack — and then fire exactly once.
void main() {
  late ProviderContainer container;
  late PendingWishlistSave intent;

  setUp(() {
    container = ProviderContainer.test();
    intent = container.read(pendingWishlistSaveProvider.notifier);
  });

  test('nothing is pending by default', () {
    expect(container.read(pendingWishlistSaveProvider), isNull);
    expect(intent.claim('linen-wrap-midi-dress-ab12c'), isFalse);
  });

  test('a remembered save is claimed by the product that asked for it', () {
    intent.remember('linen-wrap-midi-dress-ab12c');

    expect(intent.claim('linen-wrap-midi-dress-ab12c'), isTrue);
  });

  test('claiming consumes it, so the save is replayed exactly once', () {
    intent.remember('linen-wrap-midi-dress-ab12c');

    expect(intent.claim('linen-wrap-midi-dress-ab12c'), isTrue);
    // A second visit to the same product must not re-save it.
    expect(intent.claim('linen-wrap-midi-dress-ab12c'), isFalse);
    expect(container.read(pendingWishlistSaveProvider), isNull);
  });

  test('another product does not claim it, and does not consume it', () {
    intent.remember('linen-wrap-midi-dress-ab12c');

    expect(intent.claim('everyday-canvas-sneaker-zz98y'), isFalse);
    // The original intent survives, so signing in and landing back on the
    // right product still works.
    expect(intent.claim('linen-wrap-midi-dress-ab12c'), isTrue);
  });

  test('it outlives the page that recorded it', () {
    intent.remember('linen-wrap-midi-dress-ab12c');

    // `keepAlive`, so nothing collects the intent while the login screen owns
    // the stack — the read below stands in for the rebuilt route.
    expect(container.read(pendingWishlistSaveProvider),
        'linen-wrap-midi-dress-ab12c');
  });

  test('an abandoned sign-in can be dropped', () {
    intent
      ..remember('linen-wrap-midi-dress-ab12c')
      ..clear();

    expect(intent.claim('linen-wrap-midi-dress-ab12c'), isFalse);
  });
}
