import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_envelope.dart';
import '../models/notification_model.dart';

part 'notification_remote_datasource.g.dart';

/// Typed HTTP surface for `/notifications`.
@RestApi()
abstract class NotificationRemoteDataSource {
  factory NotificationRemoteDataSource(Dio dio, {String baseUrl}) =
      _NotificationRemoteDataSource;

  /// Newest first. [unread] only narrows the query when truthy, so the
  /// repository omits it entirely rather than sending `false`.
  @GET(ApiEndpoints.notifications)
  Future<ApiEnvelope<List<NotificationModel>>> getNotifications({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('unread') bool? unread,
    @Query('type') String? type,
  });

  @GET(ApiEndpoints.unreadNotificationCount)
  Future<ApiEnvelope<UnreadCountModel>> getUnreadCount();

  @PATCH('/notifications/{id}/read')
  Future<ApiEnvelope<NotificationModel>> markAsRead(@Path('id') String id);

  @PATCH(ApiEndpoints.readAllNotifications)
  Future<ApiEnvelope<UpdatedCountModel>> markAllAsRead();

  /// 204, no body.
  @DELETE('/notifications/{id}')
  Future<void> deleteNotification(@Path('id') String id);

  /// 200 **with** a body — the asymmetry with the single delete above is
  /// deliberate on the backend, and decoding this one as void would throw
  /// away the count the UI reports.
  @DELETE(ApiEndpoints.deleteReadNotifications)
  Future<ApiEnvelope<DeletedCountModel>> deleteRead();
}
