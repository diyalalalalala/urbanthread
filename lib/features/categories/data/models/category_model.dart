import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/category.dart';

part 'category_model.g.dart';

/// Wire format for a category.
///
/// Three API facts are absorbed here so the domain never learns them:
///
/// 1. **`_id`, never `id`.** There is no `toJSON` transform on the backend,
///    and the repository's `.lean()` reads emit `_id` alone.
/// 2. **`image` is always an object.** "No image" is `image.url == ""`, not a
///    null `image`, so the emptiness test — not a null test — is what decides
///    whether artwork exists.
/// 3. **`productCount` is admin-only.** It is simply absent on public reads,
///    which is why it is nullable rather than defaulted to zero.
@JsonSerializable()
class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description = '',
    this.image,
    this.parent,
    this.displayOrder = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.productCount,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  @JsonKey(name: '_id')
  final String id;
  final String name;
  final String slug;
  final String description;
  final ImageRefModel? image;

  /// An ObjectId string, or null at the top level. Read through
  /// [_parentId] because a populated parent object turns up on some
  /// responses and a bare id on others.
  @JsonKey(fromJson: _parentId)
  final String? parent;

  final int displayOrder;
  final bool isActive;
  final bool isFeatured;

  /// Absent on public responses.
  final int? productCount;

  final String? createdAt;
  final String? updatedAt;

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  Category toEntity() => Category(
        id: id,
        name: name,
        slug: slug,
        description: description,
        imageUrl: image?.urlOrNull,
        parentId: parent,
        displayOrder: displayOrder,
        isActive: isActive,
        isFeatured: isFeatured,
        productCount: productCount,
        createdAt: parseApiDate(createdAt),
        updatedAt: parseApiDate(updatedAt),
      );
}

/// `{ url, publicId }` — the shape behind a category's `image` and a brand's
/// `logo`. Same fields, different key on the parent document.
@JsonSerializable()
class ImageRefModel {
  const ImageRefModel({this.url = '', this.publicId = ''});

  factory ImageRefModel.fromJson(Map<String, dynamic> json) =>
      _$ImageRefModelFromJson(json);

  final String url;
  final String publicId;

  Map<String, dynamic> toJson() => _$ImageRefModelToJson(this);

  /// The URL, or null when the API used its empty-string "unset" sentinel.
  ///
  /// Deliberately *not* run through `MediaUrl.resolve` here: models are
  /// cached verbatim, and baking today's host into the payload would leave
  /// stale origins on disk after the base URL changes. `AppNetworkImage`
  /// re-bases at render time instead.
  String? get urlOrNull => url.trim().isEmpty ? null : url;
}

/// A category node plus its children — the shape of `/categories/tree`.
///
/// Hand-rolled rather than generated because the node is *recursive and
/// flattened*: `children` sits alongside the category's own fields in the same
/// JSON object rather than nested under a key, so there is no struct
/// json_serializable could describe without duplicating every category field a
/// second time. Composing [CategoryModel] and decoding `children` by hand
/// keeps one definition of a category.
///
/// The same type decodes `/categories/{slugOrId}`, where `children` is present
/// but flat — those nodes carry no `children` key of their own and fall
/// through to the empty default.
class CategoryNodeModel {
  const CategoryNodeModel({required this.category, this.children = const []});

  factory CategoryNodeModel.fromJson(Map<String, dynamic> json) =>
      CategoryNodeModel(
        category: CategoryModel.fromJson(json),
        children: (json['children'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(CategoryNodeModel.fromJson)
            .toList(growable: false),
      );

  final CategoryModel category;
  final List<CategoryNodeModel> children;

  /// Round-trips through the cache in exactly the shape the API sent, so a
  /// cached tree and a fresh one decode by the same path.
  Map<String, dynamic> toJson() => {
        ...category.toJson(),
        'children': children.map((child) => child.toJson()).toList(),
      };

  CategoryNode toEntity() => CategoryNode(
        category: category.toEntity(),
        children: children
            .map((child) => child.toEntity())
            .toList(growable: false),
      );
}

/// Reads a reference that may arrive as a bare ObjectId or as a populated
/// document. Both forms appear across the catalogue endpoints.
String? _parentId(Object? raw) => switch (raw) {
      String value when value.isNotEmpty => value,
      Map<String, dynamic> value => value['_id'] as String?,
      _ => null,
    };

/// Parses an API timestamp, tolerating both absent and empty-string values.
DateTime? parseApiDate(String? raw) =>
    (raw == null || raw.isEmpty) ? null : DateTime.tryParse(raw);
