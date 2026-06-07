import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/auth_service.dart';
import '../../../shared/utils/app_utils.dart';
import '../../../routes/app_routes.dart';

class SettingsController extends GetxController {
  final _storage = GetStorage();
  final _auth = Get.find<AuthService>();

  final profileFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final isLoading = false.obs;

  final subscriptionReminders = true.obs;
  final newContentAlerts = true.obs;
  final promotionalMessages = false.obs;
  final appVersion = '1.0.0'.obs;

  @override
  void onInit() {
    super.onInit();
    subscriptionReminders.value = _storage.read<bool>('notif_subscription') ?? true;
    newContentAlerts.value = _storage.read<bool>('notif_content') ?? true;
    promotionalMessages.value = _storage.read<bool>('notif_promo') ?? false;
    PackageInfo.fromPlatform().then((info) {
      appVersion.value = '${info.version}+${info.buildNumber}';
    });
    final user = _auth.currentUser.value;
    final firebaseUser = _auth.firebaseUser;
    if (user != null) {
      nameController.text = user.name;
      phoneController.text = user.phone ?? '';
    } else if (firebaseUser != null) {
      nameController.text = firebaseUser.displayName ?? '';
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    super.onClose();
  }

  void toggleSubscriptionReminders(bool value) {
    subscriptionReminders.value = value;
    _storage.write('notif_subscription', value);
  }

  void toggleNewContentAlerts(bool value) {
    newContentAlerts.value = value;
    _storage.write('notif_content', value);
  }

  void togglePromotionalMessages(bool value) {
    promotionalMessages.value = value;
    _storage.write('notif_promo', value);
  }

  Future<void> updateProfile() async {
    if (!profileFormKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      await _auth.updateUserProfile(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
      );
      AppSnackbar.success('profile_updated'.tr);
    } catch (e) {
      AppSnackbar.error('$e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> uploadAvatar(String filePath) async {
    isLoading.value = true;
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        AppSnackbar.error('Image file not found');
        return;
      }
      final bytes = await file.readAsBytes();
      // Reject if image is too large (>500KB raw)
      if (bytes.lengthInBytes > 500 * 1024) {
        AppSnackbar.error('Image too large. Please choose a smaller image.');
        return;
      }
      final base64String = base64Encode(bytes);
      await _auth.updateUserProfile(avatarBase64: base64String);
      AppSnackbar.success('Avatar updated');
    } catch (e) {
      AppSnackbar.error('Failed to update avatar: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword() async {
    if (currentPasswordController.text.isEmpty || newPasswordController.text.isEmpty) {
      AppSnackbar.error('fill_all_fields'.tr);
      return;
    }
    isLoading.value = true;
    try {
      final user = _auth.firebaseUser;
      if (user == null || user.email == null) return;
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPasswordController.text,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPasswordController.text);
      AppSnackbar.success('password_changed'.tr);
      currentPasswordController.clear();
      newPasswordController.clear();
    } catch (e) {
      AppSnackbar.error('$e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    isLoading.value = true;
    try {
      final user = _auth.firebaseUser;
      if (user == null) return;
      // Delete Firestore data
      await _auth.deleteUserData(user.uid);
      // Delete Firebase Auth account
      await user.delete();
      Get.offAllNamed(Routes.LOGIN);
      AppSnackbar.success('account_deleted'.tr);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        AppSnackbar.error('Please log out and log in again before deleting your account.');
      } else {
        AppSnackbar.error('$e');
      }
    } catch (e) {
      AppSnackbar.error('$e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rateApp() async {
    final review = InAppReview.instance;
    if (await review.isAvailable()) {
      review.requestReview();
    } else {
      review.openStoreListing();
    }
  }

  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void navigateToProfile() => Get.toNamed(Routes.PROFILE);
  void navigateToSubscription() => Get.toNamed(Routes.SUBSCRIPTION);
  void navigateToSupport() => Get.toNamed(Routes.SUPPORT);

  Future<void> openTelegram() => openUrl('https://t.me/LuyMoneySupport');

  Future<void> signOut() async {
    Get.dialog(AlertDialog(
      title: Text('logout'.tr),
      content: Text('logout_confirm'.tr),
      actions: [
        TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
        ElevatedButton(
          onPressed: () async {
            Get.back();
            await _auth.signOut();
            Get.offAllNamed(Routes.LOGIN);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text('logout'.tr),
        ),
      ],
    ));
  }
}
