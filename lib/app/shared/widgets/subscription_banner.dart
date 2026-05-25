import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../themes/app_themes.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class SubscriptionBanner extends StatelessWidget {
  const SubscriptionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return Obx(() {
      final sub = auth.currentUser.value?.subscription;
      if (sub == null) return const SizedBox.shrink();
      if (sub.isExpired) return _buildBanner(context, ext, isExpired: true);
      if (sub.isExpiringSoon) return _buildBanner(context, ext, isExpired: false);
      return const SizedBox.shrink();
    });
  }

  Widget _buildBanner(BuildContext context, AppColorExtension ext,
      {required bool isExpired}) {
    final auth = Get.find<AuthService>();
    final sub = auth.currentUser.value?.subscription;
    final daysLeft = sub?.daysRemaining ?? 0;

    final bgColor = isExpired ? Colors.red.shade800 : Colors.amber.shade700;
    final icon = isExpired ? Icons.lock_outline : Icons.access_time_rounded;
    final message = isExpired
        ? 'subscription_expired'.tr
        : '${'expiry_in'.tr} $daysLeft ${'days'.tr}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: bgColor,
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.SUBSCRIPTION),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
              ),
              child: Text(
                'renew'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
