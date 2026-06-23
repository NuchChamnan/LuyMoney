import 'dart:convert';

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
    final ext = theme.extension<AppColorExtension>()!;

    return Scaffold(
      backgroundColor: ext.background,
      body: CustomScrollView(
        slivers: [
          // ── Gradient App Bar ───────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: ext.background,
            flexibleSpace: FlexibleSpaceBar(
              background: _ProfileHeader(ext: ext),
            ),
            title: Text(
              'settings'.tr,
              style: TextStyle(
                color: ext.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            centerTitle: false,
          ),

          // ── Body ───────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ADMIN PANEL
                Obx(() {
                  final authService = Get.find<AuthService>();
                  if (!authService.isAdmin) return const SizedBox.shrink();
                  return Column(children: [
                    const SizedBox(height: 8),
                    _SectionLabel(label: 'Admin', ext: ext),
                    _SettingsCard(ext: ext, children: [
                      _Tile(
                        icon: Icons.admin_panel_settings_rounded,
                        iconColor: Colors.purple,
                        title: 'Admin Panel',
                        ext: ext,
                        onTap: () => Get.toNamed(Routes.ADMIN),
                      ),
                    ]),
                    const SizedBox(height: 16),
                  ]);
                }),

                // ACCOUNT
                _SectionLabel(label: 'account'.tr, ext: ext),
                _SettingsCard(ext: ext, children: [
                  _Tile(
                    icon: Icons.bookmark_outline_rounded,
                    iconColor: AppColors.gold,
                    title: 'saved_videos'.tr,
                    ext: ext,
                    onTap: () => Get.toNamed(Routes.SAVED_VIDEOS),
                  ),
                  _Divider(ext: ext),
                  _Tile(
                    icon: Icons.lock_outlined,
                    iconColor: Colors.blue,
                    title: 'change_password'.tr,
                    ext: ext,
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                  _Divider(ext: ext),
                  _Tile(
                    icon: Icons.delete_outline_rounded,
                    iconColor: AppColors.error,
                    title: 'delete_account'.tr,
                    titleColor: AppColors.error,
                    ext: ext,
                    onTap: () => _showDeleteAccountDialog(context),
                    showChevron: false,
                  ),
                ]),
                const SizedBox(height: 20),

                // APPEARANCE
                _SectionLabel(label: 'appearance'.tr, ext: ext),
                _SettingsCard(
                  ext: ext,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Theme picker
                    Row(children: [
                      _IconBox(icon: Icons.palette_outlined, color: Colors.orange),
                      const SizedBox(width: 12),
                      Text('theme'.tr,
                          style: TextStyle(
                            color: ext.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          )),
                    ]),
                    const SizedBox(height: 14),
                    _buildThemeSelector(ext),
                    const SizedBox(height: 20),

                    // Language picker
                    Row(children: [
                      _IconBox(icon: Icons.language_rounded, color: Colors.teal),
                      const SizedBox(width: 12),
                      Text('language'.tr,
                          style: TextStyle(
                            color: ext.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          )),
                    ]),
                    const SizedBox(height: 14),
                    _buildLanguageSelector(ext),
                  ],
                ),
                const SizedBox(height: 20),

                // NOTIFICATIONS
                _SectionLabel(label: 'notifications'.tr, ext: ext),
                _SettingsCard(ext: ext, children: [
                  Obx(() => _ToggleTile(
                        icon: Icons.notifications_outlined,
                        iconColor: Colors.amber,
                        title: 'subscription_reminders'.tr,
                        value: controller.subscriptionReminders.value,
                        onChanged: controller.toggleSubscriptionReminders,
                        ext: ext,
                      )),
                  _Divider(ext: ext),
                  Obx(() => _ToggleTile(
                        icon: Icons.new_releases_outlined,
                        iconColor: Colors.green,
                        title: 'new_content_alerts'.tr,
                        value: controller.newContentAlerts.value,
                        onChanged: controller.toggleNewContentAlerts,
                        ext: ext,
                      )),
                  _Divider(ext: ext),
                  Obx(() => _ToggleTile(
                        icon: Icons.campaign_outlined,
                        iconColor: Colors.pink,
                        title: 'promotional_messages'.tr,
                        value: controller.promotionalMessages.value,
                        onChanged: controller.togglePromotionalMessages,
                        ext: ext,
                      )),
                ]),
                const SizedBox(height: 20),

                // SUBSCRIPTION
                _SectionLabel(label: 'subscription'.tr, ext: ext),
                _SettingsCard(ext: ext, children: [
                  _Tile(
                    icon: Icons.star_outline_rounded,
                    iconColor: AppColors.gold,
                    title: 'manage_subscription'.tr,
                    ext: ext,
                    onTap: controller.navigateToSubscription,
                  ),
                ]),
                const SizedBox(height: 20),

                // SUPPORT
                _SectionLabel(label: 'support'.tr, ext: ext),
                _SettingsCard(ext: ext, children: [
                  _Tile(
                    icon: Icons.chat_bubble_outline_rounded,
                    iconColor: Colors.blue,
                    title: 'chat_support'.tr,
                    ext: ext,
                    onTap: controller.navigateToSupport,
                  ),
                  _Divider(ext: ext),
                  _Tile(
                    icon: Icons.telegram,
                    iconColor: const Color(0xFF0088CC),
                    title: 'telegram_community'.tr,
                    ext: ext,
                    onTap: controller.openTelegram,
                  ),
                  _Divider(ext: ext),
                  _Tile(
                    icon: Icons.help_outline_rounded,
                    iconColor: Colors.indigo,
                    title: 'faq'.tr,
                    ext: ext,
                    onTap: () => Get.toNamed(Routes.FAQ),
                  ),
                  _Divider(ext: ext),
                  _Tile(
                    icon: Icons.star_rate_rounded,
                    iconColor: Colors.orange,
                    title: 'rate_app'.tr,
                    ext: ext,
                    onTap: controller.rateApp,
                  ),
                ]),
                const SizedBox(height: 20),

                // LEGAL
                _SectionLabel(label: 'legal'.tr, ext: ext),
                _SettingsCard(ext: ext, children: [
                  _Tile(
                    icon: Icons.privacy_tip_outlined,
                    iconColor: Colors.purple,
                    title: 'privacy_policy'.tr,
                    ext: ext,
                    onTap: () => controller.openUrl(AppConfig.privacyPolicyUrl),
                  ),
                  _Divider(ext: ext),
                  _Tile(
                    icon: Icons.gavel_rounded,
                    iconColor: Colors.brown,
                    title: 'terms_of_service'.tr,
                    ext: ext,
                    onTap: () => Get.toNamed(Routes.TERMS),
                  ),
                  _Divider(ext: ext),
                  // App Version Row
                  Obx(() => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(children: [
                          _IconBox(
                              icon: Icons.info_outline_rounded,
                              color: Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('app_version'.tr,
                                style: TextStyle(
                                    color: ext.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: ext.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: ext.border),
                            ),
                            child: Text(
                              controller.appVersion.value,
                              style: TextStyle(
                                color: ext.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ]),
                      )),
                ]),
                const SizedBox(height: 28),

                // ── Logout Button ──────────────────────────────────────────
                GestureDetector(
                  onTap: controller.signOut,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE53935), Color(0xFFEF5350)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'logout'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Theme Selector ─────────────────────────────────────────────────────────
  Widget _buildThemeSelector(AppColorExtension ext) {
    final themeCtrl = Get.find<ThemeController>();
    const themeData = {
      AppTheme.white: (
        bg: Color(0xFFFFFFFF),
        primary: Color(0xFFD4AF37),
        text: Color(0xFF121212),
        label: 'White',
      ),
      AppTheme.black: (
        bg: Color(0xFF0A0A0A),
        primary: Color(0xFFD4AF37),
        text: Color(0xFFFFFFFF),
        label: 'Black',
      ),
      AppTheme.oldBlue: (
        bg: Color(0xFF0D1B2A),
        primary: Color(0xFFD4AF37),
        text: Color(0xFFE8F0FB),
        label: 'Navy',
      ),
    };

    return Obx(() => Row(
          children: AppTheme.values.map((t) {
            final d = themeData[t]!;
            final isSelected = themeCtrl.currentTheme.value == t;
            return Expanded(
              child: GestureDetector(
                onTap: () => themeCtrl.switchTheme(t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: d.bg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.gold : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? AppColors.gold.withValues(alpha: 0.4)
                            : Colors.black.withValues(alpha: 0.15),
                        blurRadius: isSelected ? 10 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: d.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: d.primary.withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        d.label,
                        style: TextStyle(
                          color: d.text,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: 4),
                        Icon(Icons.check_circle_rounded,
                            color: AppColors.gold, size: 14),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ));
  }

  // ── Language Selector ──────────────────────────────────────────────────────
  Widget _buildLanguageSelector(AppColorExtension ext) {
    final langCtrl = Get.find<LanguageController>();
    const langMeta = {
      'en': ('🇺🇸', 'English'),
      'km': ('🇰🇭', 'ភាសាខ្មែរ'),
      'zh': ('🇨🇳', '中文'),
    };

    return Obx(() => Row(
          children: langCtrl.supportedLocales.map((locale) {
            final isSelected = langCtrl.currentLocale.value.languageCode ==
                locale.languageCode;
            final (flag, name) =
                langMeta[locale.languageCode] ?? ('🌐', locale.displayName);
            return Expanded(
              child: GestureDetector(
                onTap: () => langCtrl.changeLanguage(
                    locale.languageCode, locale.countryCode),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.goldGradient : null,
                    color: isSelected ? null : ext.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.gold : ext.border,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.3),
                              blurRadius: 8,
                            )
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(flag, style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 6),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected ? Colors.black : ext.textPrimary,
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ));
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────
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
          TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteAccount();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('delete'.tr,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Profile Header (SliverAppBar background) ──────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final AppColorExtension ext;
  const _ProfileHeader({required this.ext});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ctrl = Get.find<SettingsController>();
      final user = Get.find<AuthService>().currentUser.value;
      final initial = user?.name.isNotEmpty == true
          ? user!.name[0].toUpperCase()
          : 'U';

      ImageProvider? avatarImage;
      if (user?.avatarBase64 != null && user!.avatarBase64!.isNotEmpty) {
        avatarImage = MemoryImage(base64Decode(user.avatarBase64!));
      } else if (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) {
        avatarImage = NetworkImage(user.avatarUrl!);
      }

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.gold.withValues(alpha: 0.15),
              AppColors.gold.withValues(alpha: 0.04),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
            child: GestureDetector(
              onTap: ctrl.navigateToProfile,
              child: Row(children: [
                // Avatar
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: avatarImage == null ? AppColors.goldGradient : null,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: avatarImage != null
                      ? CircleAvatar(
                          radius: 34,
                          backgroundImage: avatarImage,
                        )
                      : Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              fontSize: 26,
                            ),
                          ),
                        ),
                ),
                  const SizedBox(width: 16),
                  // Name & Email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user?.name ?? 'User',
                          style: TextStyle(
                            color: ext.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            color: ext.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Edit button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.edit_outlined,
                        color: AppColors.gold, size: 18),
                  ),
                ]),
              ),
            ),
          ),
        );
      });
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final AppColorExtension ext;
  const _SectionLabel({required this.label, required this.ext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
      child: Text(
        label.toUpperCase(),
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

// ── Settings Card ─────────────────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final AppColorExtension ext;
  final List<Widget> children;
  final EdgeInsets? padding;
  const _SettingsCard(
      {required this.ext, required this.children, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: ext.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: padding != null
          ? Padding(padding: padding!, child: Column(children: children))
          : Column(children: children),
    );
  }
}

// ── Tile ──────────────────────────────────────────────────────────────────────
class _Tile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final AppColorExtension ext;
  final VoidCallback onTap;
  final bool showChevron;

  const _Tile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.ext,
    required this.onTap,
    this.titleColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            _IconBox(icon: icon, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: titleColor ?? ext.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showChevron)
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: ext.textSecondary),
          ]),
        ),
      ),
    );
  }
}

// ── Toggle Tile ───────────────────────────────────────────────────────────────
class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final AppColorExtension ext;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.ext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(children: [
        _IconBox(icon: icon, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: ext.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.gold,
          activeTrackColor: AppColors.gold.withValues(alpha: 0.35),
        ),
      ]),
    );
  }
}

// ── Icon Box ──────────────────────────────────────────────────────────────────
class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBox({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

// ── Divider ───────────────────────────────────────────────────────────────────
class _Divider extends StatelessWidget {
  final AppColorExtension ext;
  const _Divider({required this.ext});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 64,
      endIndent: 0,
      color: ext.border.withValues(alpha: 0.6),
    );
  }
}
