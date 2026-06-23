import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/notification_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/themes/app_themes.dart';
import '../../../shared/widgets/comment_widgets.dart';

class NotificationDetailView extends StatelessWidget {
  const NotificationDetailView({super.key});

  String _targetLabel(String target) {
    switch (target) {
      case 'active':
        return 'admin_target_active'.tr;
      case 'expiring':
        return 'admin_target_expiring'.tr;
      default:
        return 'admin_target_all_users'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notification = Get.arguments as AppNotificationModel;
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: ext.background,
      appBar: AppBar(
        title: Text('notifications'.tr),
        backgroundColor: ext.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    gradient: AppColors.goldGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_rounded,
                      size: 22, color: Colors.black),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatRelativeTime(notification.sentAt),
                        style: TextStyle(color: ext.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _targetLabel(notification.target),
                          style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 11,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              notification.title,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800, color: ext.textPrimary),
            ),
            const SizedBox(height: 14),
            Divider(color: ext.border, height: 1),
            const SizedBox(height: 14),
            Text(
              notification.body,
              style: TextStyle(
                  color: ext.textPrimary, fontSize: 15, height: 1.7),
            ),
          ],
        ),
      ),
    );
  }
}
