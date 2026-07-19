import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/cart/presentation/providers/cart_notifier.dart';
import '../../features/wishlist/presentation/providers/wishlist_notifier.dart';
import '../extensions/context_extensions.dart';
import '../providers/core_providers.dart';
import '../widgets/state_views.dart';

/// The persistent bottom-navigation frame.
///
/// Built on `StatefulShellRoute`, so each tab keeps its own navigation stack
/// and scroll position — a shopper who browses three levels into Categories,
/// checks the cart and comes back expects to land where they left, not at the
/// top of a rebuilt tree.
class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    final cartCount = ref.watch(cartItemCountProvider);
    final wishlistCount = ref.watch(wishlistCountProvider);

    return Scaffold(
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
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // Tapping the active tab pops it back to its root — the standard
          // gesture for "take me back to the top of this section".
          initialLocation: index == navigationShell.currentIndex,
        ),
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
