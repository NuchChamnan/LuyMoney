import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/themes/app_themes.dart';
import '../controllers/admin_controller.dart';
import 'admin_users_view.dart';
import 'admin_content_view.dart';
import 'admin_analytics_view.dart';
import 'admin_notifications_view.dart';
import 'admin_chats_view.dart';
import 'admin_banners_view.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  static const _navItems = [
    {'icon': Icons.people_outline,          'label': 'Users'},
    {'icon': Icons.library_books_outlined,  'label': 'Content'},
    {'icon': Icons.bar_chart,               'label': 'Analytics'},
    {'icon': Icons.notifications_outlined,  'label': 'Notify'},
    {'icon': Icons.support_agent_outlined,  'label': 'Support'},
    {'icon': Icons.view_carousel_outlined,  'label': 'Banners'},
  ];

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return Scaffold(
      backgroundColor: ext.background,

      // ── AppBar with hamburger ─────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: ext.surface,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu, color: ext.textPrimary),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
            tooltip: 'Menu',
          ),
        ),
        title: Obx(() {
          final label = _navItems[controller.currentTab.value]['label'] as String;
          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [ext.primary, ext.secondary]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.admin_panel_settings,
                    color: Colors.black, size: 18),
              ),
              const SizedBox(width: 10),
              Text(label,
                  style: TextStyle(
                      color: ext.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700)),
            ],
          );
        }),
        actions: [
          IconButton(
            icon: Icon(Icons.home_outlined, color: ext.textSecondary),
            onPressed: () => Get.offAllNamed('/home'),
            tooltip: 'Back to App',
          ),
        ],
      ),

      // ── Drawer ────────────────────────────────────────────────────────────
      drawer: Drawer(
        backgroundColor: ext.surface,
        child: SafeArea(
          child: Column(
            children: [
              // Drawer header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ext.primary, ext.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.admin_panel_settings,
                          color: Colors.black, size: 28),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Admin Panel',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    ),
                    const Text(
                      'LuyMoney Management',
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Nav items
              Expanded(
                child: Obx(() => ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      children: _navItems.asMap().entries.map((e) {
                        final index = e.key;
                        final icon = e.value['icon'] as IconData;
                        final label = e.value['label'] as String;
                        final isSelected =
                            controller.currentTab.value == index;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            tileColor: isSelected
                                ? ext.primary.withValues(alpha: 0.15)
                                : Colors.transparent,
                            leading: Icon(
                              icon,
                              color: isSelected
                                  ? ext.primary
                                  : ext.textSecondary,
                              size: 22,
                            ),
                            title: Text(
                              label,
                              style: TextStyle(
                                color: isSelected
                                    ? ext.primary
                                    : ext.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                                fontSize: 15,
                              ),
                            ),
                            // Unread badge for Support tab
                            trailing: index == 4
                                ? Obx(() {
                                    final total = controller.adminChats.fold<int>(
                                        0,
                                        (sum, c) =>
                                            sum +
                                            ((c['unreadByAdmin'] as int?) ??
                                                0));
                                    if (total == 0) return const SizedBox();
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.gold,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Text('$total',
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700)),
                                    );
                                  })
                                : null,
                            onTap: () {
                              controller.currentTab.value = index;
                              Navigator.of(context).pop(); // close drawer
                            },
                          ),
                        );
                      }).toList(),
                    )),
              ),

              const Divider(height: 1),

              // Back to App button
              ListTile(
                leading: Icon(Icons.exit_to_app, color: ext.textSecondary),
                title: Text('Back to App',
                    style: TextStyle(color: ext.textPrimary)),
                onTap: () => Get.offAllNamed('/home'),
              ),
            ],
          ),
        ),
      ),

      // ── Body ──────────────────────────────────────────────────────────────
      body: Obx(() => IndexedStack(
            index: controller.currentTab.value,
            children: const [
              AdminUsersView(),
              AdminContentView(),
              AdminAnalyticsView(),
              AdminNotificationsView(),
              AdminChatsView(),
              AdminBannersView(),
            ],
          )),
    );
  }
}
