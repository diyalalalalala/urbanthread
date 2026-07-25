import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/cart/presentation/providers/cart_notifier.dart';
import '../../features/wishlist/presentation/providers/wishlist_notifier.dart';
import '../extensions/context_extensions.dart';
import '../providers/core_providers.dart';
import '../widgets/state_views.dart';

/// How long a second back press still counts as confirming the first.
const _exitConfirmationWindow = Duration(seconds: 2);

/// The persistent bottom-navigation frame.
///
/// Built on `StatefulShellRoute`, so each tab keeps its own state and scroll
/// position — a shopper who checks the cart and comes back expects to land
/// where they left, not at the top of a rebuilt tree. Everything deeper than a
/// tab root (a product, an order, settings) is pushed *over* this frame rather
/// than into a branch, so those screens are shared between tabs instead of
/// being duplicated per branch, and dismissing one always reveals the tab it
/// was opened from.
///
/// It also owns the Android back button for everything below it. By the time
/// a press reaches this widget the branch navigators have already declined it,
/// so no route is left to pop and the platform default is to close the app.
/// That is almost never what the press meant, so it is spent on the tab
/// history instead, and only a deliberate second press on home exits.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  /// Tabs the user came through, oldest first, without repeats.
  ///
  /// Back unwinds this rather than always jumping to home: someone who went
  /// Bag → Account and presses back means "return to my basket". A tab is
  /// dropped when it is re-entered, so bouncing between two of them cannot
  /// grow a history that takes half a dozen presses to escape.
  final _tabHistory = <int>[];

  /// Started by the first back press on the home tab. A timer rather than a
  /// timestamp so the window runs on the same clock as the prompt it belongs
  /// to, and so a test can advance it.
  Timer? _exitWindow;

  @override
  void dispose() {
    _exitWindow?.cancel();
    super.dispose();
  }

  void _selectTab(int index) {
    final shell = widget.navigationShell;
    final current = shell.currentIndex;

    if (index != current) {
      _tabHistory
        ..remove(index)
        ..remove(current)
        ..add(current);
    }

    shell.goBranch(
      index,
      // Tapping the active tab pops it back to its root — the standard
      // gesture for "take me back to the top of this section".
      initialLocation: index == current,
    );
  }

  void _handleBack() {
    if (_tabHistory.isNotEmpty) {
      widget.navigationShell.goBranch(_tabHistory.removeLast());
      return;
    }

    // Nothing recorded — the tab was reached by a redirect or a `go` from
    // elsewhere. Anywhere but home, back still means "up", not "out".
    if (widget.navigationShell.currentIndex != 0) {
      widget.navigationShell.goBranch(0);
      return;
    }

    if (_exitWindow?.isActive ?? false) {
      _exitWindow?.cancel();
      SystemNavigator.pop();
      return;
    }

    _exitWindow = Timer(_exitConfirmationWindow, () {});
    context.showSnack('Press back again to exit');
  }

  @override
  Widget build(BuildContext context) {
    final navigationShell = widget.navigationShell;
    final isOnline = ref.watch(isOnlineProvider);
    final cartCount = ref.watch(cartItemCountProvider);
    final wishlistCount = ref.watch(wishlistCountProvider);

    return PopScope(
      // Never let the framework pop the shell itself — it is the last route,
      // so a pop here is an app exit. `_handleBack` decides instead.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        body: Column(
          children: [
            // Sits above the content rather than over it: the catalogue, cart
            // and wishlist all stay usable offline, so this informs without
            // obscuring anything.
            if (!isOnline) const OfflineBanner(),
            Expanded(child: navigationShell),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _selectTab,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'HOME',
            ),
            const NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view),
              label: 'SHOP',
            ),
            NavigationDestination(
              icon: _Badged(
                count: wishlistCount,
                child: const Icon(Icons.favorite_border),
              ),
              selectedIcon: _Badged(
                count: wishlistCount,
                child: const Icon(Icons.favorite),
              ),
              label: 'SAVED',
            ),
            NavigationDestination(
              icon: _Badged(
                count: cartCount,
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              selectedIcon: _Badged(
                count: cartCount,
                child: const Icon(Icons.shopping_bag),
              ),
              label: 'BAG',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'ACCOUNT',
            ),
          ],
        ),
      ),
    );
  }
}

/// A count bubble over a tab icon.
///
/// Counts above 99 are rendered as `99+`; letting a real number through would
/// widen the bubble enough to overlap its neighbour.
class _Badged extends StatelessWidget {
  const _Badged({required this.count, required this.child});

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;

    return Badge(
      label: Text(count > 99 ? '99+' : '$count'),
      backgroundColor: context.palette.accent,
      textColor: context.palette.accentInk,
      child: child,
    );
  }
}
