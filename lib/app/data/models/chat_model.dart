import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, system }

class ChatModel {
  final String id;
  final String senderId;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final MessageType type;
  final String? imageUrl;
  final bool isFromAdmin;

  const ChatModel({
    required this.id,
    required this.senderId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type = MessageType.text,
    this.imageUrl,
    this.isFromAdmin = false,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      type: MessageType.values.byName(data['type'] ?? 'text'),
      imageUrl: data['imageUrl'],
      isFromAdmin: data['isFromAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'message': message,
        'timestamp': Timestamp.fromDate(timestamp),
        'isRead': isRead,
        'type': type.name,
        'imageUrl': imageUrl,
        'isFromAdmin': isFromAdmin,
      };
}
