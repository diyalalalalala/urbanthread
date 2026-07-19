import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/category.dart';
import '../repositories/categories_repository.dart';

/// Fetches the entire category taxonomy in one request.
///
/// One call for the whole tree beats paging `/categories?parent=…` level by
/// level: the taxonomy is small, it is the thing the browse screen needs in
/// full before it can render anything, and having it whole is what makes the
/// screen work offline.
class GetCategoryTreeUseCase extends UseCase<List<CategoryNode>, NoParams> {
  const GetCategoryTreeUseCase(this._repository);

  final CategoriesRepository _repository;

  @override
  Future<Result<List<CategoryNode>>> call(NoParams params) =>
      _repository.getCategoryTree();
}
