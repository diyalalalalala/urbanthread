import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase extends UseCase<String, String> {
  const ForgotPasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<String>> call(String email) =>
      _repository.forgotPassword(email);
}
