import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/gold_button.dart';
import '../../../data/models/subscription_model.dart';
import '../controllers/subscription_controller.dart';

class PaymentView extends GetView<SubscriptionController> {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('payment_method'.tr)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order summary
                    _buildOrderSummary(theme),
                    const SizedBox(height: 24),
                    Text('payment_method'.tr,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    // Payment methods
                    _PaymentMethodTile(
                      method: PaymentMethod.stripe,
                      label: 'credit_card'.tr,
                      icon: Icons.credit_card_rounded,
                      subtitle: 'Visa, Mastercard, AMEX',
                    ),
                    _PaymentMethodTile(
                      method: PaymentMethod.abaPay,
                      label: 'aba_pay'.tr,
                      icon: Icons.qr_code_scanner_rounded,
                      subtitle: 'ABA Mobile App QR',
                    ),
                    _PaymentMethodTile(
                      method: PaymentMethod.wingMoney,
                      label: 'wing_money'.tr,
                      icon: Icons.account_balance_wallet_rounded,
                      subtitle: 'Wing Money Transfer',
                    ),
                    _PaymentMethodTile(
                      method: PaymentMethod.paypal,
                      label: 'paypal'.tr,
                      icon: Icons.paypal_rounded,
                      subtitle: 'PayPal Account',
                    ),
                  ],
                ),
              ),
            ),
            // Pay button
            Container(
              padding: const EdgeInsets.all(20),
              child: Obx(() => GoldButton(
                    label:
                        '${'pay_now'.tr} — \$${controller.selectedPlan.value?.price.toStringAsFixed(0) ?? '0'}',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.processPayment,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(ThemeData theme) {
    return Obx(() {
      final plan = controller.selectedPlan.value;
      if (plan == null) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.gold.withOpacity(0.08),
          border: Border.all(color: AppColors.gold.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('order_summary'.tr,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700, color: AppColors.gold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(controller.getPlanName(plan.plan),
                    style: theme.textTheme.bodyMedium),
                Text('\$${plan.price.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Duration',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6))),
                Text('${plan.durationDays} days',
                    style: theme.textTheme.bodySmall),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('total'.tr,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text('\$${plan.price.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800, color: AppColors.gold)),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _PaymentMethodTile extends GetView<SubscriptionController> {
  final PaymentMethod method;
  final String label;
  final IconData icon;
  final String subtitle;

  const _PaymentMethodTile({
    required this.method,
    required this.label,
    required this.icon,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final isSelected = controller.selectedPaymentMethod.value == method;
      return GestureDetector(
        onTap: () => controller.selectPaymentMethod(method),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.gold : theme.dividerColor,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? AppColors.gold.withOpacity(0.05) : null,
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: isSelected
                      ? AppColors.gold
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                  size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.gold : null)),
                    Text(subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5))),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.gold, size: 20),
            ],
          ),
        ),
      );
    });
  }
}
