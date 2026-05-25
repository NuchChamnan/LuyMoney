import 'package:cloud_firestore/cloud_firestore.dart';

enum SubscriptionPlan { monthly, quarterly, biannual, annual }

enum PaymentMethod { abaPay }

class SubscriptionPlanInfo {
  final SubscriptionPlan plan;
  final double price;
  final int durationDays;
  final String? badge;

  const SubscriptionPlanInfo({
    required this.plan,
    required this.price,
    required this.durationDays,
    this.badge,
  });

  String get id => plan.name;

  static List<SubscriptionPlanInfo> get plans => subscriptionPlans;

  double get pricePerMonth {
    final months = durationDays / 30;
    return price / months;
  }

  int get savingsPercent {
    const baseMonthlyPrice = 5.0;
    final savings =
        ((baseMonthlyPrice - pricePerMonth) / baseMonthlyPrice * 100).round();
    return savings > 0 ? savings : 0;
  }
}

const List<SubscriptionPlanInfo> subscriptionPlans = [
  SubscriptionPlanInfo(
    plan: SubscriptionPlan.monthly,
    price: 5.0,
    durationDays: 30,
  ),
  SubscriptionPlanInfo(
    plan: SubscriptionPlan.quarterly,
    price: 12.0,
    durationDays: 90,
  ),
  SubscriptionPlanInfo(
    plan: SubscriptionPlan.biannual,
    price: 20.0,
    durationDays: 180,
    badge: 'popular',
  ),
  SubscriptionPlanInfo(
    plan: SubscriptionPlan.annual,
    price: 35.0,
    durationDays: 365,
    badge: 'best_value',
  ),
];

class SubscriptionModel {
  final String id;
  final String userId;
  final String planId;
  final DateTime startDate;
  final DateTime expiryDate;
  final bool isActive;
  final String paymentMethod;
  final String transactionId;
  final double amountPaid;

  const SubscriptionModel({
    required this.id,
    required this.userId,
    required this.planId,
    required this.startDate,
    required this.expiryDate,
    required this.isActive,
    required this.paymentMethod,
    required this.transactionId,
    required this.amountPaid,
  });

  bool get isExpired => DateTime.now().isAfter(expiryDate);
  int get daysRemaining => expiryDate.difference(DateTime.now()).inDays;
  bool get isExpiringSoon => daysRemaining <= 7 && !isExpired;
  double get progressPercent {
    final total = expiryDate.difference(startDate).inDays;
    final elapsed = DateTime.now().difference(startDate).inDays;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  factory SubscriptionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubscriptionModel.fromMap({'id': doc.id, ...data});
  }

  factory SubscriptionModel.fromMap(Map<String, dynamic> data) {
    return SubscriptionModel(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      planId: data['planId'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? false,
      paymentMethod: data['paymentMethod'] ?? '',
      transactionId: data['transactionId'] ?? '',
      amountPaid: (data['amountPaid'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'planId': planId,
        'startDate': Timestamp.fromDate(startDate),
        'expiryDate': Timestamp.fromDate(expiryDate),
        'isActive': isActive,
        'paymentMethod': paymentMethod,
        'transactionId': transactionId,
        'amountPaid': amountPaid,
      };
}
