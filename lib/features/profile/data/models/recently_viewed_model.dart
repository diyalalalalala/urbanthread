import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/recently_viewed_item.dart';
import 'product_ref_model.dart';

part 'recently_viewed_model.g.dart';

/// One row of `GET /users/me/recently-viewed`.
///
/// The endpoint answers with a **bare array** in `data` — no `meta` block —
/// so there is nothing to page through; the server already capped it at 20 and
/// filtered out entries whose product has been deleted or deactivated.
@JsonSerializable()
class RecentlyViewedModel {
  const RecentlyViewedModel({
    required this.id,
    required this.product,
    this.viewedAt,
  });

  factory RecentlyViewedModel.fromJson(Map<String, dynamic> json) =>
      _$RecentlyViewedModelFromJson(json);

  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  final ProductRefModel product;
  final String? viewedAt;

  Map<String, dynamic> toJson() => _$RecentlyViewedModelToJson(this);

  RecentlyViewedItem toEntity() => RecentlyViewedItem(
        // Fall back to the product id so a row missing `_id` still has a
        // stable list key.
        id: id.isEmpty ? product.id : id,
        product: product.toEntity(),
        viewedAt: (viewedAt == null || viewedAt!.isEmpty)
            ? null
            : DateTime.tryParse(viewedAt!),
      );
}
