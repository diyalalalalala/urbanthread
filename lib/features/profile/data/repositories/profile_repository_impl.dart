import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/preferences_service.dart';
import '../../../authentication/data/models/user_model.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../domain/entities/recently_viewed_item.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasource/profile_local_datasource.dart';
import '../datasource/profile_remote_datasource.dart';
import '../models/recently_viewed_model.dart';
import '../models/update_profile_request.dart';

/// The `/users/me` API as [Result]s, with an offline read path.
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({
    required ProfileRemoteDataSource remote,
    required ProfileLocalDataSource local,
    required NetworkInfo networkInfo,
    required PreferencesService preferences,
  })  : _remote = remote,
        _local = local,
        _networkInfo = networkInfo,
        _preferences = preferences;

  /// Multer's limit. Checked client-side so a 5 MB upload is not pushed over a
  /// mobile connection only to be rejected on arrival.
  static const maxAvatarBytes = 5 * 1024 * 1024;

  /// The exact set `fileFilter` accepts. Anything else is a 400 server-side.
  static const _allowedMimeTypes = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
    'avif': 'image/avif',
  };

  final ProfileRemoteDataSource _remote;
  final ProfileLocalDataSource _local;
  final NetworkInfo _networkInfo;
  final PreferencesService _preferences;

  @override
  User? get cachedProfile {
    try {
      return _local.readProfile()?.toEntity();
    } on Object {
      return null;
    }
  }

  @override
  Future<Result<User>> getProfile() async {
    if (!await _networkInfo.isConnected) {
      final cached = cachedProfile;
      return cached == null
          ? const Result.failure(EmptyCacheFailure())
          : Result.success(cached);
    }

    try {
      final envelope = await _remote.getProfile();
      return Result.success(await _persist(envelope.data));
    } on Object catch (error) {
      final failure = ErrorMapper.toFailure(error);
      // A transport failure falls back to cache; a 4xx does not — a 401 must
      // reach the session handler rather than being papered over with a stale
      // profile.
      if (failure is NetworkFailure || failure is TimeoutFailure) {
        final cached = cachedProfile;
        if (cached != null) return Result.success(cached);
      }
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<User>> updateProfile({String? name, String? phone}) async {
    final request = UpdateProfileRequest(name: name, phone: phone);
    if (request.isEmpty) {
      // The backend answers 400 for an empty effective update. Refusing here
      // keeps the error message specific instead of relaying a generic one.
      return const Result.failure(
        ValidationFailure('Change something before saving.'),
      );
    }

    try {
      final envelope = await _remote.updateProfile(request);
      return Result.success(await _persist(envelope.data));
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  @override
  Future<Result<User>> uploadAvatar(String filePath) async {
    final file = File(filePath);

    if (!file.existsSync()) {
      return const Result.failure(
        ValidationFailure('That image could not be read.'),
      );
    }

    final extension = filePath.split('.').last.toLowerCase();
    final mimeType = _allowedMimeTypes[extension];
    if (mimeType == null) {
      return const Result.failure(
        ValidationFailure('Choose a JPEG, PNG, WebP or AVIF image.'),
      );
    }

    if (await file.length() > maxAvatarBytes) {
      return const Result.failure(
        ValidationFailure('That image is larger than 5 MB.'),
      );
    }

    try {
      final parts = mimeType.split('/');
      final form = FormData.fromMap({
        // Field name is fixed by `upload.single('avatar')` on the route.
        'avatar': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split(Platform.pathSeparator).last,
          // Set explicitly: `fileFilter` reads the part's MIME type, and Dio
          // would otherwise send `application/octet-stream`.
          contentType: DioMediaType(parts.first, parts.last),
        ),
      });

      final envelope = await _remote.uploadAvatar(form);
      return Result.success(await _persist(envelope.data));
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  @override
  Future<Result<User>> removeAvatar() async {
    try {
      final envelope = await _remote.removeAvatar();
      return Result.success(await _persist(envelope.data));
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  @override
  Future<Result<List<RecentlyViewedItem>>> getRecentlyViewed() async {
    if (!await _networkInfo.isConnected) return _cachedRecentlyViewed();

    try {
      final envelope = await _remote.getRecentlyViewed();
      final items = envelope.data;
      await _local.writeRecentlyViewed(items);
      return Result.success(_toEntities(items));
    } on Object catch (error) {
      final failure = ErrorMapper.toFailure(error);
      if (failure is NetworkFailure || failure is TimeoutFailure) {
        final cached = _cachedRecentlyViewed();
        if (cached.isSuccess) return cached;
      }
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<void>> clearRecentlyViewed() async {
    try {
      // 204, no body — there is nothing to decode, only a status to survive.
      await _remote.clearRecentlyViewed();
      await _local.clearRecentlyViewed();
      return const Result.success(null);
    } on Object catch (error) {
      return Result.failure(ErrorMapper.toFailure(error));
    }
  }

  Result<List<RecentlyViewedItem>> _cachedRecentlyViewed() {
    final cached = _local.readRecentlyViewed();
    return cached.isEmpty
        ? const Result.failure(EmptyCacheFailure())
        : Result.success(_toEntities(cached));
  }

  List<RecentlyViewedItem> _toEntities(List<RecentlyViewedModel> items) =>
      items.map((item) => item.toEntity()).toList(growable: false);

  /// Writes a freshly fetched user to both stores.
  ///
  /// The session copy in preferences is updated too, so an avatar change or a
  /// rename is reflected in the app shell on the next cold start without
  /// waiting for `/auth/me`.
  Future<User> _persist(UserModel user) async {
    final json = user.toJson();
    await _local.writeProfile(user);
    await _preferences.saveUser(json);
    return user.toEntity();
  }
}
