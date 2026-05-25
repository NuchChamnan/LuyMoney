import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/utils/responsive_layout.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnim = Tween<double>(begin: 0.3, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _animController.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    try {
      final authService = Get.find<AuthService>();
      if (authService.isLoggedIn) {
        if (authService.isAdmin) {
          Get.offAllNamed(Routes.ADMIN);
        } else if (authService.hasActiveSubscription) {
          Get.offAllNamed(Routes.HOME);
        } else {
          Get.offAllNamed(Routes.SUBSCRIPTION);
        }
      } else {
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (e) {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackBackground,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Gold coin logo placeholder (use Lottie in production)
                Container(
                  width: context.rSize(120),
                  height: context.rSize(120),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.goldGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.monetization_on_rounded,
                    color: Colors.black,
                    size: context.rSize(64),
                  ),
                ),
                SizedBox(height: context.rSize(32)),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.goldGradient.createShader(bounds),
                  child: Text(
                    'LUY MONEY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.rFont(36),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                    ),
                  ),
                ),
                SizedBox(height: context.rSize(8)),
                Text(
                  'Financial Freedom',
                  style: TextStyle(
                    color: AppColors.blackTextSecondary,
                    fontSize: context.rFont(14),
                    letterSpacing: 3,
                  ),
                ),
                SizedBox(height: context.rSize(60)),
                SizedBox(
                  width: context.rSize(24),
                  height: context.rSize(24),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.gold.withValues(alpha: 0.6),
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
