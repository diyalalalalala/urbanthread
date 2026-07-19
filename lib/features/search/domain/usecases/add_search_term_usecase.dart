import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../repositories/search_history_repository.dart';

/// Records a term the shopper actually searched for.
class AddSearchTermUseCase extends UseCase<List<String>, String> {
  const AddSearchTermUseCase(this._repository);

  final SearchHistoryRepository _repository;

  @override
  Future<Result<List<String>>> call(String params) =>
      _repository.add(params);
}
