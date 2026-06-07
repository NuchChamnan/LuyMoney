import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/auth_service.dart';
import '../../../shared/themes/app_themes.dart';
import '../../../shared/utils/responsive_layout.dart';
import '../../../shared/widgets/widgets.dart';
import '../controllers/settings_controller.dart';

class ProfileView extends GetView<SettingsController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return Scaffold(
      backgroundColor: ext.background,
      appBar: AppBar(
        backgroundColor: ext.surface,
        elevation: 0,
        title: Text('profile'.tr,
            style: TextStyle(color: ext.textPrimary, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ext.textPrimary),
          onPressed: Get.back,
        ),
      ),
      body: Obx(() {
        final user = auth.currentUser.value;
        final firebaseUser = auth.firebaseUser;
        // Use Firebase Auth as fallback so page never blocks on Firestore
        final displayName = user?.name ?? firebaseUser?.displayName ?? '';
        final email = user?.email ?? firebaseUser?.email ?? '';
        final avatarBase64 = user?.avatarBase64;
        final avatarUrl = user?.avatarUrl ?? '';
        final isAdmin = user?.isAdmin ?? false;

        ImageProvider? avatarImage;
        if (avatarBase64 != null && avatarBase64.isNotEmpty) {
          avatarImage = MemoryImage(base64Decode(avatarBase64));
        } else if (avatarUrl.isNotEmpty) {
          avatarImage = NetworkImage(avatarUrl);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: controller.profileFormKey,
            child: Column(
              children: [
                // Avatar
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: context.rSize(52),
                        backgroundColor: ext.primary.withValues(alpha: 0.2),
                        backgroundImage: avatarImage,
                        child: avatarImage == null
                            ? Text(
                                displayName.isNotEmpty
                                    ? displayName[0].toUpperCase()
                                    : 'U',
                                style: TextStyle(
                                  fontSize: context.rFont(38),
                                  fontWeight: FontWeight.w700,
                                  color: ext.primary,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _pickAvatar(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [ext.primary, ext.secondary],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt,
                                size: 16, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  isAdmin ? '👑 Admin' : '✨ Member',
                  style: TextStyle(color: ext.primary, fontSize: 13),
                ),

                const SizedBox(height: 28),

                // Name field
                CustomTextField(
                  label: 'name'.tr,
                  controller: controller.nameController,
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (v) => v == null || v.isEmpty ? 'name_required'.tr : null,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                // Email (read only)
                CustomTextField(
                  label: 'email'.tr,
                  controller: TextEditingController(text: email),
                  prefixIcon: const Icon(Icons.email_outlined),
                  readOnly: true,
                ),

                const SizedBox(height: 16),

                // Phone
                CustomTextField(
                  label: 'phone'.tr,
                  controller: controller.phoneController,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                ),

                const SizedBox(height: 28),

                Obx(() => GoldButton(
                      label: 'save_changes'.tr,
                      onPressed: controller.updateProfile,
                      isLoading: controller.isLoading.value,
                    )),

                const SizedBox(height: 16),

                GoldButton(
                  label: 'change_password'.tr,
                  isOutlined: true,
                  onPressed: () => _showChangePasswordDialog(context, ext),
                ),

                const SizedBox(height: 16),

                // Delete account
                TextButton(
                  onPressed: () => _showDeleteDialog(context),
                  child: Text(
                    'delete_account'.tr,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> _pickAvatar(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (image != null) {
      await controller.uploadAvatar(image.path);
    }
  }

  void _showChangePasswordDialog(BuildContext context, AppColorExtension ext) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: ext.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('change_password'.tr,
            style: TextStyle(color: ext.textPrimary, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              label: 'current_password'.tr,
              controller: controller.currentPasswordController,
              isPassword: true,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'new_password'.tr,
              controller: controller.newPasswordController,
              isPassword: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('cancel'.tr, style: TextStyle(color: ext.textSecondary)),
          ),
          Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () async {
                        await controller.changePassword();
                        Get.back();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ext.primary,
                  foregroundColor: Colors.black,
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text('update'.tr),
              )),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('delete_account'.tr),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }
}
