import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description = '',
    this.imageUrl,
    this.parentId,
    this.displayOrder = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.productCount,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String slug;
  final String description;

  final String? imageUrl;

  final String? parentId;

  final int displayOrder;
  final bool isActive;
  final bool isFeatured;

  final int? productCount;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isRoot => parentId == null;

  bool get hasImage => imageUrl != null;

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        description,
        imageUrl,
        parentId,
        displayOrder,
        isActive,
        isFeatured,
        productCount,
        createdAt,
        updatedAt,
      ];
}

class CategoryNode extends Equatable {
  const CategoryNode({required this.category, this.children = const []});

  final Category category;
  final List<CategoryNode> children;

  String get id => category.id;
  String get name => category.name;
  String get slug => category.slug;

  bool get isLeaf => children.isEmpty;

  bool get hasChildren => children.isNotEmpty;

  List<Category> get flattened => [
        category,
        for (final child in children) ...child.flattened,
      ];

  int get depth => children.isEmpty
      ? 1
      : 1 + children.map((child) => child.depth).reduce((a, b) => a > b ? a : b);

  @override
  List<Object?> get props => [category, children];
}
