import 'package:dio/dio.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/session/session_events.dart';
import '../../../../core/storage/preferences_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';
import '../models/auth_models.dart';
import '../models/user_model.dart';

/// Turns the auth API into [Result]s, and owns the side effects of a session
/// starting or ending: the token in secure storage, the cached profile in
/// preferences.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required TokenStorage tokenStorage,
    required PreferencesService preferences,
    required SessionEvents sessionEvents,
  })  : _remote = remote,
        _tokenStorage = tokenStorage,
        _preferences = preferences,
        _sessionEvents = sessionEvents;

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;
  final PreferencesService _preferences;
  final SessionEvents _sessionEvents;

  @override
  Stream<void> get onSessionExpired => _sessionEvents.expired;

  @override
  bool get hasSession => _tokenStorage.hasToken;

  @override
  User? get cachedUser {
    final json = _preferences.cachedUser;
    if (json == null) return null;
    try {
      return UserModel.fromJson(json).toEntity();
    } on Object {
      // Written by an older build whose shape no longer parses. Not worth
      // surfacing — `getCurrentUser` will replace it on the next request.
      return null;
    }
  }

  @override
  Future<Result<User>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) =>
      _authenticate(
        () => _remote.register(
          RegisterRequest(
            name: name.trim(),
            email: email.trim().toLowerCase(),
            password: password,
            phone: (phone?.trim().isEmpty ?? true) ? null : phone!.trim(),
          ),
        ),
      );

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) =>
      _authenticate(
        () => _remote.login(
          LoginRequest(
            email: email.trim().toLowerCase(),
            password: password,
          ),
        ),
      );

  /// Shared tail of register and login: persist the token, cache the profile.
  ///
  /// The token is stored *before* the profile so a crash between the two
  /// leaves a usable session rather than an orphaned profile with no way to
  /// authenticate.
  Future<Result<User>> _authenticate(
    Future<dynamic> Function() request,
  ) async {
    try {
      final envelope = await request();
      final payload = envelope.data as AuthResponseModel;

      await _tokenStorage.save(payload.accessToken);
      await _preferences.saveUser(payload.user.toJson());

      return Result.success(payload.user.toEntity());
    } on DioException catch (error) {
      return Result.failure(ErrorMapper.toFailure(ErrorMapper.fromDio(error)));
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  @override
  Future<Result<void>> logout() async {
    // Tell the server first so the request still carries the token, but do
    // not let its failure block the local sign-out — an offline user must
    // still be able to leave.
    try {
      await _remote.logout();
    } on Object {
      // Intentionally ignored; the local clear below is what matters.
    }
    await _clearSession();
    return const Result.success(null);
  }

  @override
  Future<Result<void>> logoutAll() async {
    try {
      await _remote.logoutAll();
      await _clearSession();
      return const Result.success(null);
    } on Object catch (error) {
      // Unlike `logout`, this one must reach the server to mean anything —
      // its whole purpose is revoking tokens held on other devices. Report
      // the failure rather than pretending it worked.
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  Future<void> _clearSession() async {
    await _tokenStorage.clear();
    await _preferences.clearSession();
  }

  @override
  Future<Result<User>> getCurrentUser() async {
    try {
      final envelope = await _remote.getCurrentUser();
      final user = envelope.data;
      await _preferences.saveUser(user.toJson());
      return Result.success(user.toEntity());
    } on Object catch (error) {
      final failure = ErrorMapper.toFailure(error);

      // Offline is not a reason to sign someone out. Fall back to the cached
      // profile and let the UI carry on read-only.
      if (failure is NetworkFailure || failure is TimeoutFailure) {
        final cached = cachedUser;
        if (cached != null) return Result.success(cached);
      }
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<User>> verifyEmail(String token) async {
    try {
      final envelope = await _remote.verifyEmail(token);
      await _preferences.saveUser(envelope.data.toJson());
      return Result.success(envelope.data.toEntity());
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  @override
  Future<Result<User>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final envelope = await _remote.changePassword(
        ChangePasswordRequest(
          currentPassword: currentPassword,
          newPassword: newPassword,
        ),
      );
      return Result.success(envelope.data.toEntity());
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  @override
  Future<Result<String>> resendVerification(String email) => _messageOnly(
        () => _remote.resendVerification(
          EmailRequest(email: email.trim().toLowerCase()),
        ),
      );

  @override
  Future<Result<String>> forgotPassword(String email) => _messageOnly(
        () => _remote.forgotPassword(
          EmailRequest(email: email.trim().toLowerCase()),
        ),
      );

  @override
  Future<Result<String>> resetPassword({
    required String token,
    required String password,
  }) async {
    final result = await _messageOnly(
      () => _remote.resetPassword(token, ResetPasswordRequest(password: password)),
    );
    // The reset bumped `tokenVersion`, so any token this device still holds
    // is already dead. Clear it so the app does not keep sending it.
    if (result.isSuccess) await _clearSession();
    return result;
  }

  /// For endpoints whose entire payload is the message — the backend
  /// deliberately returns `data: null` and a vague string that must not be
  /// replaced with a guess ("If an account exists for that address…").
  Future<Result<String>> _messageOnly(Future<dynamic> Function() request) async {
    try {
      final envelope = await request();
      return Result.success(envelope.message as String);
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }
}
