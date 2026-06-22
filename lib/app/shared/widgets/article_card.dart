import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';
import '../themes/app_themes.dart';
import '../../data/models/content_model.dart';
import '../../routes/app_routes.dart';
import '../../modules/content/controllers/content_controller.dart';
import 'linkified_text.dart';

class ArticleCard extends StatelessWidget {
  final ArticleModel article;
  final VoidCallback? onTap;

  const ArticleCard({
    super.key,
    required this.article,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return GestureDetector(
      onTap: onTap ?? () => Get.toNamed(Routes.ARTICLE_DETAIL, arguments: article),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: ext.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ext.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: avatar + author + meta ───────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
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
                        ? Text(
                            article.authorName.isNotEmpty
                                ? article.authorName[0].toUpperCase()
                                : 'L',
                            style: const TextStyle(
                                color: Colors.black, fontWeight: FontWeight.w800),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (article.isPinned) ...[
                              Icon(Icons.push_pin_rounded,
                                  size: 12, color: AppColors.gold),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(article.authorName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: ext.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 11, color: ext.textSecondary),
                            const SizedBox(width: 2),
                            Text(
                              '${article.readTimeMinutes} ${'min'.tr}',
                              style: TextStyle(
                                  color: ext.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Title (post headline) ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                article.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ext.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ),

            // ── Caption (optional, links are tappable) ────────────────────
            if (article.excerpt.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                child: LinkifiedText(
                  text: article.excerpt,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ext.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // ── Full-width cover image (Facebook-post style) ──────────────
            _buildCover(),

            // ── Footer: Like / Comment / Save / Pin ───────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
              child: Row(
                children: [
                  _FooterAction(
                    icon: article.isLiked
                        ? Icons.thumb_up_rounded
                        : Icons.thumb_up_outlined,
                    label: 'like'.tr,
                    color: article.isLiked ? AppColors.gold : ext.textSecondary,
                    onTap: () =>
                        Get.find<ContentController>().toggleArticleLike(article.id),
                  ),
                  _FooterAction(
                    icon: Icons.mode_comment_outlined,
                    label: 'comments'.tr,
                    color: ext.textSecondary,
                    onTap: onTap ??
                        () => Get.toNamed(Routes.ARTICLE_DETAIL, arguments: article),
                  ),
                  _FooterAction(
                    icon: article.isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    label: 'save'.tr,
                    color: article.isBookmarked ? AppColors.gold : ext.textSecondary,
                    onTap: () => Get.find<ContentController>()
                        .toggleArticleBookmark(article.id),
                  ),
                  _FooterAction(
                    icon: article.isPinned
                        ? Icons.push_pin_rounded
                        : Icons.push_pin_outlined,
                    label: 'pin'.tr,
                    color: article.isPinned ? AppColors.gold : ext.textSecondary,
                    onTap: () =>
                        Get.find<ContentController>().toggleArticlePinned(article.id),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover() {
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: article.coverImageUrl,
            fit: BoxFit.cover,
            placeholder: (context, _) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final base = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
              final highlight =
                  isDark ? Colors.grey.shade600 : Colors.grey.shade100;
              return Shimmer.fromColors(
                baseColor: base,
                highlightColor: highlight,
                child: Container(color: base),
              );
            },
            errorWidget: (context, _, err) {
              final theme = Theme.of(context);
              return Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(Icons.article_outlined,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    size: 36),
              );
            },
          ),

          // Premium badge (top-left)
          if (article.isPremium)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_rounded, color: Colors.black, size: 11),
                    const SizedBox(width: 3),
                    Text(
                      'premium'.tr,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Category badge (top-right) — always visible, never hidden in meta text
          if (article.category.isNotEmpty)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  article.category.isNotEmpty
                      ? article.category[0].toUpperCase() +
                          article.category.substring(1)
                      : article.category,
                  style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),

          // Link indicator (bottom-right) when the post has an attached link
          if (article.linkUrl.trim().isNotEmpty)
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.open_in_new_rounded,
                    color: Colors.white, size: 14),
              ),
            ),
        ],
      ),
    );
  }
}

class _FooterAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FooterAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(width: 5),
              Text(label, style: TextStyle(color: color, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
