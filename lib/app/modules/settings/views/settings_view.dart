import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/themes/app_themes.dart';
import '../controllers/language_controller.dart';
import '../controllers/settings_controller.dart';
import '../../../../app_config.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ACCOUNT
          _SectionHeader(title: 'account'.tr),
          _buildProfileTile(theme),
          _SettingsTile(
            icon: Icons.lock_outlined,
            title: 'change_password'.tr,
            onTap: () => _showChangePasswordDialog(context),
          ),
          _SettingsTile(
            icon: Icons.delete_outline_rounded,
            title: 'delete_account'.tr,
            textColor: AppColors.error,
            onTap: () => _showDeleteAccountDialog(context),
          ),
          const SizedBox(height: 24),

          // ADMIN PANEL (visible only for admins)
          Obx(() {
            final authService = Get.find<AuthService>();
            if (!authService.isAdmin) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(title: 'Admin'),
                _SettingsTile(
                  icon: Icons.admin_panel_settings_rounded,
                  title: 'Admin Panel',
                  onTap: () => Get.toNamed(Routes.ADMIN),
                ),
                const SizedBox(height: 24),
              ],
            );
          }),

          // APPEARANCE
          _SectionHeader(title: 'appearance'.tr),
          _buildThemeSelector(theme),
          const SizedBox(height: 16),
          _buildLanguageSelector(theme),
          const SizedBox(height: 24),

          // NOTIFICATIONS
          _SectionHeader(title: 'notifications'.tr),
          Obx(() => _SettingsToggle(
                icon: Icons.notifications_outlined,
                title: 'subscription_reminders'.tr,
                value: controller.subscriptionReminders.value,
                onChanged: controller.toggleSubscriptionReminders,
              )),
          Obx(() => _SettingsToggle(
                icon: Icons.new_releases_outlined,
                title: 'new_content_alerts'.tr,
                value: controller.newContentAlerts.value,
                onChanged: controller.toggleNewContentAlerts,
              )),
          Obx(() => _SettingsToggle(
                icon: Icons.campaign_outlined,
                title: 'promotional_messages'.tr,
                value: controller.promotionalMessages.value,
                onChanged: controller.togglePromotionalMessages,
              )),
          const SizedBox(height: 24),

          // SUBSCRIPTION
          _SectionHeader(title: 'subscription'.tr),
          _SettingsTile(
            icon: Icons.star_outline_rounded,
            title: 'manage_subscription'.tr,
            onTap: controller.navigateToSubscription,
          ),
          _SettingsTile(
            icon: Icons.restore_rounded,
            title: 'restore_purchase'.tr,
            onTap: () {},
          ),
          const SizedBox(height: 24),

          // SUPPORT
          _SectionHeader(title: 'support'.tr),
          _SettingsTile(
            icon: Icons.chat_outlined,
            title: 'chat_support'.tr,
            onTap: controller.navigateToSupport,
          ),
          _SettingsTile(
            icon: Icons.telegram,
            title: 'telegram_community'.tr,
            onTap: controller.openTelegram,
          ),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            title: 'faq'.tr,
            onTap: () => controller.openUrl(AppConfig.faqUrl),
          ),
          _SettingsTile(
            icon: Icons.star_rate_rounded,
            title: 'rate_app'.tr,
            onTap: controller.rateApp,
          ),
          const SizedBox(height: 24),

          // LEGAL
          _SectionHeader(title: 'legal'.tr),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'privacy_policy'.tr,
            onTap: () => controller.openUrl(AppConfig.privacyPolicyUrl),
          ),
          _SettingsTile(
            icon: Icons.gavel_rounded,
            title: 'terms_of_service'.tr,
            onTap: () => controller.openUrl(AppConfig.termsOfServiceUrl),
          ),
          Obx(() => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Icon(Icons.info_outline_rounded,
                          size: 20, color: AppColors.gold),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text('app_version'.tr,
                          style: Theme.of(Get.context!).textTheme.bodyMedium),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text(controller.appVersion.value,
                          style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                                color: Theme.of(Get.context!)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.5),
                              )),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 24),

          // Logout
          ElevatedButton.icon(
            onPressed: controller.signOut,
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            label: Text('logout'.tr,
                style: const TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('change_password'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'current_password'.tr,
                prefixIcon: const Icon(Icons.lock_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'new_password'.tr,
                prefixIcon: const Icon(Icons.lock_reset_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('cancel'.tr),
          ),
          Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () async {
                        await controller.changePassword();
                        if (!controller.isLoading.value) Get.back();
                      },
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('save'.tr),
              )),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('delete_account'.tr,
            style: const TextStyle(color: AppColors.error)),
        content: Text('delete_account_confirm'.tr),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteAccount();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: Text('delete'.tr,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTile(ThemeData theme) {
    return GetBuilder<SettingsController>(
      builder: (ctrl) {
        final user = Get.find<AuthService>().currentUser.value;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.gold,
            child: Text(
              user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 20),
            ),
          ),
          title: Text(user?.name ?? 'User',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          subtitle: Text(user?.email ?? '',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5))),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: controller.navigateToProfile,
        );
      },
    );
  }

  Widget _buildThemeSelector(ThemeData theme) {
    final themeCtrl = Get.find<ThemeController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette_outlined,
                  size: 20, color: AppColors.gold),
              const SizedBox(width: 16),
              Text('theme'.tr,
                  style:
                      theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => Row(
                children: AppTheme.values.map((t) {
                  final isSelected = themeCtrl.currentTheme.value == t;
                  final colors = {
                    AppTheme.white: (const Color(0xFFFFFFFF),
                        const Color(0xFFD4AF37), const Color(0xFF121212)),
                    AppTheme.black: (const Color(0xFF0A0A0A),
                        const Color(0xFFD4AF37), const Color(0xFFFFFFFF)),
                    AppTheme.oldBlue: (const Color(0xFF1B2A4A),
                        const Color(0xFFD4AF37), const Color(0xFFE8EAF6)),
                  };
                  final (bg, primary, text) = colors[t]!;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => themeCtrl.switchTheme(t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.gold
                                : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.gold.withOpacity(0.3),
                                    blurRadius: 8,
                                  )
                                ]
                              : [],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              t.name.capitalize!,
                              style: TextStyle(
                                color: text,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(ThemeData theme) {
    final langCtrl = Get.find<LanguageController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.language_rounded, size: 20, color: AppColors.gold),
              const SizedBox(width: 16),
              Text('language'.tr,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => Wrap(
                spacing: 8,
                children: langCtrl.supportedLocales.map((locale) {
                  final isSelected = langCtrl.currentLocale.value.languageCode ==
                      locale.languageCode;
                  return GestureDetector(
                    onTap: () => langCtrl.changeLanguage(
                        locale.languageCode, locale.countryCode),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.goldGradient : null,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.gold
                              : theme.dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        locale.displayName,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.black
                              : theme.colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }
}


class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppColors.gold,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Icon(icon, color: AppColors.gold, size: 22),
      title: Text(title,
          style: theme.textTheme.bodyMedium?.copyWith(color: textColor)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Icon(icon, color: AppColors.gold, size: 22),
      title: Text(title, style: theme.textTheme.bodyMedium),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.gold,
      ),
    );
  }
}
