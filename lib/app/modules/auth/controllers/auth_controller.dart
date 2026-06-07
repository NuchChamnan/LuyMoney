import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../../../services/auth_service.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final _storage = GetStorage();

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  // Form keys
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();
  final forgotPasswordFormKey = GlobalKey<FormState>();

  // State
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final rememberMe = false.obs;
  final otpSent = false.obs;

  @override
  void onInit() {
    super.onInit();
    final savedEmail = _storage.read<String>('remember_email');
    if (savedEmail != null) {
      emailController.text = savedEmail;
      rememberMe.value = true;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();

  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      await _authService.signInWithEmail(
        emailController.text.trim(),
        passwordController.text,
      );
      if (rememberMe.value) {
        _storage.write('remember_email', emailController.text.trim());
      } else {
        _storage.remove('remember_email');
      }
      // Wait for Firestore user data (max 5s), then check role
      int attempts = 0;
      while (_authService.currentUser.value == null && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
      }
      if (_authService.isAdmin) {
        Get.offAllNamed(Routes.ADMIN);
      } else {
        Get.offAllNamed(Routes.HOME);
      }
    } on FirebaseAuthException catch (e) {
      _showError(_getAuthErrorMessage(e.code));
    } catch (e) {
      _showError('something_went_wrong'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      await _authService.registerWithEmail(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      Get.offAllNamed(Routes.HOME);
    } on FirebaseAuthException catch (e) {
      _showError(_getAuthErrorMessage(e.code));
    } catch (e) {
      _showError('something_went_wrong'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendPasswordReset() async {
    if (!forgotPasswordFormKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      await _authService.sendPasswordResetEmail(emailController.text.trim());
      Get.snackbar(
        'Success',
        'Password reset email sent. Check your inbox.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      otpSent.value = true;
    } on FirebaseAuthException catch (e) {
      _showError(_getAuthErrorMessage(e.code));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }

  Future<void> authenticateWithBiometric() async {
    try {
      final canAuth = await _localAuth.canCheckBiometrics;
      if (!canAuth) return;
      final didAuth = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Luy Money',
        biometricOnly: true,
      );
      if (didAuth) {
        final savedEmail = _storage.read<String>('remember_email');
        final savedPassword = _storage.read<String>('saved_password');
        if (savedEmail != null && savedPassword != null) {
          emailController.text = savedEmail;
          passwordController.text = savedPassword;
          await login();
        }
      }
    } catch (e) {
      Get.log('Biometric auth error: $e');
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'invalid-email':
        return 'invalid_email'.tr;
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'network_error'.tr;
      default:
        return 'something_went_wrong'.tr;
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFF44336),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // Validators
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'field_required'.tr;
    if (!GetUtils.isEmail(value)) return 'invalid_email'.tr;
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'field_required'.tr;
    if (value.length < 8) return 'invalid_password'.tr;
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'field_required'.tr;
    if (value != passwordController.text) return 'passwords_dont_match'.tr;
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'field_required'.tr;
    if (value.length < 2) return 'Name must be at least 2 characters.';
    return null;
  }
}
