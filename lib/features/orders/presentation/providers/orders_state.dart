import 'package:equatable/equatable.dart';

import '../../../../core/domain/paginated.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/order.dart';

/// State of the order history screen.
///
/// A plain Equatable value rather than an `AsyncValue<List<Order>>`, for the
/// same reason the auth feature uses one: an infinite list has more than
/// three states. It can be showing rows *and* loading the next page *and*
/// holding an error from that page — and collapsing that into a single async
/// slot would blank the list every time the user pulls to refresh.
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

  /// Null means "all statuses" — the chip row's first option.
  final OrderStatus? statusFilter;

  /// A first load or a filter change, where there is nothing to show yet.
  final bool isLoading;

  /// A `loadMore` in flight. Kept apart from [isLoading] so the existing rows
  /// stay on screen with a spinner at the foot.
  final bool isLoadingMore;

  final Failure? failure;

  /// Distinguishes "no orders yet" from "not fetched yet". Without it the
  /// empty state flashes before the first response lands.
  final bool hasLoadedOnce;

  List<Order> get orders => page.items;

  bool get isEmpty => hasLoadedOnce && page.isEmpty;

  /// Show the error as a whole screen only when there is nothing behind it;
  /// otherwise it belongs in a snack bar over the rows we already have.
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

/// State of a single order screen, including its two mutations.
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

  /// A cancel or return request in flight.
  final bool isSubmitting;

  /// Failed to load the order at all.
  final Failure? failure;

  /// A mutation was refused — the order is still on screen and still valid,
  /// so this must not replace it with an error page.
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

/// State of the tracking screen.
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
