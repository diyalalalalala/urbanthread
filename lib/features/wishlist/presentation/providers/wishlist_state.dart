import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/wishlist.dart';

class WishlistState extends Equatable {
  const WishlistState({
    this.wishlist,
    this.isLoading = false,
    this.isSyncing = false,
    this.failure,
    this.message,
    this.busyProductIds = const {},
    this.pendingWrites = 0,
  });

  const WishlistState.loading() : this(isLoading: true);

  final Wishlist? wishlist;

  final bool isLoading;
  final bool isSyncing;

  final Failure? failure;

  final String? message;

  final Set<String> busyProductIds;

  final int pendingWrites;

  bool get hasPendingWrites => pendingWrites > 0;

  bool isBusy(String productId) => busyProductIds.contains(productId);

  bool get isEmpty => !isLoading && (wishlist?.isEmpty ?? false);

  bool get showsFailureScreen => failure != null && wishlist == null;

  int get itemCount => wishlist?.itemCount ?? 0;

  WishlistState copyWith({
    Wishlist? wishlist,
    bool? isLoading,
    bool? isSyncing,
    Failure? failure,
    bool clearFailure = false,
    String? message,
    bool clearMessage = false,
    Set<String>? busyProductIds,
    int? pendingWrites,
  }) =>
      WishlistState(
        wishlist: wishlist ?? this.wishlist,
        isLoading: isLoading ?? this.isLoading,
        isSyncing: isSyncing ?? this.isSyncing,
        failure: clearFailure ? null : (failure ?? this.failure),
        message: clearMessage ? null : (message ?? this.message),
        busyProductIds: busyProductIds ?? this.busyProductIds,
        pendingWrites: pendingWrites ?? this.pendingWrites,
      );

  @override
  List<Object?> get props => [
        wishlist,
        isLoading,
        isSyncing,
        failure,
        message,
        busyProductIds,
        pendingWrites,
      ];
}
