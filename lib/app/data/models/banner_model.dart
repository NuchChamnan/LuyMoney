import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  final String id;
  final String imageUrl;
  final String title;
  final String linkUrl;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;

  const BannerModel({
    required this.id,
    required this.imageUrl,
    this.title = '',
    this.linkUrl = '',
    this.sortOrder = 0,
    this.isActive = true,
    required this.createdAt,
  });

  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BannerModel(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      title: data['title'] ?? '',
      linkUrl: data['linkUrl'] ?? '',
      sortOrder: data['sortOrder'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'imageUrl': imageUrl,
        'title': title,
        'linkUrl': linkUrl,
        'sortOrder': sortOrder,
        'isActive': isActive,
      };
}
