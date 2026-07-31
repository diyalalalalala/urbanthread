import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordParams {
  const ResetPasswordParams({required this.token, required this.password});

  final String token;
  final String password;
}

class ResetPasswordUseCase extends UseCase<String, ResetPasswordParams> {
  const ResetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<String>> call(ResetPasswordParams params) =>
      _repository.resetPassword(
        token: params.token,
        password: params.password,
      );
}
