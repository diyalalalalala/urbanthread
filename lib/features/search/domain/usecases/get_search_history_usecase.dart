import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../repositories/search_history_repository.dart';

/// Reads the recent searches shown before a term is typed.
class GetSearchHistoryUseCase extends UseCase<List<String>, NoParams> {
  const GetSearchHistoryUseCase(this._repository);

  final SearchHistoryRepository _repository;

  @override
  Future<Result<List<String>>> call(NoParams params) async =>
      Result.success(_repository.terms);
}
