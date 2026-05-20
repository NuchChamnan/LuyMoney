import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../themes/app_themes.dart';
import '../../data/models/content_model.dart';
import '../../routes/app_routes.dart';

class ArticleCard extends StatelessWidget {
  final ArticleModel article;
  final bool isBookmarked;
  final VoidCallback? onBookmark;
  final VoidCallback? onTap;

  const ArticleCard({
    super.key,
    required this.article,
    this.isBookmarked = false,
    this.onBookmark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return GestureDetector(
      onTap: onTap ?? () => Get.toNamed(Routes.ARTICLE_DETAIL, arguments: article),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: ext.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ext.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCover(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryChip(ext),
                    const SizedBox(height: 6),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ext.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.excerpt,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ext.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 12, color: ext.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            article.authorName,
                            style: TextStyle(color: ext.textSecondary, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.access_time, size: 12, color: ext.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          '${article.readTimeMinutes} ${'min'.tr}',
                          style: TextStyle(color: ext.textSecondary, fontSize: 11),
                        ),
                        if (onBookmark != null) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: onBookmark,
                            child: Icon(
                              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              size: 16,
                              color: isBookmarked ? ext.primary : ext.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover() {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
      child: CachedNetworkImage(
        imageUrl: article.coverImageUrl,
        width: 100,
        height: 130,
        fit: BoxFit.cover,
        placeholder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.grey.shade800,
          highlightColor: Colors.grey.shade600,
          child: Container(width: 100, height: 130, color: Colors.grey.shade800),
        ),
        errorWidget: (_, __, ___) => Container(
          width: 100,
          height: 130,
          color: Colors.grey.shade900,
          child: const Icon(Icons.article_outlined, color: Colors.white54, size: 28),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(AppColorExtension ext) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: ext.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        article.category,
        style: TextStyle(
          color: ext.primary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
