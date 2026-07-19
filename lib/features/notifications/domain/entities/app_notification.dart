import 'package:equatable/equatable.dart';

/// Every value the backend's `type` enum can take.
///
/// [unknown] is not a server value — it is the landing pad for one. The enum
/// is shared between the customer and admin apps and gains entries as features
/// land, so parsing must degrade to a neutral bell icon rather than throwing
/// and blanking the whole list because of one unfamiliar row.
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

  /// The string the API sends. Empty for [unknown], which is never sent.
  final String wireValue;

  static NotificationType parse(String? raw) {
    if (raw == null || raw.isEmpty) return NotificationType.unknown;
    for (final type in NotificationType.values) {
      if (type.wireValue == raw) return type;
    }
    return NotificationType.unknown;
  }

  /// Types the customer app can filter by. The admin-audience ones
  /// (`low_stock`, `new_user`, `new_order`, `review_posted`) are never
  /// delivered to a customer, so offering them as filters would produce
  /// permanently empty results.
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

/// One row of `GET /notifications`.
///
/// Named `AppNotification` rather than `Notification` because Flutter already
/// exports a `Notification` class, and a screen importing both would not
/// compile.
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

  /// ≤ 140 characters.
  final String title;

  /// ≤ 500 characters.
  final String message;

  /// A **web** path such as `/orders/UT-20260718-0042`, defaulting to `""`.
  /// Resolving it to an in-app route is a presentation concern — see
  /// `notification_link.dart`.
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
