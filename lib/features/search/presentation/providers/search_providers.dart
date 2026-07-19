import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/search_history_repository_impl.dart';
import '../../domain/repositories/search_history_repository.dart';
import '../../domain/usecases/add_search_term_usecase.dart';
import '../../domain/usecases/clear_search_history_usecase.dart';
import '../../domain/usecases/get_search_history_usecase.dart';
import '../../domain/usecases/remove_search_term_usecase.dart';

part 'search_providers.g.dart';

/// Wiring for search.
///
/// The search *results* come from the catalogue's own
/// `SearchProductsUseCase` — this feature owns the screen and the history,
/// not a second copy of the product API. Only the history has its own
/// repository here.

@Riverpod(keepAlive: true)
SearchHistoryRepository searchHistoryRepository(Ref ref) =>
    SearchHistoryRepositoryImpl(ref.watch(preferencesServiceProvider));

@riverpod
GetSearchHistoryUseCase getSearchHistoryUseCase(Ref ref) =>
    GetSearchHistoryUseCase(ref.watch(searchHistoryRepositoryProvider));

@riverpod
AddSearchTermUseCase addSearchTermUseCase(Ref ref) =>
    AddSearchTermUseCase(ref.watch(searchHistoryRepositoryProvider));

@riverpod
RemoveSearchTermUseCase removeSearchTermUseCase(Ref ref) =>
    RemoveSearchTermUseCase(ref.watch(searchHistoryRepositoryProvider));

@riverpod
ClearSearchHistoryUseCase clearSearchHistoryUseCase(Ref ref) =>
    ClearSearchHistoryUseCase(ref.watch(searchHistoryRepositoryProvider));
