import 'package:equatable/equatable.dart';

import 'product_ref.dart';

/// One entry of `/users/me/recently-viewed`.
///
/// The server caps the list at 20 and drops entries whose product was deleted
/// or deactivated, so the client never has to filter tombstones — every item
/// that arrives is safe to render and to navigate to.
class RecentlyViewedItem extends Equatable {
  const RecentlyViewedItem({
    required this.id,
    required this.product,
    this.viewedAt,
  });

  final String id;
  final ProductRef product;
  final DateTime? viewedAt;

  @override
  List<Object?> get props => [id, product, viewedAt];
}
