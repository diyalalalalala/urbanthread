import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class ChangePasswordParams {
  const ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;
}

/// Changes the password for the signed-in user.
class ChangePasswordUseCase extends UseCase<User, ChangePasswordParams> {
  const ChangePasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<User>> call(ChangePasswordParams params) =>
      _repository.changePassword(
        currentPassword: params.currentPassword,
        newPassword: params.newPassword,
      );
}
