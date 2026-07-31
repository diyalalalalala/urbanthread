import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/category.dart';
import '../repositories/categories_repository.dart';

class GetCategoryUseCase extends UseCase<CategoryNode, String> {
  const GetCategoryUseCase(this._repository);

  final CategoriesRepository _repository;

  @override
  Future<Result<CategoryNode>> call(String slugOrId) =>
      _repository.getCategory(slugOrId);
}
