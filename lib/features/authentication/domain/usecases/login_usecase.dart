import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  const LoginParams({required this.email, required this.password});

  final String email;
  final String password;
}

/// Signs in with email and password.
///
/// The API answers an unknown address and a wrong password with the identical
/// 401, so an address cannot be probed for existence — the UI must not try to
/// distinguish the two cases either.
class LoginUseCase extends UseCase<User, LoginParams> {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<User>> call(LoginParams params) =>
      _repository.login(email: params.email, password: params.password);
}
