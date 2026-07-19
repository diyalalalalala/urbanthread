import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/verify_email_usecase.dart';

part 'auth_providers.g.dart';

/// Wiring for the authentication feature.
///
/// Kept separate from the state notifier so the object graph is readable in
/// one place, and so a test can override exactly one edge — usually
/// [authRepositoryProvider] — without rebuilding the rest.

@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(Ref ref) =>
    AuthRemoteDataSource(ref.watch(dioProvider));

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
      remote: ref.watch(authRemoteDataSourceProvider),
      tokenStorage: ref.watch(tokenStorageProvider),
      preferences: ref.watch(preferencesServiceProvider),
      sessionEvents: ref.watch(sessionEventsProvider),
    );

@riverpod
LoginUseCase loginUseCase(Ref ref) =>
    LoginUseCase(ref.watch(authRepositoryProvider));

@riverpod
RegisterUseCase registerUseCase(Ref ref) =>
    RegisterUseCase(ref.watch(authRepositoryProvider));

@riverpod
LogoutUseCase logoutUseCase(Ref ref) =>
    LogoutUseCase(ref.watch(authRepositoryProvider));

@riverpod
LogoutAllUseCase logoutAllUseCase(Ref ref) =>
    LogoutAllUseCase(ref.watch(authRepositoryProvider));

@riverpod
GetCurrentUserUseCase getCurrentUserUseCase(Ref ref) =>
    GetCurrentUserUseCase(ref.watch(authRepositoryProvider));

@riverpod
ForgotPasswordUseCase forgotPasswordUseCase(Ref ref) =>
    ForgotPasswordUseCase(ref.watch(authRepositoryProvider));

@riverpod
ResetPasswordUseCase resetPasswordUseCase(Ref ref) =>
    ResetPasswordUseCase(ref.watch(authRepositoryProvider));

@riverpod
ChangePasswordUseCase changePasswordUseCase(Ref ref) =>
    ChangePasswordUseCase(ref.watch(authRepositoryProvider));

@riverpod
VerifyEmailUseCase verifyEmailUseCase(Ref ref) =>
    VerifyEmailUseCase(ref.watch(authRepositoryProvider));

@riverpod
ResendVerificationUseCase resendVerificationUseCase(Ref ref) =>
    ResendVerificationUseCase(ref.watch(authRepositoryProvider));
