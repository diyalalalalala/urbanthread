import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/category.dart';
import '../repositories/categories_repository.dart';

class GetFeaturedCategoriesUseCase extends UseCase<List<Category>, int> {
  const GetFeaturedCategoriesUseCase(this._repository);

  static const defaultLimit = 12;

  final CategoriesRepository _repository;

  @override
  Future<Result<List<Category>>> call([int limit = defaultLimit]) =>
      _repository.getFeaturedCategories(limit: limit);
}
