import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/content_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/utils/responsive_layout.dart';
import '../controllers/content_controller.dart';

class ArticleDetailView extends GetView<ContentController> {
  const ArticleDetailView({super.key});

  Future<void> _openLink(String linkUrl) async {
    final link = linkUrl.trim();
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
    final ArticleModel article = Get.arguments as ArticleModel;
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: context.screenHeight * 0.35,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: article.coverImageUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    Container(color: theme.colorScheme.surface),
                errorWidget: (_, _, _) => Container(
                  color: theme.colorScheme.surface,
                  child: Icon(Icons.image_not_supported_outlined,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                ),
              ),
            ),
            actions: [
              Obx(() {
                final isBookmarked =
                    controller.articles.firstWhere((a) => a.id == article.id,
                        orElse: () => article).isBookmarked;
                return IconButton(
                  onPressed: () =>
                      controller.toggleArticleBookmark(article.id),
                  icon: Icon(
                    isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline,
                    color: AppColors.gold,
                  ),
                );
              }),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(article.category.capitalize!,
                        style: const TextStyle(color: AppColors.gold, fontSize: 12)),
                  ),
                  const SizedBox(height: 12),
                  Text(article.title,
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.gold,
                        child: Text(article.authorName[0],
                            style: const TextStyle(
                                color: Colors.black, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(article.authorName,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          Text(
                            '${article.readTimeMinutes} ${'min_read'.tr}',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Caption (optional, plain text)
                  if (article.content.trim().isNotEmpty) ...[
                    const Divider(height: 32),
                    Text(
                      article.content,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.7,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],

                  // Link button (optional)
                  if (article.linkUrl.trim().isNotEmpty) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _openLink(article.linkUrl),
                        icon: const Icon(Icons.open_in_new_rounded, size: 18),
                        label: Text('view_link'.tr),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
