import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/themes/app_themes.dart';
import '../../../shared/utils/responsive_layout.dart';
import '../../../shared/widgets/gold_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../modules/settings/controllers/language_controller.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  // ── Language data ──────────────────────────────────────────────────────────
  static const _langs = [
    {'code': 'en', 'country': 'US', 'label': 'English',    'flag': '🇺🇸'},
    {'code': 'km', 'country': 'KH', 'label': 'ភាសាខ្មែរ', 'flag': '🇰🇭'},
    {'code': 'zh', 'country': 'CN', 'label': '中文',       'flag': '🇨🇳'},
  ];

  // ── Theme data ─────────────────────────────────────────────────────────────
  static const _themes = [
    _ThemeMeta(
      theme: AppTheme.black,
      label: 'Dark',
      labelKm: 'ងងឹត',
      labelZh: '深色',
      icon: '🌙',
      bg: Color(0xFF0A0A0A),
      surface: Color(0xFF1A1A1A),
      dot: Color(0xFFD4AF37),
      textColor: Color(0xFFFFFFFF),
    ),
    _ThemeMeta(
      theme: AppTheme.white,
      label: 'Light',
      labelKm: 'ភ្លឺ',
      labelZh: '浅色',
      icon: '☀️',
      bg: Color(0xFFFFFFFF),
      surface: Color(0xFFF5F5F5),
      dot: Color(0xFFD4AF37),
      textColor: Color(0xFF121212),
    ),
    _ThemeMeta(
      theme: AppTheme.oldBlue,
      label: 'Navy',
      labelKm: 'ខៀវវីរៈ',
      labelZh: '深海蓝',
      icon: '🌊',
      bg: Color(0xFF0D1B2A),
      surface: Color(0xFF132234),
      dot: Color(0xFFD4AF37),
      textColor: Color(0xFFE8F0FB),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langCtrl = Get.find<LanguageController>();
    final themeCtrl = Get.find<ThemeController>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top bar: Theme switcher (left) + Language switcher (right) ─
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Theme button (left)
                    Obx(() {
                      final cur = _themes.firstWhere(
                        (t) => t.theme == themeCtrl.currentTheme.value,
                        orElse: () => _themes.first,
                      );
                      final lang = langCtrl.currentLocale.value.languageCode;
                      final label = lang == 'km'
                          ? cur.labelKm
                          : lang == 'zh'
                              ? cur.labelZh
                              : cur.label;
                      return _ThemeButton(
                        meta: cur,
                        label: label,
                        onTap: () => _showThemeSheet(context, themeCtrl),
                      );
                    }),

                    // Language button (right)
                    Obx(() {
                      final cur = langCtrl.currentLocaleOption;
                      final flag = _langs.firstWhere(
                        (l) => l['code'] == cur.languageCode,
                        orElse: () => _langs.first,
                      )['flag']!;
                      return _LangButton(
                        flag: flag,
                        label: cur.displayName,
                        onTap: () => _showLangSheet(context, langCtrl),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Logo ───────────────────────────────────────────────────
                Center(
                  child: Container(
                    width: context.rSize(72),
                    height: context.rSize(72),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.goldGradient,
                    ),
                    child: Icon(
                      Icons.monetization_on_rounded,
                      color: Colors.black,
                      size: context.rSize(40),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Title ──────────────────────────────────────────────────
                Text(
                  'login'.tr,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'welcome_back_luy_money'.tr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 40),

                // ── Email ──────────────────────────────────────────────────
                CustomTextField(
                  controller: controller.emailController,
                  label: 'email'.tr,
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: controller.validateEmail,
                ),
                const SizedBox(height: 16),

                // ── Password ───────────────────────────────────────────────
                CustomTextField(
                  controller: controller.passwordController,
                  label: 'password'.tr,
                  hint: '••••••••',
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  validator: controller.validatePassword,
                ),
                const SizedBox(height: 12),

                // ── Remember me & Forgot password ──────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Row(
                          children: [
                            Checkbox(
                              value: controller.rememberMe.value,
                              onChanged: (v) =>
                                  controller.rememberMe.value = v ?? false,
                              activeColor: AppColors.gold,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Text('remember_me'.tr,
                                style: theme.textTheme.bodySmall),
                          ],
                        )),
                    TextButton(
                      onPressed: () => Get.toNamed(Routes.FORGOT_PASSWORD),
                      child: Text(
                        'forgot_password'.tr,
                        style: const TextStyle(color: AppColors.gold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ── Login button ───────────────────────────────────────────
                Obx(() => GoldButton(
                      label: 'login'.tr,
                      isLoading: controller.isLoading.value,
                      onPressed: controller.login,
                    )),
                const SizedBox(height: 16),

                // ── Divider ────────────────────────────────────────────────
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or'.tr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Biometric login ────────────────────────────────────────
                OutlinedButton.icon(
                  onPressed: controller.authenticateWithBiometric,
                  icon: const Icon(Icons.fingerprint),
                  label: Text('biometric_login'.tr),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Register link ──────────────────────────────────────────
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('dont_have_account'.tr,
                          style: theme.textTheme.bodyMedium),
                      TextButton(
                        onPressed: () => Get.toNamed(Routes.REGISTER),
                        child: Text(
                          'register'.tr,
                          style: const TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Theme Bottom Sheet ────────────────────────────────────────────────────
  void _showThemeSheet(BuildContext context, ThemeController themeCtrl) {
    final theme = Theme.of(context);
    final lang = Get.find<LanguageController>().currentLocale.value.languageCode;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (ctx, setState) => Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Row(children: [
                const Icon(Icons.palette_outlined,
                    color: AppColors.gold, size: 20),
                const SizedBox(width: 10),
                Text(
                  'select_theme'.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ]),
              const SizedBox(height: 20),

              // 3 Theme cards in a row
              Obx(() => Row(
                    children: _themes.map((meta) {
                      final isSelected =
                          themeCtrl.currentTheme.value == meta.theme;
                      final label = lang == 'km'
                          ? meta.labelKm
                          : lang == 'zh'
                              ? meta.labelZh
                              : meta.label;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            themeCtrl.switchTheme(meta.theme);
                            Get.back();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: meta.bg,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.gold
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? AppColors.gold.withValues(alpha: 0.35)
                                      : Colors.black.withValues(alpha: 0.2),
                                  blurRadius: isSelected ? 14 : 4,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Emoji icon
                                Text(meta.icon,
                                    style: const TextStyle(fontSize: 26)),
                                const SizedBox(height: 8),
                                // Gold dot
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: meta.dot,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: meta.dot
                                            .withValues(alpha: 0.5),
                                        blurRadius: 6,
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Label
                                Text(
                                  label,
                                  style: TextStyle(
                                    color: meta.textColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(height: 6),
                                  const Icon(Icons.check_circle_rounded,
                                      color: AppColors.gold, size: 16),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ── Language Bottom Sheet ─────────────────────────────────────────────────
  void _showLangSheet(BuildContext context, LanguageController langCtrl) {
    final theme = Theme.of(context);
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'select_language'.tr,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            // Language options
            ..._langs.map((lang) {
              return Obx(() {
                final isSelected =
                    langCtrl.currentLocale.value.languageCode == lang['code'];
                return GestureDetector(
                  onTap: () {
                    langCtrl.changeLanguage(lang['code']!, lang['country']!);
                    Get.back();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.gold.withValues(alpha: 0.1)
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.gold : theme.dividerColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(lang['flag']!,
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            lang['label']!,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isSelected ? AppColors.gold : null,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.gold, size: 22),
                      ],
                    ),
                  ),
                );
              });
            }),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

// ── Theme Metadata ────────────────────────────────────────────────────────────
class _ThemeMeta {
  final AppTheme theme;
  final String label;
  final String labelKm;
  final String labelZh;
  final String icon;
  final Color bg;
  final Color surface;
  final Color dot;
  final Color textColor;

  const _ThemeMeta({
    required this.theme,
    required this.label,
    required this.labelKm,
    required this.labelZh,
    required this.icon,
    required this.bg,
    required this.surface,
    required this.dot,
    required this.textColor,
  });
}

// ── Theme Button Widget ───────────────────────────────────────────────────────
class _ThemeButton extends StatelessWidget {
  final _ThemeMeta meta;
  final String label;
  final VoidCallback onTap;

  const _ThemeButton({required this.meta, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(meta.icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: AppColors.gold),
          ],
        ),
      ),
    );
  }
}

// ── Language Button Widget ────────────────────────────────────────────────────
class _LangButton extends StatelessWidget {
  final String flag;
  final String label;
  final VoidCallback onTap;

  const _LangButton({
    required this.flag,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: AppColors.gold),
          ],
        ),
      ),
    );
  }
}
