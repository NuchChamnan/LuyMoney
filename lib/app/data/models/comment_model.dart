import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String text;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userAvatarUrl: data['userAvatarUrl'],
      text: data['text'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'userAvatarUrl': userAvatarUrl,
        'text': text,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
