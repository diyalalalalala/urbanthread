import '../../../../core/storage/cache_store.dart';
import '../../../authentication/data/models/user_model.dart';
import '../models/recently_viewed_model.dart';

class ProfileLocalDataSource {
  const ProfileLocalDataSource(this._cache);

  static const _profileKey = 'profile:me';
  static const _recentlyViewedKey = 'profile:recently-viewed';

  final CacheStore _cache;

  UserModel? readProfile() => _cache.read<UserModel?>(
        _profileKey,
        (json) => json is Map<String, dynamic> ? UserModel.fromJson(json) : null,
      );

  Future<void> writeProfile(UserModel user) =>
      _cache.write(_profileKey, user.toJson());

  Future<void> clearProfile() => _cache.delete(_profileKey);

  List<RecentlyViewedModel> readRecentlyViewed() =>
      _cache.readList<RecentlyViewedModel>(
        _recentlyViewedKey,
        (json) => RecentlyViewedModel.fromJson(json! as Map<String, dynamic>),
      );

  Future<void> writeRecentlyViewed(List<RecentlyViewedModel> items) =>
      _cache.write(
        _recentlyViewedKey,
        items.map((item) => item.toJson()).toList(growable: false),
      );

  Future<void> clearRecentlyViewed() => _cache.delete(_recentlyViewedKey);
}
