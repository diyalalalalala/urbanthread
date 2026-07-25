import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:urbanthread/core/providers/core_providers.dart';
import 'package:urbanthread/core/router/app_routes.dart';
import 'package:urbanthread/core/router/app_shell.dart';
import 'package:urbanthread/core/theme/app_theme.dart';
import 'package:urbanthread/features/cart/presentation/providers/cart_notifier.dart';
import 'package:urbanthread/features/wishlist/presentation/providers/wishlist_notifier.dart';

/// The shell is the last route in the stack, so every back press that the
/// tabs and their pages decline arrives here — and the platform default for
/// that is to close the app. These cover the cases where it must not.
void main() {
  /// Delivers the same `popRoute` platform message Android sends on a back
  /// press, so the whole Router → Navigator → PopScope chain is exercised
  /// rather than [AppShell]'s callback in isolation.
  Future<void> pressBack(WidgetTester tester) async {
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/navigation',
      const JSONMethodCodec().encodeMethodCall(const MethodCall('popRoute')),
      (_) {},
    );
    await tester.pumpAndSettle();
  }

  /// Records `SystemNavigator.pop`, which is how the app asks to be closed.
  ///
  /// Filtered rather than collecting the whole channel: tapping a tab also
  /// puts a `SystemSound.play` down it, which says nothing about exiting.
  List<String> captureSystemCalls(WidgetTester tester) {
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method.startsWith('SystemNavigator')) calls.add(call.method);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    return calls;
  }

  /// A stand-in for the real route table: same shell, same five branches,
  /// trivial pages. The pages under test are the shell's, not the features'.
  Future<void> pumpShell(WidgetTester tester) async {
    Widget page(String label) => Scaffold(body: Center(child: Text(label)));

    StatefulShellBranch branch(String path, String label) =>
        StatefulShellBranch(
          routes: [GoRoute(path: path, builder: (_, _) => page(label))],
        );

    final router = GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              AppShell(navigationShell: navigationShell),
          branches: [
            branch(AppRoutes.home, 'HomeBody'),
            branch(AppRoutes.categories, 'CategoriesBody'),
            branch(AppRoutes.wishlist, 'WishlistBody'),
            branch(AppRoutes.cart, 'CartBody'),
            branch(AppRoutes.profile, 'ProfileBody'),
          ],
        ),
        GoRoute(
          path: AppRoutes.products,
          builder: (_, _) => page('ProductsBody'),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isOnlineProvider.overrideWithValue(true),
          cartItemCountProvider.overrideWithValue(0),
          wishlistCountProvider.overrideWithValue(0),
        ],
        // The real theme, not the default one: the shell's snack bar reads
        // brand colours off the palette extension and would throw without it.
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('back returns to the previous tab instead of closing the app', (
    tester,
  ) async {
    await pumpShell(tester);
    final systemCalls = captureSystemCalls(tester);

    await tapTab(tester, 'BAG');
    await tapTab(tester, 'ACCOUNT');
    expect(find.text('ProfileBody'), findsOneWidget);

    await pressBack(tester);
    expect(find.text('CartBody'), findsOneWidget);

    await pressBack(tester);
    expect(find.text('HomeBody'), findsOneWidget);
    expect(systemCalls, isEmpty, reason: 'the app must still be running');
  });

  testWidgets('a tab entered directly falls back to home, not to an exit', (
    tester,
  ) async {
    await pumpShell(tester);
    final systemCalls = captureSystemCalls(tester);

    await tapTab(tester, 'SHOP');
    await pressBack(tester);

    expect(find.text('HomeBody'), findsOneWidget);
    expect(systemCalls, isEmpty);
  });

  testWidgets('exiting from home takes two presses', (tester) async {
    await pumpShell(tester);
    final systemCalls = captureSystemCalls(tester);

    await pressBack(tester);
    expect(find.text('Press back again to exit'), findsOneWidget);
    expect(systemCalls, isEmpty, reason: 'one press must not close the app');

    await pressBack(tester);
    expect(systemCalls, contains('SystemNavigator.pop'));
  });

  testWidgets('a second press outside the confirmation window does not exit', (
    tester,
  ) async {
    await pumpShell(tester);
    final systemCalls = captureSystemCalls(tester);

    await pressBack(tester);
    await tester.pump(const Duration(seconds: 3));
    await pressBack(tester);

    expect(systemCalls, isEmpty);
  });

  testWidgets('a pushed screen pops back to the tab it was opened from', (
    tester,
  ) async {
    await pumpShell(tester);
    final systemCalls = captureSystemCalls(tester);

    await tapTab(tester, 'SHOP');
    final context = tester.element(find.text('CategoriesBody'));
    context.push(AppRoutes.products);
    await tester.pumpAndSettle();
    expect(find.text('ProductsBody'), findsOneWidget);

    // The shell must still be underneath: the press pops the pushed route and
    // leaves the tab exactly as it was.
    await pressBack(tester);
    expect(find.text('CategoriesBody'), findsOneWidget);
    expect(systemCalls, isEmpty);
  });
}
