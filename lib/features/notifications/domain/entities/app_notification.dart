import 'package:equatable/equatable.dart';

enum NotificationType {
  orderPlaced('order_placed'),
  orderStatusChanged('order_status_changed'),
  orderDelivered('order_delivered'),
  orderCancelled('order_cancelled'),
  returnRequested('return_requested'),
  returnResolved('return_resolved'),
  lowStock('low_stock'),
  newUser('new_user'),
  newOrder('new_order'),
  reviewPosted('review_posted'),
  unknown('');

  const NotificationType(this.wireValue);

  final String wireValue;

  static NotificationType parse(String? raw) {
    if (raw == null || raw.isEmpty) return NotificationType.unknown;
    for (final type in NotificationType.values) {
      if (type.wireValue == raw) return type;
    }
    return NotificationType.unknown;
  }

  static const customerFacing = [
    orderPlaced,
    orderStatusChanged,
    orderDelivered,
    orderCancelled,
    returnRequested,
    returnResolved,
  ];

  String get label => switch (this) {
        NotificationType.orderPlaced => 'Order placed',
        NotificationType.orderStatusChanged => 'Order update',
        NotificationType.orderDelivered => 'Delivered',
        NotificationType.orderCancelled => 'Cancelled',
        NotificationType.returnRequested => 'Return requested',
        NotificationType.returnResolved => 'Return resolved',
        NotificationType.lowStock => 'Low stock',
        NotificationType.newUser => 'New customer',
        NotificationType.newOrder => 'New order',
        NotificationType.reviewPosted => 'Review posted',
        NotificationType.unknown => 'Notification',
      };
}

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.type = NotificationType.unknown,
    this.link = '',
    this.entityType = '',
    this.entityId,
    this.isRead = false,
    this.readAt,
    this.createdAt,
    this.expiresAt,
  });

  final String id;
  final NotificationType type;

  final String title;

  final String message;

  final String link;

  final String entityType;
  final String? entityId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  bool get hasLink => link.isNotEmpty;

  AppNotification copyWith({bool? isRead, DateTime? readAt}) =>
      AppNotification(
        id: id,
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

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        message,
        link,
        entityType,
        entityId,
        isRead,
        readAt,
        createdAt,
        expiresAt,
      ];
}
