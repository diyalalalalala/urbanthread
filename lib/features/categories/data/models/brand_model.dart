import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/brand.dart';
import 'category_model.dart';

part 'brand_model.g.dart';

/// Wire format for a brand.
///
/// Near-identical to [CategoryModel] with one difference that costs an hour if
/// missed: the image object is keyed **`logo`**, not `image`. Same
/// `{url, publicId}` payload, different field name.
@JsonSerializable()
class BrandModel {
  const BrandModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description = '',
    this.logo,
    this.website = '',
    this.country = '',
    this.isActive = true,
    this.isFeatured = false,
    this.displayOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) =>
      _$BrandModelFromJson(json);

  @JsonKey(name: '_id')
  final String id;
  final String name;
  final String slug;
  final String description;

  /// Note the key: `logo`, where a category uses `image`.
  final ImageRefModel? logo;

  /// Empty string when unset, like every other optional string in this API.
  final String website;

  final String country;
  final bool isActive;
  final bool isFeatured;
  final int displayOrder;
  final String? createdAt;
  final String? updatedAt;

  Map<String, dynamic> toJson() => _$BrandModelToJson(this);

  Brand toEntity() => Brand(
        id: id,
        name: name,
        slug: slug,
        description: description,
        logoUrl: logo?.urlOrNull,
        website: website.trim().isEmpty ? null : website.trim(),
        country: country,
        isActive: isActive,
        isFeatured: isFeatured,
        displayOrder: displayOrder,
        createdAt: parseApiDate(createdAt),
        updatedAt: parseApiDate(updatedAt),
      );
}
