import 'package:equatable/equatable.dart';

import '../../../../core/domain/paginated.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/order.dart';

class OrdersState extends Equatable {
  const OrdersState({
    this.page = const Paginated<Order>.empty(),
    this.statusFilter,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.failure,
    this.hasLoadedOnce = false,
  });

  const OrdersState.loading({OrderStatus? statusFilter})
      : this(isLoading: true, statusFilter: statusFilter);

  final Paginated<Order> page;

  final OrderStatus? statusFilter;

  final bool isLoading;

  final bool isLoadingMore;

  final Failure? failure;

  final bool hasLoadedOnce;

  List<Order> get orders => page.items;

  bool get isEmpty => hasLoadedOnce && page.isEmpty;

  bool get showsFailureScreen => failure != null && page.isEmpty;

  bool get canLoadMore => page.hasNextPage && !isLoadingMore && !isLoading;

  OrdersState copyWith({
    Paginated<Order>? page,
    OrderStatus? statusFilter,
    bool clearStatusFilter = false,
    bool? isLoading,
    bool? isLoadingMore,
    Failure? failure,
    bool clearFailure = false,
    bool? hasLoadedOnce,
  }) =>
      OrdersState(
        page: page ?? this.page,
        statusFilter:
            clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        failure: clearFailure ? null : (failure ?? this.failure),
        hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
      );

  @override
  List<Object?> get props => [
        page,
        statusFilter,
        isLoading,
        isLoadingMore,
        failure,
        hasLoadedOnce,
      ];
}

class OrderDetailState extends Equatable {
  const OrderDetailState({
    this.order,
    this.isLoading = false,
    this.isSubmitting = false,
    this.failure,
    this.actionFailure,
  });

  const OrderDetailState.loading() : this(isLoading: true);

  final Order? order;
  final bool isLoading;

  final bool isSubmitting;

  final Failure? failure;

  final Failure? actionFailure;

  bool get hasOrder => order != null;

  OrderDetailState copyWith({
    Order? order,
    bool? isLoading,
    bool? isSubmitting,
    Failure? failure,
    bool clearFailure = false,
    Failure? actionFailure,
    bool clearActionFailure = false,
  }) =>
      OrderDetailState(
        order: order ?? this.order,
        isLoading: isLoading ?? this.isLoading,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        failure: clearFailure ? null : (failure ?? this.failure),
        actionFailure:
            clearActionFailure ? null : (actionFailure ?? this.actionFailure),
      );

  @override
  List<Object?> get props =>
      [order, isLoading, isSubmitting, failure, actionFailure];
}

class OrderTrackingState extends Equatable {
  const OrderTrackingState({
    this.tracking,
    this.isLoading = false,
    this.failure,
  });

  const OrderTrackingState.loading() : this(isLoading: true);

  final OrderTracking? tracking;
  final bool isLoading;
  final Failure? failure;

  @override
  List<Object?> get props => [tracking, isLoading, failure];
}
