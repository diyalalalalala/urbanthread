import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../../../authentication/domain/entities/user.dart';
import '../entities/recently_viewed_item.dart';
import '../repositories/profile_repository.dart';

/// Reads `/users/me`.
class GetProfileUseCase extends UseCase<User, NoParams> {
  const GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Result<User>> call(NoParams params) => _repository.getProfile();
}

class UpdateProfileParams {
  const UpdateProfileParams({this.name, this.phone});

  /// 2..80 characters. Null leaves it untouched.
  final String? name;

  /// Must match `/^[+]?[\d\s().-]{7,20}$/`. Null leaves it untouched.
  final String? phone;

  bool get isEmpty => name == null && phone == null;
}

/// Updates the editable half of the profile.
class UpdateProfileUseCase extends UseCase<User, UpdateProfileParams> {
  const UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Result<User>> call(UpdateProfileParams params) =>
      _repository.updateProfile(name: params.name, phone: params.phone);
}

/// Uploads a new avatar from a local file path.
class UploadAvatarUseCase extends UseCase<User, String> {
  const UploadAvatarUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Result<User>> call(String filePath) =>
      _repository.uploadAvatar(filePath);
}

class RemoveAvatarUseCase extends UseCase<User, NoParams> {
  const RemoveAvatarUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Result<User>> call(NoParams params) => _repository.removeAvatar();
}

class GetRecentlyViewedUseCase
    extends UseCase<List<RecentlyViewedItem>, NoParams> {
  const GetRecentlyViewedUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Result<List<RecentlyViewedItem>>> call(NoParams params) =>
      _repository.getRecentlyViewed();
}

class ClearRecentlyViewedUseCase extends UseCase<void, NoParams> {
  const ClearRecentlyViewedUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) =>
      _repository.clearRecentlyViewed();
}
