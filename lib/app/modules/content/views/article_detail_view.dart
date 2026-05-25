import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../data/models/content_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/utils/responsive_layout.dart';
import '../controllers/content_controller.dart';

class ArticleDetailView extends GetView<ContentController> {
  const ArticleDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final ArticleModel article = Get.arguments as ArticleModel;
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: context.screenHeight * 0.3,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: article.coverImageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: theme.colorScheme.surface),
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
                  const Divider(height: 32),
                  // Content
                  Html(
                    data: article.content,
                    style: {
                      'body': Style(
                        fontSize: FontSize(16),
                        lineHeight: LineHeight(1.7),
                        color: theme.colorScheme.onSurface,
                      ),
                      'h1': Style(
                        fontSize: FontSize(24),
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                      'h2': Style(
                        fontSize: FontSize(20),
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      'a': Style(color: AppColors.gold),
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
