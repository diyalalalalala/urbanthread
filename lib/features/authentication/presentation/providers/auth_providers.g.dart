// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Wiring for the authentication feature.
///
/// Kept separate from the state notifier so the object graph is readable in
/// one place, and so a test can override exactly one edge — usually
/// [authRepositoryProvider] — without rebuilding the rest.

@ProviderFor(authRemoteDataSource)
final authRemoteDataSourceProvider = AuthRemoteDataSourceProvider._();

/// Wiring for the authentication feature.
///
/// Kept separate from the state notifier so the object graph is readable in
/// one place, and so a test can override exactly one edge — usually
/// [authRepositoryProvider] — without rebuilding the rest.

final class AuthRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          AuthRemoteDataSource,
          AuthRemoteDataSource,
          AuthRemoteDataSource
        >
    with $Provider<AuthRemoteDataSource> {
  /// Wiring for the authentication feature.
  ///
  /// Kept separate from the state notifier so the object graph is readable in
  /// one place, and so a test can override exactly one edge — usually
  /// [authRepositoryProvider] — without rebuilding the rest.
  AuthRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<AuthRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthRemoteDataSource create(Ref ref) {
    return authRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRemoteDataSource>(value),
    );
  }
}

String _$authRemoteDataSourceHash() =>
    r'3abbec460b69475c628cd352fc5504e003cc4122';

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'dbbaa1e677d015bf8fba3caa885e93e33d720fc5';

@ProviderFor(loginUseCase)
final loginUseCaseProvider = LoginUseCaseProvider._();

final class LoginUseCaseProvider
    extends $FunctionalProvider<LoginUseCase, LoginUseCase, LoginUseCase>
    with $Provider<LoginUseCase> {
  LoginUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginUseCaseHash();

  @$internal
  @override
  $ProviderElement<LoginUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoginUseCase create(Ref ref) {
    return loginUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoginUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoginUseCase>(value),
    );
  }
}

String _$loginUseCaseHash() => r'5a95b111ff086652f0c947b88bcfe26ea7ce95be';

@ProviderFor(registerUseCase)
final registerUseCaseProvider = RegisterUseCaseProvider._();

final class RegisterUseCaseProvider
    extends
        $FunctionalProvider<RegisterUseCase, RegisterUseCase, RegisterUseCase>
    with $Provider<RegisterUseCase> {
  RegisterUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registerUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registerUseCaseHash();

  @$internal
  @override
  $ProviderElement<RegisterUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RegisterUseCase create(Ref ref) {
    return registerUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RegisterUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RegisterUseCase>(value),
    );
  }
}

String _$registerUseCaseHash() => r'18669430c22e1c7844c19dd3dcbe2285a2250a73';

@ProviderFor(logoutUseCase)
final logoutUseCaseProvider = LogoutUseCaseProvider._();

final class LogoutUseCaseProvider
    extends $FunctionalProvider<LogoutUseCase, LogoutUseCase, LogoutUseCase>
    with $Provider<LogoutUseCase> {
  LogoutUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logoutUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logoutUseCaseHash();

  @$internal
  @override
  $ProviderElement<LogoutUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LogoutUseCase create(Ref ref) {
    return logoutUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LogoutUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LogoutUseCase>(value),
    );
  }
}

String _$logoutUseCaseHash() => r'c3c6c589cbff5a2f6618cc56b1f9faae632da27a';

@ProviderFor(logoutAllUseCase)
final logoutAllUseCaseProvider = LogoutAllUseCaseProvider._();

final class LogoutAllUseCaseProvider
    extends
        $FunctionalProvider<
          LogoutAllUseCase,
          LogoutAllUseCase,
          LogoutAllUseCase
        >
    with $Provider<LogoutAllUseCase> {
  LogoutAllUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logoutAllUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logoutAllUseCaseHash();

  @$internal
  @override
  $ProviderElement<LogoutAllUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LogoutAllUseCase create(Ref ref) {
    return logoutAllUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LogoutAllUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LogoutAllUseCase>(value),
    );
  }
}

String _$logoutAllUseCaseHash() => r'570dfa3b935a408a12317781440804afe31edd01';

@ProviderFor(getCurrentUserUseCase)
final getCurrentUserUseCaseProvider = GetCurrentUserUseCaseProvider._();

final class GetCurrentUserUseCaseProvider
    extends
        $FunctionalProvider<
          GetCurrentUserUseCase,
          GetCurrentUserUseCase,
          GetCurrentUserUseCase
        >
    with $Provider<GetCurrentUserUseCase> {
  GetCurrentUserUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getCurrentUserUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getCurrentUserUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCurrentUserUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetCurrentUserUseCase create(Ref ref) {
    return getCurrentUserUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCurrentUserUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCurrentUserUseCase>(value),
    );
  }
}

String _$getCurrentUserUseCaseHash() =>
    r'4c558036519273e5a4eae954197dcf61cff31679';

@ProviderFor(forgotPasswordUseCase)
final forgotPasswordUseCaseProvider = ForgotPasswordUseCaseProvider._();

final class ForgotPasswordUseCaseProvider
    extends
        $FunctionalProvider<
          ForgotPasswordUseCase,
          ForgotPasswordUseCase,
          ForgotPasswordUseCase
        >
    with $Provider<ForgotPasswordUseCase> {
  ForgotPasswordUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forgotPasswordUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forgotPasswordUseCaseHash();

  @$internal
  @override
  $ProviderElement<ForgotPasswordUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ForgotPasswordUseCase create(Ref ref) {
    return forgotPasswordUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ForgotPasswordUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ForgotPasswordUseCase>(value),
    );
  }
}

String _$forgotPasswordUseCaseHash() =>
    r'fbdfcfd332abb715b8d3fc0b285a896d26dafb3c';

@ProviderFor(resetPasswordUseCase)
final resetPasswordUseCaseProvider = ResetPasswordUseCaseProvider._();

final class ResetPasswordUseCaseProvider
    extends
        $FunctionalProvider<
          ResetPasswordUseCase,
          ResetPasswordUseCase,
          ResetPasswordUseCase
        >
    with $Provider<ResetPasswordUseCase> {
  ResetPasswordUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resetPasswordUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resetPasswordUseCaseHash();

  @$internal
  @override
  $ProviderElement<ResetPasswordUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ResetPasswordUseCase create(Ref ref) {
    return resetPasswordUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ResetPasswordUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ResetPasswordUseCase>(value),
    );
  }
}

String _$resetPasswordUseCaseHash() =>
    r'954e56b2b94719a458ccec2b3c9101151c1cde49';

@ProviderFor(changePasswordUseCase)
final changePasswordUseCaseProvider = ChangePasswordUseCaseProvider._();

final class ChangePasswordUseCaseProvider
    extends
        $FunctionalProvider<
          ChangePasswordUseCase,
          ChangePasswordUseCase,
          ChangePasswordUseCase
        >
    with $Provider<ChangePasswordUseCase> {
  ChangePasswordUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changePasswordUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changePasswordUseCaseHash();

  @$internal
  @override
  $ProviderElement<ChangePasswordUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChangePasswordUseCase create(Ref ref) {
    return changePasswordUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChangePasswordUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChangePasswordUseCase>(value),
    );
  }
}

String _$changePasswordUseCaseHash() =>
    r'87ac37d0ab027c8def7825f6ae7fbe78f5a1d42f';

@ProviderFor(verifyEmailUseCase)
final verifyEmailUseCaseProvider = VerifyEmailUseCaseProvider._();

final class VerifyEmailUseCaseProvider
    extends
        $FunctionalProvider<
          VerifyEmailUseCase,
          VerifyEmailUseCase,
          VerifyEmailUseCase
        >
    with $Provider<VerifyEmailUseCase> {
  VerifyEmailUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'verifyEmailUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$verifyEmailUseCaseHash();

  @$internal
  @override
  $ProviderElement<VerifyEmailUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VerifyEmailUseCase create(Ref ref) {
    return verifyEmailUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VerifyEmailUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VerifyEmailUseCase>(value),
    );
  }
}

String _$verifyEmailUseCaseHash() =>
    r'16a79a670026b92b5c43a23aadd5eb73cd1c6bb3';

@ProviderFor(resendVerificationUseCase)
final resendVerificationUseCaseProvider = ResendVerificationUseCaseProvider._();

final class ResendVerificationUseCaseProvider
    extends
        $FunctionalProvider<
          ResendVerificationUseCase,
          ResendVerificationUseCase,
          ResendVerificationUseCase
        >
    with $Provider<ResendVerificationUseCase> {
  ResendVerificationUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resendVerificationUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resendVerificationUseCaseHash();

  @$internal
  @override
  $ProviderElement<ResendVerificationUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ResendVerificationUseCase create(Ref ref) {
    return resendVerificationUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ResendVerificationUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ResendVerificationUseCase>(value),
    );
  }
}

String _$resendVerificationUseCaseHash() =>
    r'57e293097153e410a929a61ed8d1d366b5c23ba9';
