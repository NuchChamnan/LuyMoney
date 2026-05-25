import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../themes/app_themes.dart';
import '../../routes/app_routes.dart';

class LockOverlay extends StatelessWidget {
  final Widget child;
  final bool isLocked;

  const LockOverlay({
    super.key,
    required this.child,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLocked) return child;

    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: ClipRRect(
            child: BackdropFilter(
              filter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.55),
                BlendMode.darken,
              ),
              child: Container(
                color: Colors.black.withValues(alpha: 0.45),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [ext.primary, ext.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock, color: Colors.black, size: 28),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'premium_content'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'subscribe_to_access'.tr,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 18),
                      GestureDetector(
                        onTap: () => Get.toNamed(Routes.SUBSCRIPTION),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [ext.primary, ext.secondary],
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            'subscribe_now'.tr,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
