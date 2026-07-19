import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../repositories/auth_repository.dart';

/// Ends the session on this device.
class LogoutUseCase extends UseCase<void, NoParams> {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) => _repository.logout();
}

/// Ends every session for the account, everywhere.
///
/// Unlike [LogoutUseCase] this can genuinely fail: it only means something if
/// the server received it.
class LogoutAllUseCase extends UseCase<void, NoParams> {
  const LogoutAllUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) => _repository.logoutAll();
}
