import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/cancel_order_usecase.dart';
import 'order_providers.dart';
import 'orders_state.dart';

part 'orders_notifier.g.dart';

@riverpod
class OrdersNotifier extends _$OrdersNotifier {
  static const _pageSize = 10;

  @override
  OrdersState build() {
    unawaited(_load(page: 1));
    return const OrdersState.loading();
  }

  Future<void> refresh() => _load(page: 1, status: state.statusFilter);

  Future<void> setStatusFilter(OrderStatus? status) async {
    if (status == state.statusFilter) return;

    state = OrdersState.loading(statusFilter: status);
    await _load(page: 1, status: status);
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore) return;

    final next = state.page.nextPage;
    if (next == null) return;

    state = state.copyWith(isLoadingMore: true, clearFailure: true);
    await _load(page: next, append: true, status: state.statusFilter);
  }

  Future<void> _load({
    required int page,
    bool append = false,
    OrderStatus? status,
  }) async {
    final result = await ref.read(getMyOrdersUseCaseProvider)(
      OrderFilter(page: page, limit: _pageSize, status: status),
    );

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
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

  Future<bool> cancel({String? reason}) async {
    if (state.isSubmitting) return false;

    state = state.copyWith(isSubmitting: true, clearActionFailure: true);

    final result = await ref.read(cancelOrderUseCaseProvider)(
      CancelOrderParams(orderId: orderId, reason: reason),
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

  void clearActionFailure() =>
      state = state.copyWith(clearActionFailure: true);

  void _invalidateList() => ref.invalidate(ordersProvider);
}

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
