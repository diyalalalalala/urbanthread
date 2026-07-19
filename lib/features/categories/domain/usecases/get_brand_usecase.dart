import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/brand.dart';
import '../repositories/categories_repository.dart';

/// One brand, addressed by slug or ObjectId — the backend resolves either.
class GetBrandUseCase extends UseCase<Brand, String> {
  const GetBrandUseCase(this._repository);

  final CategoriesRepository _repository;

  @override
  Future<Result<Brand>> call(String slugOrId) =>
      _repository.getBrand(slugOrId);
}
