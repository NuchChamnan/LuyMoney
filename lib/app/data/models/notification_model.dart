import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotificationModel {
  final String id;
  final String title;
  final String body;
  final String target; // 'all' | 'active' | 'expiring'
  final DateTime sentAt;
  final bool isRead;

  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.target = 'all',
    required this.sentAt,
    this.isRead = false,
  });

  factory AppNotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      target: data['target'] ?? 'all',
      sentAt: data['sentAt'] != null
          ? (data['sentAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  AppNotificationModel copyWith({bool? isRead}) => AppNotificationModel(
        id: id,
        title: title,
        body: body,
        target: target,
        sentAt: sentAt,
        isRead: isRead ?? this.isRead,
      );
}
