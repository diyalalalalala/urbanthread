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

  static const maxAvatarBytes = 5 * 1024 * 1024;

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
        'avatar': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split(Platform.pathSeparator).last,
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

  Future<User> _persist(UserModel user) async {
    final json = user.toJson();
    await _local.writeProfile(user);
    await _preferences.saveUser(json);
    return user.toEntity();
  }
}
