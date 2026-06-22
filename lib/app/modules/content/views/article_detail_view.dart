import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/content_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/themes/app_themes.dart';
import '../../../shared/utils/responsive_layout.dart';
import '../../../shared/widgets/comment_widgets.dart';
import '../../../shared/widgets/linkified_text.dart';
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
    final ext = theme.extension<AppColorExtension>()!;

    controller.listenToComments('articles', article.id);

    return Scaffold(
      backgroundColor: ext.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: context.screenHeight * 0.36,
            pinned: true,
            backgroundColor: ext.background,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.45),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: GestureDetector(
                onTap: article.linkUrl.trim().isNotEmpty
                    ? () => _openLink(article.linkUrl)
                    : null,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: article.coverImageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          Container(color: theme.colorScheme.surface),
                      errorWidget: (_, _, _) => Container(
                        color: theme.colorScheme.surface,
                        child: Icon(Icons.image_not_supported_outlined,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.4)),
                      ),
                    ),
                    // Bottom scrim so the rounded sheet below reads cleanly
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 70,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0),
                              Colors.black.withValues(alpha: 0.35),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (article.linkUrl.trim().isNotEmpty)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.open_in_new_rounded,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 6),
                              Text('view_link'.tr,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ── Content sheet (overlaps the cover image slightly) ────────────
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -18),
              child: Container(
                decoration: BoxDecoration(
                  color: ext.background,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category + read time
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(article.category.capitalize!,
                                style: const TextStyle(
                                    color: AppColors.gold,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.access_time_rounded,
                              size: 13, color: ext.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${article.readTimeMinutes} ${'min_read'.tr}',
                            style: TextStyle(
                                color: ext.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Title
                      Text(article.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800, height: 1.25)),
                      const SizedBox(height: 14),

                      // Author row
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 17,
                            backgroundColor: AppColors.gold,
                            backgroundImage: article.authorAvatarUrl != null &&
                                    article.authorAvatarUrl!.isNotEmpty
                                ? NetworkImage(article.authorAvatarUrl!)
                                : null,
                            child: article.authorAvatarUrl == null ||
                                    article.authorAvatarUrl!.isEmpty
                                ? Text(article.authorName[0].toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700))
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Text(article.authorName,
                              style: TextStyle(
                                  color: ext.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                          if (article.isPinned) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.push_pin_rounded,
                                size: 14, color: AppColors.gold),
                          ],
                        ],
                      ),

                      // Caption (optional, links are tappable)
                      if (article.content.trim().isNotEmpty) ...[
                        const SizedBox(height: 18),
                        LinkifiedText(
                          text: article.content,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.7,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                      Divider(height: 1, color: ext.border),
                      const SizedBox(height: 6),

                      // ── Action bar: Like / Save / Pin ───────────────────
                      Obx(() {
                        final live = controller.articles.firstWhere(
                            (a) => a.id == article.id,
                            orElse: () => article);
                        return Row(
                          children: [
                            _ArticleActionBtn(
                              icon: live.isLiked
                                  ? Icons.thumb_up_rounded
                                  : Icons.thumb_up_outlined,
                              label: 'like'.tr,
                              color: live.isLiked
                                  ? AppColors.gold
                                  : ext.textSecondary,
                              onTap: () =>
                                  controller.toggleArticleLike(article.id),
                            ),
                            _verticalDivider(ext),
                            _ArticleActionBtn(
                              icon: live.isBookmarked
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_outline_rounded,
                              label: 'save'.tr,
                              color: live.isBookmarked
                                  ? AppColors.gold
                                  : ext.textSecondary,
                              onTap: () => controller
                                  .toggleArticleBookmark(article.id),
                            ),
                            _verticalDivider(ext),
                            _ArticleActionBtn(
                              icon: live.isPinned
                                  ? Icons.push_pin_rounded
                                  : Icons.push_pin_outlined,
                              label: 'pin'.tr,
                              color: live.isPinned
                                  ? AppColors.gold
                                  : ext.textSecondary,
                              onTap: () => controller
                                  .toggleArticlePinned(article.id),
                            ),
                          ],
                        );
                      }),

                      const SizedBox(height: 6),
                      Divider(height: 1, color: ext.border),
                      const SizedBox(height: 18),

                      // ── Comments header ──────────────────────────────────
                      Row(children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            gradient: AppColors.goldGradient,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'comments'.tr,
                          style: TextStyle(
                            color: ext.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Obx(() => Text(
                              '(${controller.comments.length})',
                              style: TextStyle(
                                color: ext.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            )),
                      ]),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              color: ext.background,
              child: CommentInputBar(
                ext: ext,
                controller: controller.commentController,
                isSending: controller.isSendingComment,
                onSend: () => controller.addComment('articles', article.id),
              ),
            ),
          ),

          Obx(() {
            if (controller.comments.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'no_comments_yet'.tr,
                      style: TextStyle(color: ext.textSecondary, fontSize: 14),
                    ),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => CommentTile(
                    comment: controller.comments[i],
                    ext: ext,
                    canDelete: controller.canDeleteComment(controller.comments[i]),
                    onDelete: () => controller.deleteComment(
                        'articles', article.id, controller.comments[i].id),
                  ),
                  childCount: controller.comments.length,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

Widget _verticalDivider(AppColorExtension ext) {
  return Container(
    width: 1,
    height: 22,
    color: ext.border,
  );
}

class _ArticleActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ArticleActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
