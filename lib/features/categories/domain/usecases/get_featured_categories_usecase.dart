import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/category.dart';
import '../repositories/categories_repository.dart';

/// The categories merchandising has flagged for the home strip.
class GetFeaturedCategoriesUseCase extends UseCase<List<Category>, int> {
  const GetFeaturedCategoriesUseCase(this._repository);

  /// Enough to fill a horizontal strip on the widest supported layout without
  /// paying for a page the user will never scroll to.
  static const defaultLimit = 12;

  final CategoriesRepository _repository;

  @override
  Future<Result<List<Category>>> call([int limit = defaultLimit]) =>
      _repository.getFeaturedCategories(limit: limit);
}
