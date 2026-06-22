import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/banner_model.dart';
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

            // ── Promo banner carousel ────────────────────────────────────────
            const SliverToBoxAdapter(
              child: _BannerCarousel(),
            ),

            // ── Subscription card ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: _SubscriptionCard(),
              ),
            ),

            // ── Stats row ─────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _StatsRow(),
            ),

            // ── Quick actions ─────────────────────────────────────────────────
            const SliverToBoxAdapter(
              child: _QuickActionsRow(),
            ),

            // ── Latest Videos ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'latest_videos'.tr,
                icon: Icons.play_circle_rounded,
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
                    message: 'no_videos_yet'.tr,
                    actionLabel: 'browse_videos'.tr,
                    onAction: () => Get.toNamed(Routes.VIDEOS),
                  );
                }
                return SizedBox(
                  height: 214,
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
                icon: Icons.article_rounded,
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
                    message: 'no_articles_yet'.tr,
                    actionLabel: 'browse_articles'.tr,
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
                case 3:
                  Get.toNamed(Routes.NOTIFICATIONS)
                      ?.then((_) => controller.loadUnreadNotifications());
                  break;
                case 4: Get.toNamed(Routes.SETTINGS); break;
              }
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded, color: AppColors.gold),
                label: 'home'.tr,
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
                icon: Obx(() => Badge(
                      isLabelVisible: controller.unreadNotifications.value > 0,
                      label: Text('${controller.unreadNotifications.value}'),
                      child: const Icon(Icons.notifications_outlined),
                    )),
                selectedIcon: Obx(() => Badge(
                      isLabelVisible: controller.unreadNotifications.value > 0,
                      label: Text('${controller.unreadNotifications.value}'),
                      child: const Icon(Icons.notifications_rounded, color: AppColors.gold),
                    )),
                label: 'notifications'.tr,
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

  // ── Hero header ────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, AppColorExtension ext, ThemeData theme) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'good_morning'.tr
        : now.hour < 17
            ? 'good_afternoon'.tr
            : 'good_evening'.tr;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gold.withValues(alpha: isDark ? 0.22 : 0.16),
            ext.background,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          // Decorative glow
          Positioned(
            top: -50,
            right: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: isDark ? 0.10 : 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: isDark ? 0.06 : 0.05),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 16, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _HeaderAvatar(),
                    const SizedBox(width: 14),
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: ext.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          )),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed(Routes.SETTINGS),
                      child: Container(
                        padding: const EdgeInsets.all(11),
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
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.trending_up_rounded,
                          size: 14, color: AppColors.gold),
                      const SizedBox(width: 6),
                      Text(
                        'financial_freedom'.tr,
                        style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header Avatar ──────────────────────────────────────────────────────────────
class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = Get.find<AuthService>().currentUser.value;
      final name = Get.find<HomeController>().userName;
      final source = user?.name.isNotEmpty == true ? user!.name : name;
      final initial = source.isNotEmpty ? source[0].toUpperCase() : 'U';

      ImageProvider? avatarImage;
      if (user?.avatarBase64 != null && user!.avatarBase64!.isNotEmpty) {
        avatarImage = MemoryImage(base64Decode(user.avatarBase64!));
      } else if (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) {
        avatarImage = NetworkImage(user.avatarUrl!);
      }

      return GestureDetector(
        onTap: () => Get.toNamed(Routes.PROFILE),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: avatarImage == null ? AppColors.goldGradient : null,
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: avatarImage != null
              ? CircleAvatar(radius: 28, backgroundImage: avatarImage)
              : Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                ),
        ),
      );
    });
  }
}

// ── Promo Banner Carousel ──────────────────────────────────────────────────────
class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel();

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  final _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  void _startAutoScroll(int itemCount) {
    _timer?.cancel();
    if (itemCount <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pageController.hasClients) return;
      _currentPage = (_currentPage + 1) % itemCount;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleTap(BannerModel banner) async {
    final link = banner.linkUrl.trim();
    if (link.isEmpty) return;
    if (link.startsWith('/')) {
      Get.toNamed(link);
      return;
    }
    final uri = Uri.tryParse(link);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    return Obx(() {
      final banners = Get.find<HomeController>().banners;
      if (banners.isEmpty) return const SizedBox.shrink();

      _startAutoScroll(banners.length);
      if (_currentPage >= banners.length) _currentPage = 0;

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: AspectRatio(
          aspectRatio: 16 / 7,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: banners.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (_, i) {
                    final banner = banners[i];
                    return GestureDetector(
                      onTap: () => _handleTap(banner),
                      child: CachedNetworkImage(
                        imageUrl: banner.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (_, _) => Container(color: ext.card),
                        errorWidget: (_, _, _) => Container(
                          color: ext.card,
                          child: Icon(Icons.image_not_supported_outlined,
                              color: ext.textSecondary),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (banners.length > 1)
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(banners.length, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.gold
                              : Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      );
    });
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
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.workspace_premium_rounded,
                      color: Colors.black, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('unlock_premium_content'.tr,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              fontSize: 15)),
                      const SizedBox(height: 2),
                      Text('subscribe_to_access'.tr,
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_ios,
                      color: Colors.black, size: 14),
                ),
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
          ? 'subscription_expired'.tr
          : isExpiring
              ? '${'subscription_expiring'.tr} — ${sub.daysRemaining} ${'days_left'.tr}'
              : 'subscription_active'.tr;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
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
                child: Text('renew'.tr,
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
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          child: Row(
            children: [
              _StatTile(
                icon: Icons.play_circle_rounded,
                label: 'videos'.tr,
                value: controller.totalVideos.value > 0
                    ? '${controller.totalVideos.value}'
                    : '0',
                color: const Color(0xFF6C63FF),
                onTap: () => Get.toNamed(Routes.VIDEOS),
              ),
              const SizedBox(width: 10),
              _StatTile(
                icon: Icons.article_rounded,
                label: 'articles'.tr,
                value: controller.totalArticles.value > 0
                    ? '${controller.totalArticles.value}'
                    : '0',
                color: const Color(0xFF00BCD4),
                onTap: () => Get.toNamed(Routes.ARTICLES),
              ),
              const SizedBox(width: 10),
              _StatTile(
                icon: Icons.category_rounded,
                label: 'topics'.tr,
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
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          decoration: BoxDecoration(
            color: ext.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ext.border),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 10),
              Text(value,
                  style: TextStyle(
                      color: ext.textPrimary,
                      fontSize: 19,
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

// ── Quick Actions Row ─────────────────────────────────────────────────────────
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Row(
        children: [
          _QuickActionTile(
            icon: Icons.bookmark_rounded,
            label: 'saved_videos'.tr,
            color: const Color(0xFFFF6B6B),
            onTap: () => Get.toNamed(Routes.SAVED_VIDEOS),
          ),
          _QuickActionTile(
            icon: Icons.workspace_premium_rounded,
            label: 'premium'.tr,
            color: AppColors.gold,
            onTap: () => Get.toNamed(Routes.SUBSCRIPTION),
          ),
          _QuickActionTile(
            icon: Icons.support_agent_rounded,
            label: 'support'.tr,
            color: const Color(0xFF4ECDC4),
            onTap: () => Get.toNamed(Routes.SUPPORT),
          ),
          _QuickActionTile(
            icon: Icons.settings_rounded,
            label: 'settings'.tr,
            color: const Color(0xFF9B59B6),
            onTap: () => Get.toNamed(Routes.SETTINGS),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: ext.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, required this.icon, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.black, size: 18),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: TextStyle(
                  color: ext.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800)),
          const Spacer(),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: ext.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ext.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('see_all'.tr,
                        style: const TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                    const SizedBox(width: 2),
                    const Icon(Icons.arrow_forward_ios,
                        size: 10, color: AppColors.gold),
                  ],
                ),
              ),
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
      height: 214,
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          itemCount: 3,
          itemBuilder: (_, i) => Container(
            width: 200,
            height: 214,
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
