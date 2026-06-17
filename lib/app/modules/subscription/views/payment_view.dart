import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/gold_button.dart';
import '../controllers/subscription_controller.dart';

class PaymentView extends GetView<SubscriptionController> {
  const PaymentView({super.key});

  // ═══════════════════════════════════════════
  // ABA Merchant Info — ប្តូរតាម Account ពិត
  // ═══════════════════════════════════════════
  static const String _abaAccountNumber = '000 712 828';
  static const String _abaAccountName = 'CHAMNAN NOCH';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('payment_method'.tr),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Order Summary ──
                    _OrderSummaryCard(theme: theme, controller: controller),
                    const SizedBox(height: 24),

                    // ── ABA Pay Header ──
                    _AbaBadge(theme: theme),
                    const SizedBox(height: 20),

                    // ── QR Code Box ──
                    _QrCodeSection(theme: theme, controller: controller),
                    const SizedBox(height: 20),

                    // ── Account Info ──
                    _AccountInfoCard(
                      theme: theme,
                      accountNumber: _abaAccountNumber,
                      accountName: _abaAccountName,
                      controller: controller,
                    ),
                    const SizedBox(height: 20),

                    // ── Steps ──
                    _PaymentSteps(theme: theme),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── Pay Button ──
            _PayButton(controller: controller),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Order Summary Card
// ─────────────────────────────────────────────
class _OrderSummaryCard extends StatelessWidget {
  final ThemeData theme;
  final SubscriptionController controller;
  const _OrderSummaryCard({required this.theme, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final plan = controller.selectedPlan.value;
      if (plan == null) return const SizedBox.shrink();
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.07),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.35),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'order_summary'.tr,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 14),
            _SummaryRow(
              theme: theme,
              label: controller.getPlanName(plan.plan),
              value: '\$${plan.price.toStringAsFixed(2)}',
              bold: false,
            ),
            const SizedBox(height: 6),
            _SummaryRow(
              theme: theme,
              label: 'duration'.tr,
              value: 'days_count'.trParams({'count': '${plan.durationDays}'}),
              bold: false,
              dimmed: true,
            ),
            Divider(height: 24, color: AppColors.gold.withValues(alpha: 0.25)),
            _SummaryRow(
              theme: theme,
              label: 'total'.tr,
              value: '\$${plan.price.toStringAsFixed(2)}',
              bold: true,
              valueColor: AppColors.gold,
            ),
          ],
        ),
      );
    });
  }
}

class _SummaryRow extends StatelessWidget {
  final ThemeData theme;
  final String label;
  final String value;
  final bool bold;
  final bool dimmed;
  final Color? valueColor;
  const _SummaryRow({
    required this.theme,
    required this.label,
    required this.value,
    required this.bold,
    this.dimmed = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = bold
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)
        : theme.textTheme.bodyMedium?.copyWith(
            color: dimmed
                ? theme.colorScheme.onSurface.withValues(alpha: 0.55)
                : null,
          );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textStyle),
        Text(
          value,
          style: textStyle?.copyWith(
            color: valueColor,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// ABA Pay Badge / Header
// ─────────────────────────────────────────────
class _AbaBadge extends StatelessWidget {
  final ThemeData theme;
  const _AbaBadge({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF003087), Color(0xFF0050A0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF003087).withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'ABA Pay',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.12),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'KHQR',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// QR Code Section
// ─────────────────────────────────────────────
class _QrCodeSection extends StatelessWidget {
  final ThemeData theme;
  final SubscriptionController controller;
  const _QrCodeSection({required this.theme, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF003087).withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF003087).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Real KHQR image from ABA Bank
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/aba_qr.png',
                width: 260,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Amount badge
          Obx(() {
            final plan = controller.selectedPlan.value;
            if (plan == null) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.4),
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${'amount'.tr}: ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    '\$${plan.price.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

}

// ─────────────────────────────────────────────
// Account Info Card (copy-able)
// ─────────────────────────────────────────────
class _AccountInfoCard extends StatelessWidget {
  final ThemeData theme;
  final String accountNumber;
  final String accountName;
  final SubscriptionController controller;
  const _AccountInfoCard({
    required this.theme,
    required this.accountNumber,
    required this.accountName,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF003087).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: Color(0xFF003087),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'aba_bank_account'.tr,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF003087),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _CopyableRow(
            theme: theme,
            label: 'account_number'.tr,
            value: accountNumber,
            icon: Icons.tag_rounded,
          ),
          const SizedBox(height: 10),
          _CopyableRow(
            theme: theme,
            label: 'account_name'.tr,
            value: accountName,
            icon: Icons.person_rounded,
            copyable: false,
          ),
          const SizedBox(height: 10),
          Obx(() {
            final plan = controller.selectedPlan.value;
            if (plan == null) return const SizedBox.shrink();
            return _CopyableRow(
              theme: theme,
              label: 'amount'.tr,
              value: '\$${plan.price.toStringAsFixed(2)}',
              icon: Icons.attach_money_rounded,
              valueColor: AppColors.gold,
            );
          }),
        ],
      ),
    );
  }
}

class _CopyableRow extends StatelessWidget {
  final ThemeData theme;
  final String label;
  final String value;
  final IconData icon;
  final bool copyable;
  final Color? valueColor;

  const _CopyableRow({
    required this.theme,
    required this.label,
    required this.value,
    required this.icon,
    this.copyable = true,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
        if (copyable)
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              Get.snackbar(
                '',
                'copied_value'.trParams({'value': value}),
                snackPosition: SnackPosition.TOP,
                duration: const Duration(seconds: 2),
                backgroundColor: AppColors.gold.withValues(alpha: 0.9),
                colorText: Colors.black,
                margin: const EdgeInsets.all(12),
                borderRadius: 12,
                icon: const Icon(
                  Icons.copy_rounded,
                  color: Colors.black,
                  size: 18,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.copy_rounded, size: 13, color: AppColors.gold),
                  const SizedBox(width: 4),
                  Text(
                    'copy'.tr,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Payment Steps
// ─────────────────────────────────────────────
class _PaymentSteps extends StatelessWidget {
  final ThemeData theme;
  const _PaymentSteps({required this.theme});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (Icons.phone_android_rounded, 'payment_step_1'.tr),
      (Icons.qr_code_scanner_rounded, 'payment_step_2'.tr),
      (Icons.check_circle_outline_rounded, 'payment_step_3'.tr),
      (Icons.touch_app_rounded, 'payment_step_4'.tr),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: AppColors.gold.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Text(
                'how_to_pay'.tr,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...steps.asMap().entries.map((e) {
            final idx = e.key;
            final step = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${idx + 1}',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    step.$1,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step.$2,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.75,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Pay Button
// ─────────────────────────────────────────────
class _PayButton extends StatelessWidget {
  final SubscriptionController controller;
  const _PayButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Obx(
        () => GoldButton(
          label: controller.isLoading.value
              ? 'processing'.tr
              : '✓  ${'ive_completed_payment'.tr}',
          isLoading: controller.isLoading.value,
          onPressed: controller.processPayment,
          icon: controller.isLoading.value ? null : Icons.verified_rounded,
        ),
      ),
    );
  }
}
