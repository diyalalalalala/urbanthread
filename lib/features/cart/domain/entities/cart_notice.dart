import 'package:equatable/equatable.dart';

/// What the server changed about a cart line without being asked.
enum CartNoticeType {
  /// The product or variant is gone or deactivated, so the line was dropped.
  removed,

  /// Stock fell below the requested quantity and it was capped.
  quantityReduced,

  /// The live price no longer matches the snapshot taken when the item was
  /// added, and the snapshot was refreshed.
  priceChanged,

  /// A type this build does not know about. Rendered with its message rather
  /// than swallowed — the text is written for customers either way.
  unknown;

  static CartNoticeType parse(String? raw) => switch (raw) {
        'removed' => CartNoticeType.removed,
        'quantity_reduced' => CartNoticeType.quantityReduced,
        'price_changed' => CartNoticeType.priceChanged,
        _ => CartNoticeType.unknown,
      };
}

/// A reconciliation message from the server.
///
/// These are regenerated on **every** cart read — they are not events with an
/// id to acknowledge, they describe what the current read had to fix. That is
/// why they must be surfaced rather than logged: they are the only explanation
/// the customer gets for a cart that changed under them between sessions, and
/// `/cart/validate` treats any outstanding notice as a checkout blocker.
class CartNotice extends Equatable {
  const CartNotice({
    required this.type,
    required this.message,
    this.itemId,
  });

  final CartNoticeType type;

  /// Customer-facing text, written by the backend. Shown verbatim.
  final String message;

  /// The line it concerns. Absent for cart-wide notices.
  final String? itemId;

  /// A removal is worth more emphasis than a price nudge — something the
  /// customer chose is no longer there.
  bool get isSevere => type == CartNoticeType.removed;

  @override
  List<Object?> get props => [type, message, itemId];
}
