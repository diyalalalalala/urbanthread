import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_notice.dart';
import '../../domain/entities/cart_snapshot.dart';
import '../../domain/entities/cart_validation.dart';
import '../providers/cart_notifier.dart';
import '../providers/cart_state.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/cart_summary_card.dart';
import '../widgets/coupon_field.dart';

/// The bag.
///
/// Reads from the kept-alive cart notifier rather than loading its own copy,
/// so opening this page after tapping the badge shows what the badge counted
/// with no spinner in between.
class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cartProvider);
    final isOnline = ref.watch(isOnlineProvider);

    // One-shot messages: rolled-back mutations, coupon results, and the
    // server's reconciliation notices. Shown here rather than inside the
    // notifier so the state stays free of presentation concerns.
    ref.listen(cartProvider, (previous, next) {
      final message = next.message;
      if (message == null || message == previous?.message) return;
      context.showSnack(message, isError: next.failure != null);
      ref.read(cartProvider.notifier).consumeMessage();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('BAG'),
        actions: [
          if ((state.snapshot?.cart.items.isNotEmpty ?? false))
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
      bottomNavigationBar: state.snapshot?.cart.hasActiveItems ?? false
          ? _CheckoutBar(state: state)
          : null,
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Empty your bag?'),
        content: const Text(
          'This removes everything, including items you saved for later, and '
          'any coupon you applied.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('EMPTY BAG'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) await ref.read(cartProvider.notifier).clear();
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.state});

  final CartState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading && state.snapshot == null) {
      return const LoadingView(message: 'Loading your bag');
    }

    if (state.showsFailureScreen) {
      return FailureView(
        failure: state.failure!,
        onRetry: () => ref.read(cartProvider.notifier).refresh(),
      );
    }

    final snapshot = state.snapshot;
    if (snapshot == null || snapshot.cart.items.isEmpty) {
      return EmptyView(
        title: 'Your bag is empty',
        message: 'Everything you add will be waiting here.',
        icon: Icons.shopping_bag_outlined,
        actionLabel: 'Start shopping',
        onAction: () => context.go(AppRoutes.products),
      );
    }

    return RefreshIndicator(
      onRefresh: ref.read(cartProvider.notifier).refresh,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.pageGutter,
          vertical: AppDimens.space8,
        ),
        children: [
          // Cart-wide notices — the ones not tied to a line that survived, so
          // they have nowhere else to appear.
          ..._orphanNotices(snapshot).map(
            (notice) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.space12),
              child: _GlobalNotice(notice: notice),
            ),
          ),
          if (snapshot.activeItems.isEmpty)
            const _SectionEmptyNote(
              text: 'Nothing in your bag — everything below is saved for later.',
            )
          else
            ..._lines(context, ref, snapshot, snapshot.activeItems),
          if (snapshot.savedItems.isNotEmpty) ...[
            const SizedBox(height: AppDimens.space24),
            _SectionHeader(
              title: 'SAVED FOR LATER',
              trailing: Formatters.items(snapshot.savedItems.length),
            ),
            ..._lines(context, ref, snapshot, snapshot.savedItems),
          ],
          const SizedBox(height: AppDimens.space32),
          CouponField(
            summary: snapshot.summary,
            isBusy: state.isCouponBusy,
            // A rejected code is a form error and belongs under the field, so
            // the validation failure is routed here rather than to a toast.
            errorText: state.failure is ValidationFailure
                ? state.failure!.message
                : null,
            onApply: (code) =>
                ref.read(cartProvider.notifier).applyCoupon(code),
            onRemove: ref.read(cartProvider.notifier).removeCoupon,
          ),
          const SizedBox(height: AppDimens.space24),
          CartSummaryCard(
            summary: snapshot.summary,
            isEstimated: state.busyItemIds.isNotEmpty,
          ),
          const SizedBox(height: AppDimens.space32),
        ],
      ),
    );
  }

  /// Notices whose `itemId` no longer matches a line in the payload — a
  /// removal, typically. They still have to be shown; the line they describe
  /// is precisely the one that is gone.
  List<CartNotice> _orphanNotices(CartSnapshot snapshot) => snapshot.notices
      .where(
        (notice) =>
            notice.itemId == null ||
            snapshot.cart.itemById(notice.itemId!) == null,
      )
      .toList(growable: false);

  List<Widget> _lines(
    BuildContext context,
    WidgetRef ref,
    CartSnapshot snapshot,
    List<CartItem> items,
  ) {
    final notifier = ref.read(cartProvider.notifier);

    return [
      for (final item in items)
        CartItemTile(
          key: ValueKey(item.id),
          item: item,
          notice: snapshot.noticeForItem(item.id),
          isBusy: state.isItemBusy(item.id),
          onQuantityChanged: (quantity) =>
              notifier.setQuantity(item.id, quantity),
          onRemove: () => notifier.removeItem(item.id),
          onSaveForLater: () => notifier.saveForLater(item.id),
          onMoveToCart: () => notifier.moveToCart(item.id),
          onTapProduct: item.product.slug.isEmpty
              ? null
              // Product detail is slug-only — there is no `GET /products/:id`.
              : () => context.push(
                    AppRoutes.productDetailPath(item.product.slug),
                  ),
        ),
    ];
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppDimens.space8),
        child: Row(
          children: [
            Text(title, style: AppTypography.eyebrow),
            const Spacer(),
            if (trailing != null)
              Text(
                trailing!,
                style: context.text.bodySmall?.copyWith(
                  color: context.palette.inkMuted,
                ),
              ),
          ],
        ),
      );
}

class _SectionEmptyNote extends StatelessWidget {
  const _SectionEmptyNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.space16),
        child: Text(
          text,
          style: context.text.bodySmall?.copyWith(
            color: context.palette.inkMuted,
          ),
        ),
      );
}

class _GlobalNotice extends StatelessWidget {
  const _GlobalNotice({required this.notice});

  final CartNotice notice;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final severe = notice.isSevere;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.space12),
      decoration: BoxDecoration(
        color: severe ? palette.dangerSubtle : palette.warningSubtle,
        borderRadius: AppDimens.borderRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            severe ? Icons.error_outline : Icons.info_outline,
            size: 14,
            color: severe ? palette.danger : palette.warning,
          ),
          const SizedBox(width: AppDimens.space8),
          Expanded(
            child: Text(
              notice.message,
              style: context.text.bodySmall?.copyWith(
                color: severe ? palette.danger : palette.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tells the customer that a change they made is recorded but not yet sent.
class _PendingWritesBanner extends ConsumerWidget {
  const _PendingWritesBanner({required this.state});

  final CartState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

/// The persistent total and checkout CTA.
class _CheckoutBar extends ConsumerStatefulWidget {
  const _CheckoutBar({required this.state});

  final CartState state;

  @override
  ConsumerState<_CheckoutBar> createState() => _CheckoutBarState();
}

class _CheckoutBarState extends ConsumerState<_CheckoutBar> {
  bool _isValidating = false;

  Future<void> _checkout() async {
    setState(() => _isValidating = true);
    final validation =
        await ref.read(cartProvider.notifier).validateForCheckout();
    if (!mounted) return;
    setState(() => _isValidating = false);

    // A null result means the request itself failed; the notifier has already
    // surfaced that as a message.
    if (validation == null) return;

    if (validation.isValid) {
      context.push(AppRoutes.checkout);
      return;
    }

    await _showBlockers(validation);
  }

  /// Lists every blocker at once, because that is how the endpoint reports
  /// them — the customer fixes the cart in one pass instead of discovering
  /// problems one refusal at a time.
  Future<void> _showBlockers(CartValidation validation) => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Before you check out'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final blocker in validation.blockers)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.space8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 5,
                        color: context.palette.inkMuted,
                      ),
                      const SizedBox(width: AppDimens.space8),
                      Expanded(
                        child: Text(
                          blocker.message,
                          style: context.text.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('REVIEW BAG'),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final summary = widget.state.snapshot?.summary;
    final isOnline = ref.watch(isOnlineProvider);
    final busy = _isValidating || widget.state.busyItemIds.isNotEmpty;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(AppDimens.pageGutter),
        decoration: BoxDecoration(
          color: palette.surface,
          border: Border(top: BorderSide(color: palette.line)),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('TOTAL', style: AppTypography.eyebrow),
                const SizedBox(height: AppDimens.space2),
                Text(
                  Formatters.price(summary?.grandTotal),
                  style: AppTypography.price.copyWith(
                    color: palette.ink,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppDimens.space20),
            Expanded(
              child: SizedBox(
                height: AppDimens.controlHeightLg,
                child: FilledButton(
                  // Checkout is synchronous and server-side; attempting it
                  // offline would fail at the first request, so the button
                  // says why instead of pretending.
                  onPressed: isOnline && !busy ? _checkout : null,
                  child: _isValidating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isOnline ? 'CHECKOUT' : 'OFFLINE'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
