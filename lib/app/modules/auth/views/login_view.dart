import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../shared/constants/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langCtrl = Get.find<LanguageController>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top bar: Language switcher ──────────────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: Obx(() {
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
                        'or',
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
                  label: const Text('Biometric Login'),
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
                    langCtrl.changeLanguage(
                        lang['code']!, lang['country']!);
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
                        color: isSelected
                            ? AppColors.gold
                            : theme.dividerColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Flag emoji
                        Text(lang['flag']!,
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 16),
                        // Language name
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
                        // Check mark
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
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: AppColors.gold),
          ],
        ),
      ),
    );
  }
}
