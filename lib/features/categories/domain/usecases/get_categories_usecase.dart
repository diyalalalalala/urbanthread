import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/category.dart';
import '../repositories/categories_repository.dart';

class GetCategoriesParams {
  const GetCategoriesParams({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.parent,
    this.isFeatured,
  });

  /// Only top-level categories.
  const GetCategoriesParams.roots({this.page = 1, this.limit = 50})
      : search = null,
        parent = CategoriesRepository.rootParent,
        isFeatured = null;

  /// The direct children of [parentId].
  const GetCategoriesParams.childrenOf(
    String parentId, {
    this.page = 1,
    this.limit = 50,
  })  : search = null,
        parent = parentId,
        isFeatured = null;

  final int page;

  /// The validator caps this at 100; anything higher is rejected outright
  /// rather than clamped.
  final int limit;

  final String? search;
  final String? parent;
  final bool? isFeatured;
}

/// Lists categories, optionally filtered by parent, feature flag or search.
class GetCategoriesUseCase
    extends UseCase<Paginated<Category>, GetCategoriesParams> {
  const GetCategoriesUseCase(this._repository);

  final CategoriesRepository _repository;

  @override
  Future<Result<Paginated<Category>>> call(GetCategoriesParams params) =>
      _repository.getCategories(
        page: params.page,
        limit: params.limit,
        search: params.search,
        parent: params.parent,
        isFeatured: params.isFeatured,
      );
}
