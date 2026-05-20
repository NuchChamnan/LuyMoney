import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Gold - Brand primary across all themes
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldDark = Color(0xFFB8960C);
  static const Color goldLight = Color(0xFFF0C832);
  static const Color goldAccent = Color(0xFFE8C547);

  // White Theme
  static const Color whiteBackground = Color(0xFFFFFFFF);
  static const Color whiteSurface = Color(0xFFF5F5F5);
  static const Color whiteCardBorder = Color(0xFFE0E0E0);
  static const Color whiteTextPrimary = Color(0xFF121212);
  static const Color whiteTextSecondary = Color(0xFF555555);

  // Black Theme (Dark)
  static const Color blackBackground = Color(0xFF0A0A0A);
  static const Color blackSurface = Color(0xFF1A1A1A);
  static const Color blackCard = Color(0xFF1E1E1E);
  static const Color blackCardBorder = Color(0xFF2A2A2A);
  static const Color blackTextPrimary = Color(0xFFFFFFFF);
  static const Color blackTextSecondary = Color(0xFFAAAAAA);

  // Old Blue Theme (Vintage)
  static const Color blueBackground = Color(0xFF1B2A4A);
  static const Color blueSurface = Color(0xFF243560);
  static const Color blueCard = Color(0xFF1E3060);
  static const Color blueCardBorder = Color(0xFF2E4080);
  static const Color blueTextPrimary = Color(0xFFE8EAF6);
  static const Color blueTextSecondary = Color(0xFF9FA8DA);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Subscription status
  static const Color subscriptionActive = Color(0xFF4CAF50);
  static const Color subscriptionExpiring = Color(0xFFFFC107);
  static const Color subscriptionExpired = Color(0xFFF44336);

  // Gradient
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFF0C832), Color(0xFFB8960C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
