import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/app_notification.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  const NotificationModel({
    required this.id,
    this.audience = 'user',
    this.type = '',
    this.title = '',
    this.message = '',
    this.link = '',
    this.entityType = '',
    this.entityId,
    this.isRead = false,
    this.readAt,
    this.createdAt,
    this.expiresAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  final String audience;

  final String type;
  final String title;
  final String message;

  final String link;

  final String entityType;
  final String? entityId;
  final bool isRead;
  final String? readAt;
  final String? createdAt;
  final String? expiresAt;

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  NotificationModel copyWith({bool? isRead, String? readAt}) =>
      NotificationModel(
        id: id,
        audience: audience,
        type: type,
        title: title,
        message: message,
        link: link,
        entityType: entityType,
        entityId: entityId,
        isRead: isRead ?? this.isRead,
        readAt: readAt ?? this.readAt,
        createdAt: createdAt,
        expiresAt: expiresAt,
      );

  AppNotification toEntity() => AppNotification(
        id: id,
        type: NotificationType.parse(type),
        title: title,
        message: message,
        link: link,
        entityType: entityType,
        entityId: (entityId == null || entityId!.isEmpty) ? null : entityId,
        isRead: isRead,
        readAt: _parseDate(readAt),
        createdAt: _parseDate(createdAt),
        expiresAt: _parseDate(expiresAt),
      );
}

@JsonSerializable(createToJson: false)
class UnreadCountModel {
  const UnreadCountModel({this.unread = 0});

  factory UnreadCountModel.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountModelFromJson(json);

  final int unread;
}

@JsonSerializable(createToJson: false)
class UpdatedCountModel {
  const UpdatedCountModel({this.updated = 0});

  factory UpdatedCountModel.fromJson(Map<String, dynamic> json) =>
      _$UpdatedCountModelFromJson(json);

  final int updated;
}

@JsonSerializable(createToJson: false)
class DeletedCountModel {
  const DeletedCountModel({this.deleted = 0});

  factory DeletedCountModel.fromJson(Map<String, dynamic> json) =>
      _$DeletedCountModelFromJson(json);

  final int deleted;
}

DateTime? _parseDate(String? raw) =>
    (raw == null || raw.isEmpty) ? null : DateTime.tryParse(raw);
