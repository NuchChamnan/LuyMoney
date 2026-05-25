import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/subscription_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../services/notification_service.dart';

class SubscriptionController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final selectedPlan = Rx<SubscriptionPlanInfo?>(null);
  final selectedPaymentMethod = PaymentMethod.abaPay.obs;
  final isLoading = false.obs;
  final currentSubscription = Rx<SubscriptionModel?>(null);
  final paymentConfirmed = false.obs;

  @override
  void onInit() {
    super.onInit();
    currentSubscription.value = _authService.currentUser.value?.subscription;
    // Pre-select popular plan
    selectedPlan.value = subscriptionPlans.firstWhere(
      (p) => p.badge == 'popular',
      orElse: () => subscriptionPlans.first,
    );
  }

  void selectPlan(SubscriptionPlanInfo plan) {
    selectedPlan.value = plan;
  }

  String getPlanName(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.monthly:
        return 'monthly'.tr;
      case SubscriptionPlan.quarterly:
        return 'quarterly'.tr;
      case SubscriptionPlan.biannual:
        return 'biannual'.tr;
      case SubscriptionPlan.annual:
        return 'annual'.tr;
    }
  }

  Future<void> proceedToPayment() async {
    if (selectedPlan.value == null) {
      Get.snackbar('Error', 'Please select a plan',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    Get.toNamed(Routes.PAYMENT);
  }

  Future<void> processPayment() async {
    final plan = selectedPlan.value;
    if (plan == null) return;
    isLoading.value = true;
    try {
      await _activateSubscription(plan);
      await _authService.refreshUser();
      _showSuccessSheet();
    } catch (e) {
      Get.snackbar('payment_failed'.tr, e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _activateSubscription(SubscriptionPlanInfo plan) async {
    final uid = _authService.currentUser.value?.id;
    if (uid == null) return;

    final now = DateTime.now();
    final expiryDate = now.add(Duration(days: plan.durationDays));

    final subData = {
      'userId': uid,
      'planId': plan.plan.name,
      'startDate': Timestamp.fromDate(now),
      'expiryDate': Timestamp.fromDate(expiryDate),
      'isActive': true,
      'paymentMethod': selectedPaymentMethod.value.name,
      'transactionId': 'TXN_${DateTime.now().millisecondsSinceEpoch}',
      'amountPaid': plan.price,
    };

    // Save to Firestore
    final ref = await _firestore
        .collection('users')
        .doc(uid)
        .collection('subscriptions')
        .add(subData);

    // Update user document
    await _firestore.collection('users').doc(uid).update({
      'subscription': {'id': ref.id, ...subData},
    });

    // Schedule notifications
    await _notificationService.scheduleExpiryReminders(expiryDate);

    currentSubscription.value = SubscriptionModel.fromMap({
      'id': ref.id,
      ...subData
    });
  }

  void _showSuccessSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 72),
            const SizedBox(height: 16),
            Text('payment_successful'.tr,
                style: Theme.of(Get.context!).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('payment_confirmation'.tr,
                textAlign: TextAlign.center,
                style: Theme.of(Get.context!).textTheme.bodyMedium),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Get.offAllNamed(Routes.HOME),
              child: Text('done'.tr),
            ),
          ],
        ),
      ),
      isDismissible: false,
    );
  }
}
