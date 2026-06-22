import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../themes/app_themes.dart';
import '../../data/models/content_model.dart';
import '../../routes/app_routes.dart';

/// Auto-extract YouTube thumbnail from any YouTube URL or ID
String _youtubeThumbnail(VideoModel video) {
  final id = video.youtubeVideoId;
  if (id.isNotEmpty) {
    return 'https://img.youtube.com/vi/$id/mqdefault.jpg';
  }
  return video.thumbnailUrl;
}

class VideoCard extends StatelessWidget {
  final VideoModel video;
  final bool isBookmarked;
  final VoidCallback? onBookmark;
  final VoidCallback? onTap;
  final bool horizontal; // true = small card for home carousel
  final bool showChannelInfo; // false = hide avatar + channel name row

  const VideoCard({
    super.key,
    required this.video,
    this.isBookmarked = false,
    this.onBookmark,
    this.onTap,
    this.horizontal = false,
    this.showChannelInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    return horizontal
        ? _CarouselCard(video: video, onTap: onTap)
        : _ListCard(
            video: video,
            isBookmarked: isBookmarked,
            onBookmark: onBookmark,
            onTap: onTap,
            showChannelInfo: showChannelInfo,
          );
  }
}

// ── Full-width vertical card (Videos list page) ───────────────────────────────
class _ListCard extends StatelessWidget {
  final VideoModel video;
  final bool isBookmarked;
  final VoidCallback? onBookmark;
  final VoidCallback? onTap;
  final bool showChannelInfo;

  const _ListCard({
    required this.video,
    required this.isBookmarked,
    this.onBookmark,
    this.onTap,
    this.showChannelInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    final thumbUrl = _youtubeThumbnail(video);

    return GestureDetector(
      onTap: onTap ?? () => Get.toNamed(Routes.VIDEO_DETAIL, arguments: video),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail 16:9 ──────────────────────────────────────────────
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Thumbnail image
                    thumbUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: thumbUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _ThumbPlaceholder(),
                            errorWidget: (_, __, ___) => _ThumbPlaceholder(),
                          )
                        : _ThumbPlaceholder(),

                    // Gradient overlay (bottom)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.5, 1.0],
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.55),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Center play button
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 28),
                      ),
                    ),

                    // Duration badge (bottom-right)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          video.durationFormatted,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    // Premium badge (top-left)
                    if (video.isPremium)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: AppColors.goldGradient,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('premium'.tr,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),

                    // Category badge (top-right) — always visible, never hidden in meta text
                    if (video.category.isNotEmpty)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            video.category.isNotEmpty
                                ? video.category[0].toUpperCase() +
                                    video.category.substring(1)
                                : video.category,
                            style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 10,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Info row ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 10, 4, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Channel avatar (hidden when showChannelInfo is false)
                  if (showChannelInfo) ...[
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.monetization_on_rounded,
                          color: Colors.black, size: 20),
                    ),
                    const SizedBox(width: 10),
                  ],

                  // Title + meta
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.title,
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
                        if (showChannelInfo)
                          Row(
                            children: [
                              Text(
                                'Luy Money',
                                style: TextStyle(
                                    color: ext.textSecondary, fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              Text('•',
                                  style: TextStyle(
                                      color: ext.textSecondary, fontSize: 12)),
                              const SizedBox(width: 4),
                              Icon(Icons.remove_red_eye_outlined,
                                  size: 12, color: ext.textSecondary),
                              const SizedBox(width: 2),
                              Text('${video.viewCount}',
                                  style: TextStyle(
                                      color: ext.textSecondary, fontSize: 12)),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Icon(Icons.remove_red_eye_outlined,
                                  size: 12, color: ext.textSecondary),
                              const SizedBox(width: 2),
                              Text('${video.viewCount}',
                                  style: TextStyle(
                                      color: ext.textSecondary, fontSize: 12)),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Bookmark
                  if (onBookmark != null)
                    GestureDetector(
                      onTap: onBookmark,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          size: 20,
                          color: isBookmarked
                              ? AppColors.gold
                              : ext.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Divider(color: ext.border, height: 16, thickness: 0.5),
          ],
        ),
      ),
    );
  }
}

// ── Small carousel card (Home page) ──────────────────────────────────────────
class _CarouselCard extends StatelessWidget {
  final VideoModel video;
  final VoidCallback? onTap;

  const _CarouselCard({required this.video, this.onTap});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    final thumbUrl = _youtubeThumbnail(video);

    return GestureDetector(
      onTap: onTap ?? () => Get.toNamed(Routes.VIDEO_DETAIL, arguments: video),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: ext.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ext.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    thumbUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: thumbUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _ThumbPlaceholder(),
                            errorWidget: (_, __, ___) => _ThumbPlaceholder(),
                          )
                        : _ThumbPlaceholder(),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(video.durationFormatted,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Text
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryChip(label: video.category, ext: ext),
                  const SizedBox(height: 4),
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ext.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.remove_red_eye_outlined,
                          size: 11, color: ext.textSecondary),
                      const SizedBox(width: 3),
                      Text('${video.viewCount}',
                          style: TextStyle(
                              color: ext.textSecondary, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────
class _ThumbPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg   = isDark ? Colors.grey.shade900 : Colors.grey.shade200;
    final icon = isDark
        ? Colors.white.withValues(alpha: 0.3)
        : Colors.grey.shade500;
    return Container(
      color: bg,
      child: Center(
        child: Icon(Icons.play_circle_outline, color: icon, size: 40),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final AppColorExtension ext;
  const _CategoryChip({required this.label, required this.ext});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: ext.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.isNotEmpty
            ? label[0].toUpperCase() + label.substring(1)
            : label,
        style:
            TextStyle(color: ext.primary, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}
