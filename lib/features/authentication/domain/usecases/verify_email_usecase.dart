import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Confirms an email address from the link's token, unlocking checkout and
/// reviews.
class VerifyEmailUseCase extends UseCase<User, String> {
  const VerifyEmailUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<User>> call(String token) => _repository.verifyEmail(token);
}

/// Sends the verification email again.
class ResendVerificationUseCase extends UseCase<String, String> {
  const ResendVerificationUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<String>> call(String email) =>
      _repository.resendVerification(email);
}
