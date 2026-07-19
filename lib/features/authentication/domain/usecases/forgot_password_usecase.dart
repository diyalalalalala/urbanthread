import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../repositories/auth_repository.dart';

/// Requests a password reset link.
///
/// Returns the server's message verbatim. It is deliberately non-committal
/// ("If an account exists for that address…") so the endpoint cannot be used
/// to discover which addresses are registered — showing a friendlier,
/// more definite string would leak exactly what it withholds.
class ForgotPasswordUseCase extends UseCase<String, String> {
  const ForgotPasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<String>> call(String email) =>
      _repository.forgotPassword(email);
}
