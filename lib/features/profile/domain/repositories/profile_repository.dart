import '../../../../core/domain/result.dart';
import '../../../authentication/domain/entities/user.dart';
import '../entities/recently_viewed_item.dart';

abstract interface class ProfileRepository {
  Future<Result<User>> getProfile();

  User? get cachedProfile;

  Future<Result<User>> updateProfile({String? name, String? phone});

  Future<Result<User>> uploadAvatar(String filePath);

  Future<Result<User>> removeAvatar();

  Future<Result<List<RecentlyViewedItem>>> getRecentlyViewed();

  Future<Result<void>> clearRecentlyViewed();
}
