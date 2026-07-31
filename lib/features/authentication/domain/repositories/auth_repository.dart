import '../../../../core/domain/result.dart';
import '../entities/user.dart';

abstract interface class AuthRepository {
  Future<Result<User>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  });

  Future<Result<User>> login({
    required String email,
    required String password,
  });

  Future<Result<void>> logout();

  Future<Result<void>> logoutAll();

  Future<Result<User>> getCurrentUser();

  User? get cachedUser;

  bool get hasSession;

  Future<Result<String>> forgotPassword(String email);

  Future<Result<String>> resetPassword({
    required String token,
    required String password,
  });

  Future<Result<User>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Stream<void> get onSessionExpired;
}
