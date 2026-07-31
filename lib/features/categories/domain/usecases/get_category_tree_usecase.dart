import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/category.dart';
import '../repositories/categories_repository.dart';

class GetCategoryTreeUseCase extends UseCase<List<CategoryNode>, NoParams> {
  const GetCategoryTreeUseCase(this._repository);

  final CategoriesRepository _repository;

  @override
  Future<Result<List<CategoryNode>>> call(NoParams params) =>
      _repository.getCategoryTree();
}
