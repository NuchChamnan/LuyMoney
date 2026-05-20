import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luy_money/app/data/models/subscription_model.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String role; // 'user' | 'admin'
  final SubscriptionModel? subscription;
  final DateTime createdAt;
  final bool biometricEnabled;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.role = 'user',
    this.subscription,
    required this.createdAt,
    this.biometricEnabled = false,
  });

  bool get isAdmin => role == 'admin';
  bool get hasActiveSubscription => subscription?.isActive ?? false;

  factory UserModel.fromFirestore(DocumentSnapshot doc, {SubscriptionModel? subscription}) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      avatarUrl: data['avatarUrl'],
      role: data['role'] ?? 'user',
      subscription: subscription ??
          (data['subscription'] != null
              ? SubscriptionModel.fromMap(data['subscription'])
              : null),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      biometricEnabled: data['biometricEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => toMap();

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'phone': phone,
    'avatarUrl': avatarUrl,
    'role': role,
    'biometricEnabled': biometricEnabled,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  UserModel copyWith({
    String? name,
    String? phone,
    String? avatarUrl,
    bool? biometricEnabled,
    SubscriptionModel? subscription,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role,
      subscription: subscription ?? this.subscription,
      createdAt: createdAt,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }
}
