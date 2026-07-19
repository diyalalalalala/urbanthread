import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/order.dart';
import '../providers/orders_notifier.dart';
import '../providers/orders_state.dart';
import '../widgets/order_card.dart';

/// The order history: a paginated, status-filtered list.
class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// Fetches the next page while the user is still 400px from the end, so the
  /// rows are usually there before the scroll reaches them. `loadMore` is a
  /// no-op when one is already running, so firing on every scroll frame is
  /// harmless.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      ref.read(ordersProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersProvider);
    final isOnline = ref.watch(isOnlineProvider);

    return Scaffold(
      backgroundColor: context.palette.canvas,
      appBar: AppBar(title: const Text('My orders')),
      body: Column(
        children: [
          if (!isOnline) const OfflineBanner(),
          _StatusFilterBar(
            selected: state.statusFilter,
            onSelected: (status) =>
                ref.read(ordersProvider.notifier).setStatusFilter(status),
          ),
          Expanded(child: _body(state)),
        ],
      ),
    );
  }

  Widget _body(OrdersState state) {
    if (state.isLoading && state.orders.isEmpty) {
      return const LoadingView(message: 'Fetching your orders…');
    }

    if (state.showsFailureScreen) {
      return FailureView(
        failure: state.failure!,
        onRetry: () => ref.read(ordersProvider.notifier).refresh(),
      );
    }

    if (state.isEmpty) {
      final filtered = state.statusFilter != null;
      return EmptyView(
        icon: Icons.receipt_long_outlined,
        title: filtered ? 'Nothing here' : 'No orders yet',
        message: filtered
            ? 'You have no ${state.statusFilter!.label.toLowerCase()} orders.'
            : 'When you place an order it will appear here, with tracking and '
                'your receipt.',
        actionLabel: filtered ? 'Show all orders' : 'Start shopping',
        onAction: () {
          if (filtered) {
            ref.read(ordersProvider.notifier).setStatusFilter(null);
          } else {
            context.go(AppRoutes.home);
          }
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(ordersProvider.notifier).refresh(),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pageGutter,
          AppDimens.space16,
          AppDimens.pageGutter,
          AppDimens.space32,
        ),
        // One extra row at the foot holds the paging spinner.
        itemCount: state.orders.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: AppDimens.space12),
        itemBuilder: (context, index) {
          if (index == state.orders.length) return _footer(state);

          final order = state.orders[index];
          return OrderCard(
            order: order,
            onTap: () => context.push(AppRoutes.orderDetailPath(order.id)),
          );
        },
      ),
    );
  }

  Widget _footer(OrdersState state) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimens.space24),
        child: LoadingView(),
      );
    }

    // A page failed but earlier ones are on screen. Offering a retry inline
    // beats replacing the whole list with an error.
    if (state.failure != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.space24),
        child: Column(
          children: [
            Text(
              state.failure!.message,
              textAlign: TextAlign.center,
              style: context.text.bodySmall,
            ),
            const SizedBox(height: AppDimens.space12),
            OutlinedButton(
              onPressed: () => ref.read(ordersProvider.notifier).loadMore(),
              child: const Text('TRY AGAIN'),
            ),
          ],
        ),
      );
    }

    return const SizedBox(height: AppDimens.space8);
  }
}

/// The horizontal chip row of status filters.
///
/// Every one of the eight statuses is offered, plus "All". They map to the
/// `status` query parameter, which the backend validates against the same
/// enum — a value it does not recognise is dropped and the filter fails open,
/// so the wire strings come from the enum rather than being typed here.
class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar({required this.selected, required this.onSelected});

  final OrderStatus? selected;
  final ValueChanged<OrderStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(bottom: BorderSide(color: palette.line)),
      ),
      padding: const EdgeInsets.symmetric(vertical: AppDimens.space12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.pageGutter),
        child: Row(
          children: [
            _Chip(
              label: 'All',
              isSelected: selected == null,
              onTap: () => onSelected(null),
            ),
            for (final status in OrderStatus.values) ...[
              const SizedBox(width: AppDimens.space8),
              _Chip(
                label: status.label,
                isSelected: selected == status,
                // Tapping the active chip clears the filter, which is what
                // people expect from a toggle and saves a trip to "All".
                onTap: () => onSelected(selected == status ? null : status),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.borderRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: AppDimens.space8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? palette.ink : palette.surface,
          border: Border.all(
            color: isSelected ? palette.ink : palette.line,
          ),
          borderRadius: AppDimens.borderRadius,
        ),
        child: Text(
          label,
          style: context.text.labelMedium?.copyWith(
            color: isSelected ? palette.canvas : palette.inkMuted,
          ),
        ),
      ),
    );
  }
}
