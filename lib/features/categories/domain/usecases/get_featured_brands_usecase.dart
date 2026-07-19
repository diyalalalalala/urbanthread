import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/brand.dart';
import '../repositories/categories_repository.dart';

/// The brands merchandising has flagged for the home strip.
class GetFeaturedBrandsUseCase extends UseCase<List<Brand>, int> {
  const GetFeaturedBrandsUseCase(this._repository);

  /// The server's own default for this route. Worth stating rather than
  /// leaving to the backend, because it is **12** here while every product
  /// collection endpoint defaults to 10 — an asymmetry that silently changes
  /// how long a rail is if you assume otherwise.
  static const defaultLimit = 12;

  final CategoriesRepository _repository;

  @override
  Future<Result<List<Brand>>> call([int limit = defaultLimit]) =>
      _repository.getFeaturedBrands(limit: limit);
}
