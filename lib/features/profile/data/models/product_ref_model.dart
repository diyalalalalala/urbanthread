import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/media_url.dart';
import '../../domain/entities/product_ref.dart';

part 'product_ref_model.g.dart';

/// Wire format for the product projections embedded in recently-viewed and
/// review responses.
///
/// `_id` is optional here, unlike everywhere else in the API: `/reviews/
/// my-reviews` populates only `{name, slug, images, price}`, and the
/// `/reviews/reviewable` aggregate projects the id out altogether. Defaulting
/// it to `''` keeps a partial projection parseable instead of throwing on a
/// field the endpoint was never going to send.
@JsonSerializable()
class ProductRefModel {
  const ProductRefModel({
    this.id = '',
    this.name = '',
    this.slug = '',
    this.images = const [],
    this.price,
    this.effectivePrice,
    this.discountPercentage = 0,
    this.rating,
    this.totalStock,
    this.isActive = true,
  });

  factory ProductRefModel.fromJson(Map<String, dynamic> json) =>
      _$ProductRefModelFromJson(json);

  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  final String name;
  final String slug;

  /// Flattened to URLs on the way in. The catalogue sends objects
  /// (`{url, alt, isPrimary}`) but seeded and legacy rows can carry bare
  /// strings, and an account screen only ever needs the first usable URL —
  /// so both shapes are tolerated rather than modelled.
  @JsonKey(fromJson: _imageUrls, toJson: _imageUrlsToJson)
  final List<String> images;

  final num? price;
  final num? effectivePrice;
  final num discountPercentage;

  /// Nested `{average, count, distribution}`. Absent on the review
  /// projection.
  final RatingRefModel? rating;

  final int? totalStock;
  final bool isActive;

  Map<String, dynamic> toJson() => _$ProductRefModelToJson(this);

  ProductRef toEntity() => ProductRef(
        id: id,
        name: name,
        slug: slug,
        imageUrl: MediaUrl.firstOf(images),
        price: price,
        effectivePrice: effectivePrice,
        discountPercentage: discountPercentage,
        ratingAverage: rating?.average ?? 0,
        ratingCount: rating?.count ?? 0,
        totalStock: totalStock,
        isActive: isActive,
      );
}

@JsonSerializable()
class RatingRefModel {
  const RatingRefModel({this.average = 0, this.count = 0});

  factory RatingRefModel.fromJson(Map<String, dynamic> json) =>
      _$RatingRefModelFromJson(json);

  final num average;
  final int count;

  Map<String, dynamic> toJson() => _$RatingRefModelToJson(this);
}

List<String> _imageUrls(Object? raw) {
  if (raw is! List) return const [];
  final urls = <String>[];
  for (final entry in raw) {
    if (entry is String && entry.isNotEmpty) {
      urls.add(entry);
    } else if (entry is Map) {
      final url = entry['url'];
      if (url is String && url.isNotEmpty) urls.add(url);
    }
  }
  return urls;
}

/// Round-trips through the cache as plain strings; `_imageUrls` accepts them
/// back unchanged.
List<String> _imageUrlsToJson(List<String> images) => images;
