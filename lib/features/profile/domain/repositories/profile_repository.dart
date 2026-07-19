import '../../../../core/domain/result.dart';
import '../../../authentication/domain/entities/user.dart';
import '../entities/recently_viewed_item.dart';

/// The account-profile contract.
///
/// Reuses the authentication feature's [User] rather than declaring a second
/// profile entity: `GET /users/me` and `GET /auth/me` return the same
/// document, and two entities for one resource would guarantee they drift.
abstract interface class ProfileRepository {
  /// `GET /users/me`. Falls back to the cached copy when offline.
  Future<Result<User>> getProfile();

  /// The last profile written to the cache, without touching the network.
  User? get cachedProfile;

  /// `PATCH /users/me`. Only `name` and `phone` are accepted by the
  /// validator — anything else is silently dropped — and an update that
  /// changes nothing is a 400, so both arguments being null is refused
  /// locally rather than round-tripped.
  Future<Result<User>> updateProfile({String? name, String? phone});

  /// `POST /users/me/avatar`, multipart. [filePath] is a local image path;
  /// the repository validates size and type before uploading.
  Future<Result<User>> uploadAvatar(String filePath);

  /// `DELETE /users/me/avatar`. A 400 comes back when there was no avatar.
  Future<Result<User>> removeAvatar();

  /// `GET /users/me/recently-viewed` — a bare array, capped at 20.
  Future<Result<List<RecentlyViewedItem>>> getRecentlyViewed();

  /// `DELETE /users/me/recently-viewed` — answers 204 with no body.
  Future<Result<void>> clearRecentlyViewed();
}
