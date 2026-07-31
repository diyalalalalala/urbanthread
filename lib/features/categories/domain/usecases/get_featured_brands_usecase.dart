import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/brand.dart';
import '../repositories/categories_repository.dart';

class GetFeaturedBrandsUseCase extends UseCase<List<Brand>, int> {
  const GetFeaturedBrandsUseCase(this._repository);

  static const defaultLimit = 12;

  final CategoriesRepository _repository;

  @override
  Future<Result<List<Brand>>> call([int limit = defaultLimit]) =>
      _repository.getFeaturedBrands(limit: limit);
}
