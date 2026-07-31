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

const _exitConfirmationWindow = Duration(seconds: 2);

class AppShell extends ConsumerStatefulWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final _tabHistory = <int>[];

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
      initialLocation: index == current,
    );
  }

  void _handleBack() {
    if (_tabHistory.isNotEmpty) {
      widget.navigationShell.goBranch(_tabHistory.removeLast());
      return;
    }

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
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        body: Column(
          children: [
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
