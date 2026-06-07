import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/themes/app_themes.dart';
import '../../../shared/widgets/video_card.dart';
import '../../../shared/widgets/article_card.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext  = Theme.of(context).extension<AppColorExtension>()!;

    return Scaffold(
      backgroundColor: ext.background,
      body: RefreshIndicator(
        color: AppColors.gold,
        onRefresh: () async => controller.loadRecentContent(),
        child: CustomScrollView(
          slivers: [
            // ── Header ────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildHeader(context, ext, theme),
            ),

            // ── Subscription card ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _SubscriptionCard(),
              ),
            ),

            // ── Stats row ─────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _StatsRow(),
            ),

            // ── Latest Videos ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'latest_videos'.tr,
                onSeeAll: () => Get.toNamed(Routes.VIDEOS),
              ),
            ),
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _ShimmerCarousel();
                }
                if (controller.recentVideos.isEmpty) {
                  return _EmptySection(
                    icon: Icons.play_circle_outline,
                    message: 'No videos yet',
                    actionLabel: 'Browse Videos',
                    onAction: () => Get.toNamed(Routes.VIDEOS),
                  );
                }
                return SizedBox(
                  height: 210,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    itemCount: controller.recentVideos.length,
                    itemBuilder: (_, i) {
                      final v = controller.recentVideos[i];
                      return VideoCard(
                        video: v,
                        horizontal: true,
                        onTap: () {
                          final auth = Get.find<AuthService>();
                          if (v.isPremium && !auth.hasActiveSubscription) {
                            Get.toNamed(Routes.SUBSCRIPTION);
                          } else {
                            Get.toNamed(Routes.VIDEO_DETAIL, arguments: v);
                          }
                        },
                      );
                    },
                  ),
                );
              }),
            ),

            // ── Latest Articles ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'latest_articles'.tr,
                onSeeAll: () => Get.toNamed(Routes.ARTICLES),
              ),
            ),
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _ShimmerList();
                }
                if (controller.recentArticles.isEmpty) {
                  return _EmptySection(
                    icon: Icons.article_outlined,
                    message: 'No articles yet',
                    actionLabel: 'Browse Articles',
                    onAction: () => Get.toNamed(Routes.ARTICLES),
                  );
                }
                return Column(
                  children: controller.recentArticles
                      .map((a) => Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: ArticleCard(
                              article: a,
                              onTap: () {
                                final auth = Get.find<AuthService>();
                                if (a.isPremium &&
                                    !auth.hasActiveSubscription) {
                                  Get.toNamed(Routes.SUBSCRIPTION);
                                } else {
                                  Get.toNamed(Routes.ARTICLE_DETAIL,
                                      arguments: a);
                                }
                              },
                            ),
                          ))
                      .toList(),
                );
              }),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),

      // ── Bottom Navigation ─────────────────────────────────────────────────
      bottomNavigationBar: Obx(() => NavigationBar(
            selectedIndex: controller.currentIndex.value,
            backgroundColor: ext.surface,
            indicatorColor: AppColors.gold.withValues(alpha: 0.15),
            onDestinationSelected: (i) {
              controller.changeTab(i);
              switch (i) {
                case 1: Get.toNamed(Routes.VIDEOS); break;
                case 2: Get.toNamed(Routes.ARTICLES); break;
                case 3: Get.toNamed(Routes.SUPPORT); break;
                case 4: Get.toNamed(Routes.SETTINGS); break;
              }
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded, color: AppColors.gold),
                label: 'Home',
              ),
              NavigationDestination(
                icon: const Icon(Icons.play_circle_outline),
                selectedIcon: const Icon(Icons.play_circle_rounded, color: AppColors.gold),
                label: 'videos'.tr,
              ),
              NavigationDestination(
                icon: const Icon(Icons.article_outlined),
                selectedIcon: const Icon(Icons.article_rounded, color: AppColors.gold),
                label: 'articles'.tr,
              ),
              NavigationDestination(
                icon: const Icon(Icons.support_agent_outlined),
                selectedIcon: const Icon(Icons.support_agent_rounded, color: AppColors.gold),
                label: 'support'.tr,
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings_rounded, color: AppColors.gold),
                label: 'settings'.tr,
              ),
            ],
          )),
    );
  }

  Widget _buildHeader(BuildContext context, AppColorExtension ext, ThemeData theme) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good Morning'
        : now.hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gold.withValues(alpha: 0.12),
            ext.background,
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                          color: ext.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.userName.isEmpty
                          ? 'Luy Money'
                          : controller.userName,
                      style: TextStyle(
                        color: ext.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'financial_freedom'.tr,
                      style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                )),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.SETTINGS),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ext.surface,
                shape: BoxShape.circle,
                border: Border.all(color: ext.border),
              ),
              child: Icon(Icons.settings_outlined,
                  color: ext.textSecondary, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Subscription Status Card ──────────────────────────────────────────────────
class _SubscriptionCard extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sub = Get.find<AuthService>().currentUser.value?.subscription;

      if (sub == null) {
        return GestureDetector(
          onTap: () => Get.toNamed(Routes.SUBSCRIPTION),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.workspace_premium_rounded,
                      color: Colors.black, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Unlock Premium Content',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              fontSize: 15)),
                      Text('Subscribe to access all videos & articles',
                          style: TextStyle(
                              color: Colors.black54, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.black54, size: 16),
              ],
            ),
          ),
        );
      }

      final isExpired = sub.isExpired;
      final isExpiring = sub.isExpiringSoon;
      final color = isExpired
          ? AppColors.error
          : isExpiring
              ? AppColors.warning
              : AppColors.success;
      final icon = isExpired
          ? Icons.lock_rounded
          : isExpiring
              ? Icons.access_time_rounded
              : Icons.verified_rounded;
      final title = isExpired
          ? 'Subscription Expired'
          : isExpiring
              ? 'Expiring Soon — ${sub.daysRemaining} days left'
              : 'Subscription Active';

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ),
            if (isExpired || isExpiring)
              TextButton(
                onPressed: () => Get.toNamed(Routes.SUBSCRIPTION),
                child: Text('Renew',
                    style: TextStyle(
                        color: color, fontWeight: FontWeight.w800)),
              ),
          ],
        ),
      );
    });
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────
class _StatsRow extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Row(
            children: [
              _StatTile(
                icon: Icons.play_circle_rounded,
                label: 'Videos',
                value: controller.totalVideos.value > 0
                    ? '${controller.totalVideos.value}'
                    : '0',
                color: const Color(0xFF6C63FF),
                onTap: () => Get.toNamed(Routes.VIDEOS),
              ),
              const SizedBox(width: 10),
              _StatTile(
                icon: Icons.article_rounded,
                label: 'Articles',
                value: controller.totalArticles.value > 0
                    ? '${controller.totalArticles.value}'
                    : '0',
                color: const Color(0xFF00BCD4),
                onTap: () => Get.toNamed(Routes.ARTICLES),
              ),
              const SizedBox(width: 10),
              _StatTile(
                icon: Icons.category_rounded,
                label: 'Topics',
                value: controller.totalTopics.value > 0
                    ? '${controller.totalTopics.value}'
                    : '0',
                color: AppColors.gold,
              ),
            ],
          ),
        ));
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: ext.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ext.border),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(value,
                  style: TextStyle(
                      color: ext.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      color: ext.textSecondary, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: TextStyle(
                  color: ext.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
          const Spacer(),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('See All',
                  style: TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ),
        ],
      ),
    );
  }
}

// ── Empty Section ─────────────────────────────────────────────────────────────
class _EmptySection extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptySection({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: ext.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ext.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: ext.textSecondary),
            const SizedBox(height: 10),
            Text(message,
                style: TextStyle(color: ext.textSecondary, fontSize: 13)),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.gold),
                  foregroundColor: AppColors.gold,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Shimmer Carousel ──────────────────────────────────────────────────────────
class _ShimmerCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base      = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlight = isDark ? Colors.grey.shade600 : Colors.grey.shade100;
    return SizedBox(
      height: 210,
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          itemCount: 3,
          itemBuilder: (_, i) => Container(
            width: 200,
            height: 210,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shimmer List ──────────────────────────────────────────────────────────────
class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base      = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlight = isDark ? Colors.grey.shade600 : Colors.grey.shade100;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: List.generate(
            2,
            (_) => Container(
              height: 100,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: base,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

