import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:urbanthread/core/domain/paginated.dart';
import 'package:urbanthread/core/domain/result.dart';
import 'package:urbanthread/core/network/network_info.dart';
import 'package:urbanthread/core/providers/core_providers.dart';
import 'package:urbanthread/features/authentication/presentation/providers/auth_notifier.dart';
import 'package:urbanthread/features/cart/domain/entities/cart_snapshot.dart';
import 'package:urbanthread/features/cart/domain/repositories/cart_repository.dart';
import 'package:urbanthread/features/cart/presentation/providers/cart_notifier.dart';
import 'package:urbanthread/features/cart/presentation/providers/cart_providers.dart';
import 'package:urbanthread/features/checkout/domain/entities/checkout_cart.dart';
import 'package:urbanthread/features/checkout/domain/repositories/address_repository.dart';
import 'package:urbanthread/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:urbanthread/features/checkout/presentation/providers/checkout_notifier.dart';
import 'package:urbanthread/features/checkout/presentation/providers/checkout_providers.dart';
import 'package:urbanthread/features/orders/domain/entities/order.dart';
import 'package:urbanthread/features/orders/domain/repositories/order_repository.dart';
import 'package:urbanthread/features/orders/presentation/providers/order_providers.dart';
import 'package:urbanthread/features/orders/presentation/providers/orders_notifier.dart';
import 'package:urbanthread/features/wishlist/domain/entities/wishlist.dart';
import 'package:urbanthread/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:urbanthread/features/wishlist/presentation/providers/wishlist_notifier.dart';
import 'package:urbanthread/features/wishlist/presentation/providers/wishlist_providers.dart';

class MockCartRepository extends Mock implements CartRepository {}

class MockWishlistRepository extends Mock implements WishlistRepository {}

class MockOrderRepository extends Mock implements OrderRepository {}

class MockCheckoutRepository extends Mock implements CheckoutRepository {}

class MockAddressRepository extends Mock implements AddressRepository {}

class FakeNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;

  @override
  Stream<bool> get onStatusChange => const Stream<bool>.empty();
}

class FakeOrderFilter extends Fake implements OrderFilter {}

/// Every one of these notifiers starts its first fetch from `build` with
/// `unawaited(...)`, which runs the method synchronously up to its first
/// `await` — while `build` is still on the stack and the provider therefore
/// has no state yet. Touching `state` in that window throws "Tried to read the
/// state of an uninitialized provider" and takes the whole screen down before
/// it paints. So each of these opens its provider cold and lets it settle.
void main() {
  setUpAll(() => registerFallbackValue(FakeOrderFilter()));

  test('checkout survives a cold build', () async {
    final checkout = MockCheckoutRepository();
    final address = MockAddressRepository();
    when(checkout.validateCart).thenAnswer(
      (_) async => const Result.success(
        CheckoutCart(lines: [], summary: CartSummary.empty()),
      ),
    );
    when(address.getAddresses)
        .thenAnswer((_) async => const Result.success([]));

    final container = ProviderContainer.test(
      overrides: [
        checkoutRepositoryProvider.overrideWithValue(checkout),
        addressRepositoryProvider.overrideWithValue(address),
        networkInfoProvider.overrideWithValue(FakeNetworkInfo()),
        currentUserProvider.overrideWithValue(null),
      ],
    );

    // Held open for the duration: checkout is autoDispose, and a bare `read`
    // would tear the notifier down before its first fetch lands.
    final sub = container.listen(checkoutProvider, (_, _) {});
    expect(sub.read().isLoading, isTrue);
    await pumpEventQueue();

    final state = sub.read();
    expect(state.isLoading, isFalse);
    expect(state.failure, isNull);
  });

  test('orders survives a cold build', () async {
    final orders = MockOrderRepository();
    when(() => orders.getMyOrders(any())).thenAnswer(
      (_) async => const Result.success(Paginated<Order>.empty()),
    );

    final container = ProviderContainer.test(
      overrides: [orderRepositoryProvider.overrideWithValue(orders)],
    );

    final sub = container.listen(ordersProvider, (_, _) {});
    expect(sub.read().isLoading, isTrue);
    await pumpEventQueue();

    final state = sub.read();
    expect(state.isLoading, isFalse);
    expect(state.hasLoadedOnce, isTrue);
    expect(state.failure, isNull);
  });

  group('bag', () {
    MockCartRepository repository({CartSnapshot? cached}) {
      final cart = MockCartRepository();
      when(() => cart.cachedCart).thenReturn(cached);
      when(() => cart.pendingWriteCount).thenReturn(0);
      when(cart.getCart).thenAnswer(
        (_) async => const Result.success(CartSnapshot.empty()),
      );
      return cart;
    }

    ProviderContainer containerFor(MockCartRepository cart) =>
        ProviderContainer.test(
          overrides: [
            cartRepositoryProvider.overrideWithValue(cart),
            networkInfoProvider.overrideWithValue(FakeNetworkInfo()),
          ],
        );

    // The dangerous branch: with nothing on disk the notifier used to take the
    // non-silent path, which writes `state` before its first await.
    test('survives a cold build with an empty cache', () async {
      final container = containerFor(repository());

      expect(container.read(cartProvider).isLoading, isTrue);
      await pumpEventQueue();

      final state = container.read(cartProvider);
      expect(state.isLoading, isFalse);
      expect(state.snapshot, isNotNull);
      expect(state.failure, isNull);
    });

    test('paints a cached bag without a spinner', () async {
      final container = containerFor(
        repository(cached: const CartSnapshot.empty()),
      );

      final initial = container.read(cartProvider);
      expect(initial.isLoading, isFalse);
      expect(initial.snapshot, isNotNull);

      await pumpEventQueue();
      expect(container.read(cartProvider).failure, isNull);
    });
  });

  group('wishlist', () {
    MockWishlistRepository repository({Wishlist? cached}) {
      final wishlist = MockWishlistRepository();
      when(() => wishlist.cachedWishlist).thenReturn(cached);
      when(() => wishlist.pendingWriteCount).thenReturn(0);
      when(wishlist.getWishlist).thenAnswer(
        (_) async => const Result.success(Wishlist(id: 'w1')),
      );
      return wishlist;
    }

    ProviderContainer containerFor(MockWishlistRepository wishlist) =>
        ProviderContainer.test(
          overrides: [
            wishlistRepositoryProvider.overrideWithValue(wishlist),
            networkInfoProvider.overrideWithValue(FakeNetworkInfo()),
          ],
        );

    test('survives a cold build with an empty cache', () async {
      final container = containerFor(repository());

      expect(container.read(wishlistProvider).isLoading, isTrue);
      await pumpEventQueue();

      final state = container.read(wishlistProvider);
      expect(state.isLoading, isFalse);
      expect(state.wishlist, isNotNull);
      expect(state.failure, isNull);
    });

    test('paints a cached wishlist without a spinner', () async {
      final container = containerFor(
        repository(cached: const Wishlist(id: 'w1')),
      );

      expect(container.read(wishlistProvider).isLoading, isFalse);

      await pumpEventQueue();
      expect(container.read(wishlistProvider).failure, isNull);
    });
  });
}
