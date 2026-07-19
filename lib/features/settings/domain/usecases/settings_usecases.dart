import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/theme_preference.dart';
import '../repositories/settings_repository.dart';

/// Persists the chosen colour scheme.
class SetThemePreferenceUseCase extends UseCase<void, ThemePreference> {
  const SetThemePreferenceUseCase(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<void>> call(ThemePreference params) async {
    await _repository.saveThemePreference(params);
    return const Result.success(null);
  }
}

/// Empties the catalogue cache to reclaim storage.
class ClearCatalogueCacheUseCase extends UseCase<void, NoParams> {
  const ClearCatalogueCacheUseCase(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) =>
      _repository.clearCatalogueCache();
}

class ClearSearchHistoryUseCase extends UseCase<void, NoParams> {
  const ClearSearchHistoryUseCase(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) =>
      _repository.clearSearchHistory();
}
