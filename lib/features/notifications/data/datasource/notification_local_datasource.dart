import '../../../../core/storage/cache_store.dart';
import '../models/notification_model.dart';

/// Offline copy of the notification list.
///
/// Only the first page is kept. Notifications are read newest-first and
/// nobody scrolls to page four without a connection, so caching deeper pages
/// would cost storage for a screen that will never be shown.
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

  /// The last known unread count, so the app-bar badge renders at launch
  /// without a round trip.
  int? readUnreadCount() =>
      _cache.read<int?>(_unreadKey, (json) => json is int ? json : null);

  Future<void> writeUnreadCount(int count) => _cache.write(_unreadKey, count);

  Future<void> clear() async {
    await _cache.delete(_listKey);
    await _cache.delete(_unreadKey);
  }
}
