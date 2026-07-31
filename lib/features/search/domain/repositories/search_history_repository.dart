import '../../../../core/domain/result.dart';

abstract interface class SearchHistoryRepository {
  List<String> get terms;

  Future<Result<List<String>>> add(String term);

  Future<Result<List<String>>> remove(String term);

  Future<Result<List<String>>> clear();
}
