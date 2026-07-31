import 'package:equatable/equatable.dart';

enum CartNoticeType {
  removed,

  quantityReduced,

  priceChanged,

  unknown;

  static CartNoticeType parse(String? raw) => switch (raw) {
        'removed' => CartNoticeType.removed,
        'quantity_reduced' => CartNoticeType.quantityReduced,
        'price_changed' => CartNoticeType.priceChanged,
        _ => CartNoticeType.unknown,
      };
}

class CartNotice extends Equatable {
  const CartNotice({
    required this.type,
    required this.message,
    this.itemId,
  });

  final CartNoticeType type;

  final String message;

  final String? itemId;

  bool get isSevere => type == CartNoticeType.removed;

  @override
  List<Object?> get props => [type, message, itemId];
}
