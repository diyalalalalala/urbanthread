import 'package:equatable/equatable.dart';

/// A catalogue category.
///
/// `slug` is `slugify(name)` with no random suffix, so it is both stable and
/// human-readable — which is why every navigation target in this feature is
/// built from the slug rather than the id.
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

  /// Null when the category has no artwork.
  ///
  /// The API always sends `image` as an object and spells "no image" as
  /// `image.url == ""`, so the emptiness check happens in the model and the
  /// domain gets one honest nullable instead of a sentinel.
  final String? imageUrl;

  /// Null for a root category. Non-null values are ObjectId strings.
  final String? parentId;

  final int displayOrder;
  final bool isActive;
  final bool isFeatured;

  /// Only present on admin responses, so this is nullable rather than 0 —
  /// "we were not told" and "there are none" are different facts, and showing
  /// "0 products" on a category that is actually full would be a lie.
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

/// A category together with its children.
///
/// The type is recursive because `GET /categories/tree` is: every node
/// carries a `children` array of the same shape, `[]` at the leaves, and the
/// backend imposes no depth limit. A fixed two-level model would silently
/// drop grandchildren on a catalogue that grows a third tier.
///
/// The same type also carries `GET /categories/{slugOrId}`, whose `children`
/// are populated one level deep and flat — those child nodes simply arrive
/// with an empty [children] of their own. Callers that need to know the
/// difference can ask [isLeaf]; callers that just render do not have to care.
class CategoryNode extends Equatable {
  const CategoryNode({required this.category, this.children = const []});

  final Category category;
  final List<CategoryNode> children;

  String get id => category.id;
  String get name => category.name;
  String get slug => category.slug;

  bool get isLeaf => children.isEmpty;

  bool get hasChildren => children.isNotEmpty;

  /// Every category at or below this node, parents before their children.
  ///
  /// Used to answer "how many categories are in this branch" and to power a
  /// flat search over a tree the user is browsing hierarchically.
  List<Category> get flattened => [
        category,
        for (final child in children) ...child.flattened,
      ];

  /// Depth of the deepest branch under this node; 1 for a leaf.
  int get depth => children.isEmpty
      ? 1
      : 1 + children.map((child) => child.depth).reduce((a, b) => a > b ? a : b);

  @override
  List<Object?> get props => [category, children];
}
