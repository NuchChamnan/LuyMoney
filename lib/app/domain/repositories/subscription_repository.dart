import '../../data/models/subscription_model.dart';

abstract class SubscriptionRepository {
  Future<SubscriptionModel?> getUserSubscription(String userId);
  Future<SubscriptionModel> createSubscription({
    required String userId,
    required String planId,
    required String paymentMethod,
    required String transactionId,
  });
  Future<SubscriptionModel> renewSubscription({
    required String subscriptionId,
    required String planId,
    required String paymentMethod,
    required String transactionId,
  });
  Future<void> cancelSubscription(String subscriptionId);
  Future<void> extendSubscription({
    required String subscriptionId,
    required int extraDays,
  });

  // Admin
  Future<List<SubscriptionModel>> getAllSubscriptions({
    int limit = 20,
    SubscriptionModel? lastItem,
  });

  Future<bool> validatePromoCode(String code, String planId);
  Future<double> applyPromoCode({
    required String code,
    required String planId,
    required double originalPrice,
  });
}
