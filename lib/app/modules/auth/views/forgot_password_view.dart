import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/utils/responsive_layout.dart';
import '../../../shared/widgets/gold_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('forgot_password'.tr)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Obx(() => controller.otpSent.value
              ? _buildSuccessState(context, theme)
              : Form(
                  key: controller.forgotPasswordFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.lock_reset_rounded,
                          size: context.rSize(48),
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Reset Password',
                        style: theme.textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your email address and we\'ll send you a reset link.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                      ),
                      const SizedBox(height: 32),
                      CustomTextField(
                        controller: controller.emailController,
                        label: 'email'.tr,
                        hint: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: controller.validateEmail,
                      ),
                      const SizedBox(height: 32),
                      Obx(() => GoldButton(
                            label: 'send_otp'.tr,
                            isLoading: controller.isLoading.value,
                            onPressed: controller.sendPasswordReset,
                          )),
                    ],
                  ),
                )),
        ),
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.mark_email_read_rounded,
            size: context.rSize(80), color: AppColors.gold),
        const SizedBox(height: 24),
        Text(
          'Email Sent!',
          style: theme.textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Text(
          'Check your inbox and follow the link to reset your password.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 40),
        GoldButton(
          label: 'back'.tr,
          onPressed: () => Get.back(),
        ),
      ],
    );
  }
}
