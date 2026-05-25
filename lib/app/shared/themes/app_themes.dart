import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

enum AppTheme { white, black, oldBlue }

class ThemeController extends GetxController {
  final _storage = GetStorage();
  final currentTheme = AppTheme.black.obs;

  @override
  void onInit() {
    super.onInit();
    final saved = _storage.read<String>('theme');
    if (saved != null) {
      try {
        switchTheme(AppTheme.values.byName(saved), persist: false);
      } catch (_) {}
    }
  }

  void switchTheme(AppTheme theme, {bool persist = true}) {
    currentTheme.value = theme;
    Get.changeTheme(AppThemes.getTheme(theme));
    _updateSystemUI(theme);
    if (persist) {
      _storage.write('theme', theme.name);
    }
  }

  void _updateSystemUI(AppTheme theme) {
    switch (theme) {
      case AppTheme.white:
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ));
        break;
      case AppTheme.black:
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ));
        break;
      case AppTheme.oldBlue:
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ));
        break;
    }
  }

  String get currentThemeName {
    switch (currentTheme.value) {
      case AppTheme.white:
        return 'White';
      case AppTheme.black:
        return 'Black';
      case AppTheme.oldBlue:
        return 'Old Blue';
    }
  }
}

class AppThemes {
  AppThemes._();

  static ThemeData getTheme(AppTheme theme) {
    switch (theme) {
      case AppTheme.white:
        return _whiteTheme;
      case AppTheme.black:
        return _blackTheme;
      case AppTheme.oldBlue:
        return _oldBlueTheme;
    }
  }

  static ThemeData get _whiteTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.gold,
          secondary: AppColors.goldDark,
          surface: AppColors.whiteSurface,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.whiteTextPrimary,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.whiteBackground,
        cardColor: AppColors.whiteBackground,
        dividerColor: AppColors.whiteCardBorder,
        textTheme: _buildTextTheme(AppColors.whiteTextPrimary),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.whiteBackground,
          foregroundColor: AppColors.whiteTextPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.whiteSurface,
          selectedItemColor: AppColors.gold,
          unselectedItemColor: AppColors.whiteTextSecondary,
        ),
        inputDecorationTheme: _buildInputTheme(AppColors.whiteTextSecondary, AppColors.whiteCardBorder),
        elevatedButtonTheme: _buildButtonTheme(),
        extensions: [
          AppColorExtension(
            background: AppColors.whiteBackground,
            surface: AppColors.whiteSurface,
            card: AppColors.whiteSurface,
            cardBorder: AppColors.whiteCardBorder,
            border: AppColors.whiteCardBorder,
            primary: AppColors.gold,
            secondary: AppColors.goldDark,
            textPrimary: AppColors.whiteTextPrimary,
            textSecondary: AppColors.whiteTextSecondary,
          ),
        ],
      );

  static ThemeData get _blackTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.gold,
          secondary: AppColors.goldLight,
          surface: AppColors.blackSurface,
          onPrimary: AppColors.blackBackground,
          onSecondary: AppColors.blackBackground,
          onSurface: AppColors.blackTextPrimary,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.blackBackground,
        cardColor: AppColors.blackCard,
        dividerColor: AppColors.blackCardBorder,
        textTheme: _buildTextTheme(AppColors.blackTextPrimary),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.blackBackground,
          foregroundColor: AppColors.blackTextPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.blackSurface,
          selectedItemColor: AppColors.gold,
          unselectedItemColor: AppColors.blackTextSecondary,
        ),
        inputDecorationTheme: _buildInputTheme(AppColors.blackTextSecondary, AppColors.blackCardBorder),
        elevatedButtonTheme: _buildButtonTheme(),
        extensions: [
          AppColorExtension(
            background: AppColors.blackBackground,
            surface: AppColors.blackSurface,
            card: AppColors.blackCard,
            cardBorder: AppColors.blackCardBorder,
            border: AppColors.blackCardBorder,
            primary: AppColors.gold,
            secondary: AppColors.goldLight,
            textPrimary: AppColors.blackTextPrimary,
            textSecondary: AppColors.blackTextSecondary,
          ),
        ],
      );

  static ThemeData get _oldBlueTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.gold,
          secondary: AppColors.goldAccent,
          surface: AppColors.blueSurface,
          onPrimary: AppColors.blueBackground,
          onSecondary: AppColors.blueBackground,
          onSurface: AppColors.blueTextPrimary,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.blueBackground,
        cardColor: AppColors.blueCard,
        dividerColor: AppColors.blueCardBorder,
        textTheme: _buildTextTheme(AppColors.blueTextPrimary),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.blueBackground,
          foregroundColor: AppColors.blueTextPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.blueBackground,
          selectedItemColor: AppColors.gold,
          unselectedItemColor: AppColors.blueTextSecondary,
        ),
        inputDecorationTheme: _buildInputTheme(AppColors.blueTextSecondary, AppColors.blueCardBorder),
        elevatedButtonTheme: _buildButtonTheme(),
        extensions: [
          AppColorExtension(
            background: AppColors.blueBackground,
            surface: AppColors.blueSurface,
            card: AppColors.blueCard,
            cardBorder: AppColors.blueCardBorder,
            border: AppColors.blueCardBorder,
            primary: AppColors.gold,
            secondary: AppColors.goldAccent,
            textPrimary: AppColors.blueTextPrimary,
            textSecondary: AppColors.blueTextSecondary,
          ),
        ],
      );

  static TextTheme _buildTextTheme(Color color) {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.playfairDisplay(color: color),
      displayMedium: GoogleFonts.playfairDisplay(color: color),
      headlineLarge: GoogleFonts.inter(color: color, fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.inter(color: color, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.inter(color: color),
      bodyMedium: GoogleFonts.inter(color: color.withValues(alpha: 0.85)),
    );
  }

  static InputDecorationTheme _buildInputTheme(Color hint, Color border) {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.transparent,
      hintStyle: TextStyle(color: hint),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gold, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  static ElevatedButtonThemeData _buildButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.black,
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    );
  }
}

// Custom theme extension for easy color access
class AppColorExtension extends ThemeExtension<AppColorExtension> {
  final Color background;
  final Color surface;
  final Color card;
  final Color cardBorder;
  final Color border;
  final Color primary;
  final Color secondary;
  final Color textPrimary;
  final Color textSecondary;

  const AppColorExtension({
    required this.background,
    required this.surface,
    required this.card,
    required this.cardBorder,
    required this.border,
    required this.primary,
    required this.secondary,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  ThemeExtension<AppColorExtension> copyWith({
    Color? background,
    Color? surface,
    Color? card,
    Color? cardBorder,
    Color? border,
    Color? primary,
    Color? secondary,
    Color? textPrimary,
    Color? textSecondary,
  }) {
    return AppColorExtension(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      cardBorder: cardBorder ?? this.cardBorder,
      border: border ?? this.border,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
    );
  }

  @override
  ThemeExtension<AppColorExtension> lerp(ThemeExtension<AppColorExtension>? other, double t) {
    if (other is! AppColorExtension) return this;
    return AppColorExtension(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      border: Color.lerp(border, other.border, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}

// Extension for easy access
extension ThemeExtensionX on BuildContext {
  AppColorExtension get appColors =>
      Theme.of(this).extension<AppColorExtension>()!;
}
