import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/cart_snapshot.dart';

/// Everything the cart screen and the nav badge need.
///
/// [snapshot] is nullable only until the first read resolves — after that it
/// is replaced wholesale on every mutation, because the API answers each write
/// with the complete `{cart, notices, summary}` triple.
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

  /// True only for the very first load. A refresh over existing data leaves
  /// this false so the list does not collapse into a spinner.
  final bool isLoading;

  /// True while queued offline writes are being replayed.
  final bool isSyncing;

  /// The last error. Cleared when a new action starts, so a stale message
  /// cannot outlive the thing that caused it.
  final Failure? failure;

  /// A one-shot line for a snack bar — a rolled-back mutation, a coupon
  /// rejection, a sync summary. Read once and cleared by the listener.
  final String? message;

  /// Lines with a mutation in flight. Their controls disable individually
  /// rather than freezing the whole list, so editing one item never blocks
  /// editing another.
  final Set<String> busyItemIds;

  final bool isCouponBusy;

  /// Writes made offline that have not reached the server yet. Surfaced on
  /// the screen so a queued change is visible rather than silent.
  final int pendingWrites;

  bool get hasPendingWrites => pendingWrites > 0;

  bool isItemBusy(String itemId) => busyItemIds.contains(itemId);

  /// True when there is nothing to show and nothing in flight — the empty
  /// state, as opposed to "not loaded yet".
  bool get isEmpty => !isLoading && (snapshot?.isEmpty ?? false);

  /// Only a failure with no data behind it should take over the screen.
  /// Offline with a cached cart shows the cart and a banner instead.
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
