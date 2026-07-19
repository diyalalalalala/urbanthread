import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/brand.dart';
import '../repositories/categories_repository.dart';

class GetBrandsParams {
  const GetBrandsParams({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.isFeatured,
  });

  final int page;

  /// Capped at 100 by the validator.
  final int limit;

  final String? search;
  final bool? isFeatured;
}

/// A page of brands, ordered server-side — there is no `sort` parameter.
class GetBrandsUseCase extends UseCase<Paginated<Brand>, GetBrandsParams> {
  const GetBrandsUseCase(this._repository);

  final CategoriesRepository _repository;

  @override
  Future<Result<Paginated<Brand>>> call(GetBrandsParams params) =>
      _repository.getBrands(
        page: params.page,
        limit: params.limit,
        search: params.search,
        isFeatured: params.isFeatured,
      );
}
