import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/recently_viewed_item.dart';
import 'product_ref_model.dart';

part 'recently_viewed_model.g.dart';

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
        id: id.isEmpty ? product.id : id,
        product: product.toEntity(),
        viewedAt: (viewedAt == null || viewedAt!.isEmpty)
            ? null
            : DateTime.tryParse(viewedAt!),
      );
}
