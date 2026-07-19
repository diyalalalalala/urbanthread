import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import 'order_providers.dart';
import 'orders_state.dart';

part 'orders_notifier.g.dart';

/// The paginated order history.
///
/// The generator strips the `Notifier` suffix, so this class is reached
/// through `ordersProvider`.
@riverpod
class OrdersNotifier extends _$OrdersNotifier {
  static const _pageSize = 10;

  @override
  OrdersState build() {
    // Kick the first page off without blocking the first frame, so the list
    // renders its skeleton immediately.
    unawaited(_load(page: 1));
    return const OrdersState.loading();
  }

  /// Re-reads the first page, keeping the current filter. Wired to pull-to-
  /// refresh.
  Future<void> refresh() => _load(page: 1);

  /// Narrows to a single status, or clears the filter when [status] is null.
  ///
  /// Resets to page 1: page 3 of "all orders" has no meaning once the list is
  /// restricted to cancelled ones.
  Future<void> setStatusFilter(OrderStatus? status) async {
    if (status == state.statusFilter) return;

    state = OrdersState.loading(statusFilter: status);
    await _load(page: 1);
  }

  /// Appends the next page. A no-op at the end of the list or while a load is
  /// already running, so a fast scroll cannot fire it twice.
  Future<void> loadMore() async {
    if (!state.canLoadMore) return;

    final next = state.page.nextPage;
    if (next == null) return;

    state = state.copyWith(isLoadingMore: true, clearFailure: true);
    await _load(page: next, append: true);
  }

  Future<void> _load({required int page, bool append = false}) async {
    final result = await ref.read(getMyOrdersUseCaseProvider)(
      OrderFilter(
        page: page,
        limit: _pageSize,
        status: state.statusFilter,
      ),
    );

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          // Appending rather than replacing keeps the scroll position; the
          // incoming page carries the fresher paging metadata.
          page: append ? state.page.append(value) : value,
          isLoading: false,
          isLoadingMore: false,
          hasLoadedOnce: true,
          clearFailure: true,
        );

      case FailureResult(:final failure):
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          hasLoadedOnce: true,
          failure: failure,
        );
    }
  }
}

/// One order, by id.
///
/// A family, so navigating between two orders does not make them share a
/// slot — and so the detail screen for an order already visited rebuilds from
/// its own cache rather than the previous order's data.
@riverpod
class OrderDetailNotifier extends _$OrderDetailNotifier {
  @override
  OrderDetailState build(String orderId) {
    unawaited(_load());
    return const OrderDetailState.loading();
  }

  Future<void> refresh() => _load();

  Future<void> _load() async {
    final result = await ref.read(getOrderByIdUseCaseProvider)(orderId);

    state = switch (result) {
      Success(:final value) =>
        state.copyWith(order: value, isLoading: false, clearFailure: true),
      FailureResult(:final failure) =>
        state.copyWith(isLoading: false, failure: failure),
    };
  }

  /// Cancels the order.
  ///
  /// Returns whether it worked, so the caller can show a confirmation without
  /// re-reading the state it just triggered. On success the server's updated
  /// order replaces the local one — its status, timeline and payment state
  /// have all moved, and re-fetching would be a second round trip for data we
  /// already hold.
  Future<bool> cancel({String? reason}) async {
    if (state.isSubmitting) return false;

    state = state.copyWith(isSubmitting: true, clearActionFailure: true);

    final result = await ref.read(cancelOrderUseCaseProvider)(
      CancelOrderParams(orderId: orderId, reason: reason),
    );

    switch (result) {
      case Success(:final value):
        state = state.copyWith(order: value, isSubmitting: false);
        // The history list now shows a stale status for this row.
        _invalidateList();
        return true;

      case FailureResult(:final failure):
        state = state.copyWith(isSubmitting: false, actionFailure: failure);
        return false;
    }
  }

  /// Requests a return for the chosen lines.
  Future<bool> requestReturn({
    required List<String> itemIds,
    required String reason,
  }) async {
    if (state.isSubmitting) return false;

    state = state.copyWith(isSubmitting: true, clearActionFailure: true);

    final result = await ref.read(requestReturnUseCaseProvider)(
      ReturnRequest(orderId: orderId, itemIds: itemIds, reason: reason),
    );

    switch (result) {
      case Success(:final value):
        state = state.copyWith(order: value, isSubmitting: false);
        _invalidateList();
        return true;

      case FailureResult(:final failure):
        state = state.copyWith(isSubmitting: false, actionFailure: failure);
        return false;
    }
  }

  /// Drops a stale mutation error so reopening a sheet does not show it.
  void clearActionFailure() =>
      state = state.copyWith(clearActionFailure: true);

  /// Rebuilds the history so its copy of this order is not stale.
  ///
  /// Invalidating rather than patching in place: a cancelled order may fall
  /// out of the active filter entirely, which only a re-query can decide.
  void _invalidateList() => ref.invalidate(ordersProvider);
}

/// The tracking projection for one order.
@riverpod
class OrderTrackingNotifier extends _$OrderTrackingNotifier {
  @override
  OrderTrackingState build(String orderId) {
    unawaited(_load());
    return const OrderTrackingState.loading();
  }

  Future<void> refresh() => _load();

  Future<void> _load() async {
    final result = await ref.read(trackOrderUseCaseProvider)(orderId);

    state = switch (result) {
      Success(:final value) => OrderTrackingState(tracking: value),
      FailureResult(:final failure) => OrderTrackingState(failure: failure),
    };
  }
}
