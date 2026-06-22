import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/notification_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/themes/app_themes.dart';
import '../../../shared/widgets/comment_widgets.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return Scaffold(
      backgroundColor: ext.background,
      appBar: AppBar(
        title: Text('notifications'.tr),
        backgroundColor: ext.surface,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: AppColors.gold,
        onRefresh: () => controller.loadNotifications(),
        child: Obx(() {
          if (controller.isLoading.value && controller.notifications.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.gold));
          }
          if (controller.notifications.isEmpty) {
            return ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                Icon(Icons.notifications_off_outlined,
                    size: 56, color: ext.textSecondary),
                const SizedBox(height: 16),
                Center(
                  child: Text('no_notifications_yet'.tr,
                      style: TextStyle(color: ext.textSecondary, fontSize: 14)),
                ),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.notifications.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final n = controller.notifications[i];
              return _NotificationTile(
                notification: n,
                ext: ext,
                onTap: () => controller.markAsRead(n.id),
              );
            },
          );
        }),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotificationModel notification;
  final AppColorExtension ext;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.ext,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ext.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notification.isRead ? ext.border : AppColors.gold,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: notification.isRead
                    ? null
                    : AppColors.goldGradient,
                color: notification.isRead
                    ? ext.background
                    : null,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_rounded,
                size: 18,
                color: notification.isRead ? ext.textSecondary : Colors.black,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            color: ext.textPrimary,
                            fontWeight: notification.isRead
                                ? FontWeight.w600
                                : FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: const BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: TextStyle(color: ext.textSecondary, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatRelativeTime(notification.sentAt),
                    style: TextStyle(color: ext.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
