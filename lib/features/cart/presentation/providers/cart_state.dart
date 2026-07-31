import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/cart_snapshot.dart';

class CartState extends Equatable {
  const CartState({
    this.snapshot,
    this.isLoading = false,
    this.isSyncing = false,
    this.failure,
    this.message,
    this.busyItemIds = const {},
    this.isCouponBusy = false,
    this.pendingWrites = 0,
  });

  const CartState.loading() : this(isLoading: true);

  final CartSnapshot? snapshot;

  final bool isLoading;

  final bool isSyncing;

  final Failure? failure;

  final String? message;

  final Set<String> busyItemIds;

  final bool isCouponBusy;

  final int pendingWrites;

  bool get hasPendingWrites => pendingWrites > 0;

  bool isItemBusy(String itemId) => busyItemIds.contains(itemId);

  bool get isEmpty => !isLoading && (snapshot?.isEmpty ?? false);

  bool get showsFailureScreen => failure != null && snapshot == null;

  CartState copyWith({
    CartSnapshot? snapshot,
    bool? isLoading,
    bool? isSyncing,
    Failure? failure,
    bool clearFailure = false,
    String? message,
    bool clearMessage = false,
    Set<String>? busyItemIds,
    bool? isCouponBusy,
    int? pendingWrites,
  }) =>
      CartState(
        snapshot: snapshot ?? this.snapshot,
        isLoading: isLoading ?? this.isLoading,
        isSyncing: isSyncing ?? this.isSyncing,
        failure: clearFailure ? null : (failure ?? this.failure),
        message: clearMessage ? null : (message ?? this.message),
        busyItemIds: busyItemIds ?? this.busyItemIds,
        isCouponBusy: isCouponBusy ?? this.isCouponBusy,
        pendingWrites: pendingWrites ?? this.pendingWrites,
      );

  @override
  List<Object?> get props => [
        snapshot,
        isLoading,
        isSyncing,
        failure,
        message,
        busyItemIds,
        isCouponBusy,
        pendingWrites,
      ];
}
