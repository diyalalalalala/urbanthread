import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  const LoginParams({required this.email, required this.password});

  final String email;
  final String password;
}

class LoginUseCase extends UseCase<User, LoginParams> {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<User>> call(LoginParams params) =>
      _repository.login(email: params.email, password: params.password);
}
