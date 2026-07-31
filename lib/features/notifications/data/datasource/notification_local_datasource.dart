import '../../../../core/storage/cache_store.dart';
import '../models/notification_model.dart';

class NotificationLocalDataSource {
  const NotificationLocalDataSource(this._cache);

  static const _listKey = 'notifications:first-page';
  static const _unreadKey = 'notifications:unread-count';

  final CacheStore _cache;

  List<NotificationModel> readNotifications() =>
      _cache.readList<NotificationModel>(
        _listKey,
        (json) => NotificationModel.fromJson(json! as Map<String, dynamic>),
      );

  Future<void> writeNotifications(List<NotificationModel> items) => _cache.write(
        _listKey,
        items.map((item) => item.toJson()).toList(growable: false),
      );

  int? readUnreadCount() =>
      _cache.read<int?>(_unreadKey, (json) => json is int ? json : null);

  Future<void> writeUnreadCount(int count) => _cache.write(_unreadKey, count);

  Future<void> clear() async {
    await _cache.delete(_listKey);
    await _cache.delete(_unreadKey);
  }
}
