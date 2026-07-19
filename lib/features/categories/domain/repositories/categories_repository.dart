import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../entities/brand.dart';
import '../entities/category.dart';

/// The catalogue-taxonomy contract: categories, the category tree, and brands.
///
/// Categories and brands live behind one repository because they are the same
/// job from the UI's point of view — "how do I narrow the catalogue" — and
/// splitting them would mean two datasources, two caches and two sets of
/// offline rules for six endpoints.
abstract interface class CategoriesRepository {
  /// A page of categories, ordered by `displayOrder` then `name`.
  ///
  /// There is no `sort` parameter on this endpoint; the ordering is fixed
  /// server-side, so there is nothing to expose here.
  ///
  /// [parent] takes an ObjectId to list one category's children, or the
  /// literal string [rootParent] to list only top-level categories.
  Future<Result<Paginated<Category>>> getCategories({
    int page = 1,
    int limit = 20,
    String? search,
    String? parent,
    bool? isFeatured,
  });

  /// The whole taxonomy, recursively nested.
  ///
  /// Public callers never see a category whose parent is inactive — the
  /// backend prunes the branch — so the tree is always internally consistent.
  Future<Result<List<CategoryNode>>> getCategoryTree();

  /// One category by slug or ObjectId, with its immediate children.
  ///
  /// The backend tries the value as a slug first and falls back to an id, so
  /// either works and the caller does not have to know which it holds.
  Future<Result<CategoryNode>> getCategory(String slugOrId);

  /// Featured categories, for the home strip. A thin wrapper over
  /// [getCategories] that exists so the caller does not have to remember the
  /// filter name is `isFeatured` rather than `featured`.
  Future<Result<List<Category>>> getFeaturedCategories({int limit = 12});

  Future<Result<Paginated<Brand>>> getBrands({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isFeatured,
  });

  /// Featured brands. Note the server default is 12 here, unlike the product
  /// collection endpoints which default to 10.
  Future<Result<List<Brand>>> getFeaturedBrands({int limit = 12});

  Future<Result<Brand>> getBrand(String slugOrId);

  // ── Synchronous cache reads ──────────────────────────────────────────────
  // These exist so a screen can paint from disk on its very first frame and
  // then refresh, instead of showing a spinner over data it already has.
  // Reading Hive is synchronous, so making the caller await would buy nothing
  // but a frame of empty screen.

  List<CategoryNode> cachedCategoryTree();

  List<Category> cachedFeaturedCategories();

  List<Brand> cachedFeaturedBrands();

  List<Brand> cachedBrands();

  /// The value [getCategories] accepts to mean "top-level only". It is a
  /// literal string the validator special-cases, not an id.
  static const rootParent = 'root';
}
