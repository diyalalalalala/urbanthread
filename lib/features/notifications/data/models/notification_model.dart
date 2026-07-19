import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/app_notification.dart';

part 'notification_model.g.dart';

/// Wire format for a notification.
///
/// List responses are `.lean()`, so there is no `id` virtual — `_id` is the
/// only identifier present on every path.
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

  /// `"user"` or `"admin"`. The customer app only ever receives `"user"`
  /// rows — the route filters by the caller's audience — but it is carried
  /// through rather than dropped so an unexpected row is visible in a log.
  final String audience;

  final String type;
  final String title;
  final String message;

  /// Defaults to `""`, not null.
  final String link;

  final String entityType;
  final String? entityId;
  final bool isRead;
  final String? readAt;
  final String? createdAt;
  final String? expiresAt;

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  /// Used to keep the offline copy in step with a read/unread mutation
  /// without re-fetching the page.
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

/// `GET /notifications/unread-count` → `{ unread: 3 }`.
@JsonSerializable(createToJson: false)
class UnreadCountModel {
  const UnreadCountModel({this.unread = 0});

  factory UnreadCountModel.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountModelFromJson(json);

  final int unread;
}

/// `PATCH /notifications/read-all` → `{ updated: 7 }`.
@JsonSerializable(createToJson: false)
class UpdatedCountModel {
  const UpdatedCountModel({this.updated = 0});

  factory UpdatedCountModel.fromJson(Map<String, dynamic> json) =>
      _$UpdatedCountModelFromJson(json);

  final int updated;
}

/// `DELETE /notifications/read` → `{ deleted: 7 }`, returned with a 200 —
/// unlike `DELETE /notifications/{id}`, which answers 204 and no body.
@JsonSerializable(createToJson: false)
class DeletedCountModel {
  const DeletedCountModel({this.deleted = 0});

  factory DeletedCountModel.fromJson(Map<String, dynamic> json) =>
      _$DeletedCountModelFromJson(json);

  final int deleted;
}

DateTime? _parseDate(String? raw) =>
    (raw == null || raw.isEmpty) ? null : DateTime.tryParse(raw);
