import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/gold_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('register'.tr),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.registerFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'create_account'.tr,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'join_thousands_tagline'.tr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: controller.nameController,
                  label: 'name'.tr,
                  hint: 'your_full_name'.tr,
                  prefixIcon: const Icon(Icons.person_outlined),
                  validator: controller.validateName,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.emailController,
                  label: 'email'.tr,
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: controller.validateEmail,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.phoneController,
                  label: 'phone'.tr,
                  hint: '+855 XX XXX XXX',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.passwordController,
                  label: 'password'.tr,
                  hint: 'at_least_8_chars'.tr,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  validator: controller.validatePassword,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.confirmPasswordController,
                  label: 'confirm_password'.tr,
                  hint: 'repeat_password'.tr,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  validator: controller.validateConfirmPassword,
                ),
                const SizedBox(height: 40),
                Obx(() => GoldButton(
                      label: 'register'.tr,
                      isLoading: controller.isLoading.value,
                      onPressed: controller.register,
                    )),
                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('already_have_account'.tr,
                          style: theme.textTheme.bodyMedium),
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'login'.tr,
                          style: TextStyle(
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
}
