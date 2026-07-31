import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_envelope.dart';
import '../models/notification_model.dart';

part 'notification_remote_datasource.g.dart';

@RestApi()
abstract class NotificationRemoteDataSource {
  factory NotificationRemoteDataSource(Dio dio, {String baseUrl}) =
      _NotificationRemoteDataSource;

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

  @DELETE('/notifications/{id}')
  Future<void> deleteNotification(@Path('id') String id);

  @DELETE(ApiEndpoints.deleteReadNotifications)
  Future<ApiEnvelope<DeletedCountModel>> deleteRead();
}
