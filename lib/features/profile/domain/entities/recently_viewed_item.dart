import 'package:equatable/equatable.dart';

import 'product_ref.dart';

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
