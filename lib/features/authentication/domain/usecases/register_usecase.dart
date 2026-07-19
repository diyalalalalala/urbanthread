import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
  });

  final String name;
  final String email;
  final String password;
  final String? phone;
}

/// Creates a customer account and signs in.
///
/// `role`, `isActive` and `isEmailVerified` are stripped server-side, so there
/// is no way to self-provision an administrator.
class RegisterUseCase extends UseCase<User, RegisterParams> {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<User>> call(RegisterParams params) => _repository.register(
        name: params.name,
        email: params.email,
        password: params.password,
        phone: params.phone,
      );
}
