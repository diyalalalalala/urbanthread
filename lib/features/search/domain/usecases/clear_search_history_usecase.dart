import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../repositories/search_history_repository.dart';

class ClearSearchHistoryUseCase extends UseCase<List<String>, NoParams> {
  const ClearSearchHistoryUseCase(this._repository);

  final SearchHistoryRepository _repository;

  @override
  Future<Result<List<String>>> call(NoParams params) => _repository.clear();
}
