// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['_id'] as String? ?? '',
      audience: json['audience'] as String? ?? 'user',
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      link: json['link'] as String? ?? '',
      entityType: json['entityType'] as String? ?? '',
      entityId: json['entityId'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] as String?,
      createdAt: json['createdAt'] as String?,
      expiresAt: json['expiresAt'] as String?,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'audience': instance.audience,
      'type': instance.type,
      'title': instance.title,
      'message': instance.message,
      'link': instance.link,
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'isRead': instance.isRead,
      'readAt': instance.readAt,
      'createdAt': instance.createdAt,
      'expiresAt': instance.expiresAt,
    };

UnreadCountModel _$UnreadCountModelFromJson(Map<String, dynamic> json) =>
    UnreadCountModel(unread: (json['unread'] as num?)?.toInt() ?? 0);

UpdatedCountModel _$UpdatedCountModelFromJson(Map<String, dynamic> json) =>
    UpdatedCountModel(updated: (json['updated'] as num?)?.toInt() ?? 0);

DeletedCountModel _$DeletedCountModelFromJson(Map<String, dynamic> json) =>
    DeletedCountModel(deleted: (json['deleted'] as num?)?.toInt() ?? 0);
