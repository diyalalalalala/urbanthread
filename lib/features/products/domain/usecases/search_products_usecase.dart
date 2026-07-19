import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product.dart';
import '../entities/product_query.dart';
import '../repositories/product_repository.dart';

/// Runs a catalogue search.
///
/// An empty term is rejected here rather than sent: `/products/search`
/// answers a blank `search` with a 400, and paying a round trip to learn that
/// on every cleared search box would be wasteful — and would flash an error
/// on a screen the user is simply resetting.
class SearchProductsUseCase extends UseCase<Paginated<Product>, ProductQuery> {
  const SearchProductsUseCase(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<Paginated<Product>>> call(ProductQuery params) {
    final term = params.search?.trim() ?? '';
    if (term.isEmpty) {
      return Future.value(
        const Result.failure(
          ValidationFailure(
            'A search term is required',
            errors: [
              FieldError(field: 'search', message: 'Provide a search term'),
            ],
          ),
        ),
      );
    }
    return _repository.searchProducts(params.copyWith(search: term));
  }
}
