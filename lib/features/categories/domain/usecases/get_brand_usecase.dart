import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/brand.dart';
import '../repositories/categories_repository.dart';

class GetBrandUseCase extends UseCase<Brand, String> {
  const GetBrandUseCase(this._repository);

  final CategoriesRepository _repository;

  @override
  Future<Result<Brand>> call(String slugOrId) =>
      _repository.getBrand(slugOrId);
}
