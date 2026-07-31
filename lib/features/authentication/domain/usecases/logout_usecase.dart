import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase extends UseCase<void, NoParams> {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) => _repository.logout();
}

class LogoutAllUseCase extends UseCase<void, NoParams> {
  const LogoutAllUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) => _repository.logoutAll();
}
