import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../entities/brand.dart';
import '../entities/category.dart';

abstract interface class CategoriesRepository {
  Future<Result<Paginated<Category>>> getCategories({
    int page = 1,
    int limit = 20,
    String? search,
    String? parent,
    bool? isFeatured,
  });

  Future<Result<List<CategoryNode>>> getCategoryTree();

  Future<Result<CategoryNode>> getCategory(String slugOrId);

  Future<Result<List<Category>>> getFeaturedCategories({int limit = 12});

  Future<Result<Paginated<Brand>>> getBrands({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isFeatured,
  });

  Future<Result<List<Brand>>> getFeaturedBrands({int limit = 12});

  Future<Result<Brand>> getBrand(String slugOrId);

  List<CategoryNode> cachedCategoryTree();

  List<Category> cachedFeaturedCategories();

  List<Brand> cachedFeaturedBrands();

  List<Brand> cachedBrands();

  static const rootParent = 'root';
}
