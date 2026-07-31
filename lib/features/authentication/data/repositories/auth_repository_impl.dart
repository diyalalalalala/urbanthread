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
    try {
      await _remote.logout();
    } on Object catch (_) {}
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

      if (failure is NetworkFailure || failure is TimeoutFailure) {
        final cached = cachedUser;
        if (cached != null) return Result.success(cached);
      }
      return Result.failure(failure);
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
    if (result.isSuccess) await _clearSession();
    return result;
  }

  Future<Result<String>> _messageOnly(Future<dynamic> Function() request) async {
    try {
      final envelope = await request();
      return Result.success(envelope.message as String);
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }
}
