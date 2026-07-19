import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Re-reads the signed-in user from the server, falling back to the cached
/// copy when offline.
class GetCurrentUserUseCase extends UseCase<User, NoParams> {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<User>> call(NoParams params) => _repository.getCurrentUser();
}
