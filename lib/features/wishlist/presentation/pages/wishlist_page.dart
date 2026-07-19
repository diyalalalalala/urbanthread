import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/state_views.dart';
import '../providers/wishlist_notifier.dart';
import '../providers/wishlist_state.dart';
import '../widgets/wishlist_tile.dart';

/// Saved items.
///
/// A grid rather than a list: a wishlist is browsed visually — the customer is
/// reminding themselves what they liked, not reviewing an order.
class WishlistPage extends ConsumerWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wishlistProvider);
    final isOnline = ref.watch(isOnlineProvider);

    ref.listen(wishlistProvider, (previous, next) {
      final message = next.message;
      if (message == null || message == previous?.message) return;
      context.showSnack(message, isError: next.failure != null);
      ref.read(wishlistProvider.notifier).consumeMessage();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('WISHLIST'),
        actions: [
          if (!(state.wishlist?.isEmpty ?? true))
            TextButton(
              onPressed: () => _confirmClear(context, ref),
              child: const Text('CLEAR'),
            ),
        ],
      ),
      body: Column(
        children: [
          if (!isOnline) const OfflineBanner(),
          if (state.hasPendingWrites) _PendingWritesBanner(state: state),
          Expanded(child: _Body(state: state)),
        ],
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear your wishlist?'),
        content: const Text('This removes every saved item.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('CLEAR ALL'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) await ref.read(wishlistProvider.notifier).clear();
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.state});

  final WishlistState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading && state.wishlist == null) {
      return const LoadingView(message: 'Loading your wishlist');
    }

    if (state.showsFailureScreen) {
      return FailureView(
        failure: state.failure!,
        onRetry: () => ref.read(wishlistProvider.notifier).refresh(),
      );
    }

    final items = state.wishlist?.items ?? const [];
    if (items.isEmpty) {
      return EmptyView(
        title: 'Nothing saved yet',
        message: 'Tap the heart on anything you want to come back to.',
        icon: Icons.favorite_border,
        actionLabel: 'Browse the shop',
        onAction: () => context.go(AppRoutes.products),
      );
    }

    final notifier = ref.read(wishlistProvider.notifier);

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: GridView.builder(
        padding: const EdgeInsets.all(AppDimens.pageGutter),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: context.productGridColumns,
          crossAxisSpacing: AppDimens.space16,
          mainAxisSpacing: AppDimens.space24,
          // Tall enough for the 3:4 image plus brand, name, price, the
          // price-drop line and the action button.
          childAspectRatio: 0.48,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return WishlistTile(
            key: ValueKey(item.id),
            item: item,
            isBusy: state.isBusy(item.product.id),
            onTap: item.product.slug.isEmpty
                ? null
                // Product detail is slug-only on this API.
                : () => context.push(
                      AppRoutes.productDetailPath(item.product.slug),
                    ),
            onRemove: () => notifier.remove(item.product.id),
            onMoveToCart: () => notifier.moveToCart(
              productId: item.product.id,
              // The server falls back to the saved variant, but sending an
              // explicit one covers items saved without a preference — the
              // cart tracks stock per variant and cannot accept a bare
              // product.
              variantId: item.variantForCart?.id,
            ),
          );
        },
      ),
    );
  }
}

class _PendingWritesBanner extends StatelessWidget {
  const _PendingWritesBanner({required this.state});

  final WishlistState state;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      width: double.infinity,
      color: palette.infoSubtle,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.pageGutter,
        vertical: AppDimens.space8,
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_upload_outlined, size: 14, color: palette.info),
          const SizedBox(width: AppDimens.space8),
          Expanded(
            child: Text(
              state.isSyncing
                  ? 'SAVING YOUR CHANGES…'
                  : '${state.pendingWrites} CHANGE'
                      '${state.pendingWrites == 1 ? '' : 'S'} WILL SYNC WHEN '
                      'YOU ARE BACK ONLINE',
              style: AppTypography.eyebrow.copyWith(color: palette.info),
            ),
          ),
        ],
      ),
    );
  }
}
