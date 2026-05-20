import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

// ── Validators ────────────────────────────────────────────────────────────────
class AppValidators {
  AppValidators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'email_required'.tr;
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'email_invalid'.tr;
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'password_required'.tr;
    if (value.length < 6) return 'password_too_short'.tr;
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'confirm_password_required'.tr;
    if (value != password) return 'passwords_do_not_match'.tr;
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.isEmpty) return 'name_required'.tr;
    if (value.trim().length < 2) return 'name_too_short'.tr;
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    final phoneRegex = RegExp(r'^\+?[\d\s\-]{8,15}$');
    if (!phoneRegex.hasMatch(value)) return 'phone_invalid'.tr;
    return null;
  }

  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName ${'is_required'.tr}'
          : 'field_required'.tr;
    }
    return null;
  }
}

// ── Date Helpers ──────────────────────────────────────────────────────────────
class DateHelper {
  DateHelper._();

  static String formatDate(DateTime date) =>
      DateFormat('MMM dd, yyyy').format(date);

  static String formatDateTime(DateTime date) =>
      DateFormat('MMM dd, yyyy HH:mm').format(date);

  static String formatShort(DateTime date) =>
      DateFormat('dd/MM/yyyy').format(date);

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  static String formatChatTime(DateTime date) {
    final now = DateTime.now();
    if (now.difference(date).inDays == 0) {
      return DateFormat('HH:mm').format(date);
    }
    return DateFormat('MMM dd HH:mm').format(date);
  }
}

// ── Currency Helpers ──────────────────────────────────────────────────────────
class CurrencyHelper {
  CurrencyHelper._();

  static String formatUsd(double amount) =>
      NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);

  static String formatKhr(double amount) =>
      NumberFormat.currency(symbol: '៛', decimalDigits: 0).format(amount);
}

// ── String Extensions ─────────────────────────────────────────────────────────
extension StringExt on String {
  String truncate(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength)}...';

  bool get isValidEmail =>
      RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
}

// ── Duration Formatter ────────────────────────────────────────────────────────
extension DurationExt on Duration {
  String get formatted {
    final h = inHours;
    final m = inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }
}

// ── Snackbar Helpers ──────────────────────────────────────────────────────────
class AppSnackbar {
  AppSnackbar._();

  static void success(String message) {
    Get.snackbar(
      'success'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1B5E20),
      colorText: const Color(0xFFFFFFFF),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  static void error(String message) {
    Get.snackbar(
      'error'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFB71C1C),
      colorText: const Color(0xFFFFFFFF),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  static void info(String message) {
    Get.snackbar(
      'info'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0D47A1),
      colorText: const Color(0xFFFFFFFF),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }
}

// ── Import for snackbar ───────────────────────────────────────────────────────
