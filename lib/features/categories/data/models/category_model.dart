import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/category.dart';

part 'category_model.g.dart';

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

  @JsonKey(fromJson: _parentId)
  final String? parent;

  final int displayOrder;
  final bool isActive;
  final bool isFeatured;

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

@JsonSerializable()
class ImageRefModel {
  const ImageRefModel({this.url = '', this.publicId = ''});

  factory ImageRefModel.fromJson(Map<String, dynamic> json) =>
      _$ImageRefModelFromJson(json);

  final String url;
  final String publicId;

  Map<String, dynamic> toJson() => _$ImageRefModelToJson(this);

  String? get urlOrNull => url.trim().isEmpty ? null : url;
}

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

String? _parentId(Object? raw) => switch (raw) {
      String value when value.isNotEmpty => value,
      Map<String, dynamic> value => value['_id'] as String?,
      _ => null,
    };

DateTime? parseApiDate(String? raw) =>
    (raw == null || raw.isEmpty) ? null : DateTime.tryParse(raw);
