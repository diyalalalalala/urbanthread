import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../repositories/search_history_repository.dart';

class RemoveSearchTermUseCase extends UseCase<List<String>, String> {
  const RemoveSearchTermUseCase(this._repository);

  final SearchHistoryRepository _repository;

  @override
  Future<Result<List<String>>> call(String params) =>
      _repository.remove(params);
}
