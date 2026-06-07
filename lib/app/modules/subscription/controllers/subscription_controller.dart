import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/subscription_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/themes/app_themes.dart';

class SubscriptionController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  static const String _adminTelegramUrl = 'https://t.me/Noch_Chamnan';

  final selectedPlan = Rx<SubscriptionPlanInfo?>(null);
  final selectedPaymentMethod = PaymentMethod.abaPay.obs;
  final isLoading = false.obs;
  final currentSubscription = Rx<SubscriptionModel?>(null);
  final paymentConfirmed = false.obs;

  @override
  void onInit() {
    super.onInit();
    currentSubscription.value = _authService.currentUser.value?.subscription;
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

  // Called after user confirms they have paid via ABA QR
  Future<void> processPayment() async {
    final plan = selectedPlan.value;
    if (plan == null) return;
    _showTelegramInstructionSheet(plan);
  }

  // ── Telegram Instruction Sheet ─────────────────────────────────────────────
  void _showTelegramInstructionSheet(SubscriptionPlanInfo plan) {
    final ctx = Get.context!;
    final ext = Theme.of(ctx).extension<AppColorExtension>()!;
    final theme = Theme.of(ctx);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        decoration: BoxDecoration(
          color: ext.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ext.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                gradient: AppColors.goldGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.black, size: 34),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'ជំហានបន្ទាប់',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: ext.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Instruction card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan summary
                  Row(children: [
                    const Icon(Icons.receipt_long_outlined,
                        color: AppColors.gold, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${getPlanName(plan.plan)}  —  \$${plan.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),

                  // Steps
                  _Step(
                    number: '1',
                    text: 'ថតរូបភាពបង្ហាញការទូទាត់ (Screenshot) ពី ABA Mobile',
                    ext: ext,
                  ),
                  const SizedBox(height: 10),
                  _Step(
                    number: '2',
                    text: 'ផ្ញើ Screenshot ទៅ Admin Telegram ខាងក្រោម',
                    ext: ext,
                  ),
                  const SizedBox(height: 10),
                  _Step(
                    number: '3',
                    text: 'Admin នឹង Activate គណនីរបស់អ្នក ក្នុងពេលឆាប់ៗ',
                    ext: ext,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Telegram button
            GestureDetector(
              onTap: _openTelegram,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0088CC), Color(0xFF00AEFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0088CC).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.telegram, color: Colors.white, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'ទំនាក់ទំនង Admin Telegram',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Back to home
            TextButton(
              onPressed: () {
                Get.back(); // close sheet
                Get.offAllNamed(Routes.HOME);
              },
              child: Text(
                'ត្រឡប់ទៅទំព័រដើម',
                style: TextStyle(
                  color: ext.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
      isDismissible: false,
      isScrollControlled: true,
    );
  }

  Future<void> _openTelegram() async {
    final uri = Uri.parse(_adminTelegramUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      Get.snackbar(
        'Error',
        'Could not open Telegram. Please install Telegram first.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

// ── Step Widget ───────────────────────────────────────────────────────────────
class _Step extends StatelessWidget {
  final String number;
  final String text;
  final AppColorExtension ext;

  const _Step({
    required this.number,
    required this.text,
    required this.ext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            gradient: AppColors.goldGradient,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: ext.textPrimary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
