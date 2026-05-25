import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../data/models/content_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/themes/app_themes.dart';
import '../../../shared/widgets/video_card.dart';
import '../controllers/content_controller.dart';

class VideoDetailView extends GetView<ContentController> {
  const VideoDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final VideoModel video = Get.arguments as VideoModel;

    if (video.hostType == VideoHostType.youtube) {
      final ytController = YoutubePlayerController(
        initialVideoId: video.youtubeVideoId,
        flags: const YoutubePlayerFlags(autoPlay: true),
      );
      return YoutubePlayerBuilder(
        player: YoutubePlayer(controller: ytController),
        builder: (ctx, player) =>
            _VideoDetailScaffold(video: video, player: player),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(video.title)),
      body: const Center(child: Text('Video player not available')),
    );
  }
}

// ── Main Scaffold ─────────────────────────────────────────────────────────────
class _VideoDetailScaffold extends StatefulWidget {
  final VideoModel video;
  final Widget player;
  const _VideoDetailScaffold({required this.video, required this.player});

  @override
  State<_VideoDetailScaffold> createState() => _VideoDetailScaffoldState();
}

class _VideoDetailScaffoldState extends State<_VideoDetailScaffold> {
  bool _descExpanded = false;
  bool _liked = false;
  int _likeCount = 0;
  late String _selectedCategory; // for the filter bar below

  @override
  void initState() {
    super.initState();
    _likeCount = widget.video.viewCount ~/ 10;
    // Default: show all videos (not filtered)
    _selectedCategory = 'all';
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    final theme = Theme.of(context);
    final ctrl = Get.find<ContentController>();

    return Scaffold(
      backgroundColor: ext.background,
      body: Column(
        children: [
          // ── Player (fixed at top) ──────────────────────────────────────────
          widget.player,

          // ── Scrollable content below ───────────────────────────────────────
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Title + close
                SliverToBoxAdapter(
                  child: _TitleSection(
                      video: widget.video, ext: ext, theme: theme),
                ),

                // Stats row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Wrap(
                      spacing: 14,
                      children: [
                        _StatChip(
                          icon: Icons.visibility_outlined,
                          label:
                              '${_formatCount(widget.video.viewCount)} views',
                          color: ext.textSecondary,
                        ),
                        _StatChip(
                          icon: Icons.timer_outlined,
                          label: widget.video.durationFormatted,
                          color: AppColors.gold,
                        ),
                        _StatChip(
                          icon: Icons.calendar_today_outlined,
                          label: _formatDate(widget.video.publishedAt),
                          color: ext.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),

                // Action bar
                SliverToBoxAdapter(
                  child: _ActionBar(
                    video: widget.video,
                    ext: ext,
                    liked: _liked,
                    likeCount: _likeCount,
                    onLike: () => setState(() {
                      _liked = !_liked;
                      _likeCount += _liked ? 1 : -1;
                    }),
                    onMore: () => _showMoreSheet(context, ext),
                  ),
                ),

                SliverToBoxAdapter(child: Divider(height: 1, color: ext.border)),

                // Description + category chip
                SliverToBoxAdapter(
                  child: _DescriptionSection(
                    video: widget.video,
                    ext: ext,
                    expanded: _descExpanded,
                    onToggle: () =>
                        setState(() => _descExpanded = !_descExpanded),
                  ),
                ),

                SliverToBoxAdapter(child: Divider(height: 1, color: ext.border)),

                // ── Category filter bar ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: _CategoryFilterBar(
                    ctrl: ctrl,
                    selectedCategory: _selectedCategory,
                    onSelect: (cat) =>
                        setState(() => _selectedCategory = cat),
                    ext: ext,
                  ),
                ),

                // ── "More Videos" header ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                    child: Row(children: [
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
                        'More Videos',
                        style: TextStyle(
                          color: ext.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ]),
                  ),
                ),

                // ── Reactive filtered video list ─────────────────────────────
                Obx(() {
                  final filtered = ctrl.videos.where((v) {
                    final notSelf = v.id != widget.video.id;
                    final catMatch = _selectedCategory == 'all' ||
                        v.category.toLowerCase() ==
                            _selectedCategory.toLowerCase();
                    return notSelf && catMatch;
                  }).toList();

                  if (filtered.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(children: [
                            Icon(Icons.video_library_outlined,
                                size: 48,
                                color: ext.textSecondary
                                    .withValues(alpha: 0.4)),
                            const SizedBox(height: 12),
                            Text(
                              'No videos found',
                              style: TextStyle(
                                  color: ext.textSecondary, fontSize: 14),
                            ),
                          ]),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: VideoCard(
                            video: filtered[i],
                            onTap: () => Get.off(
                              () => const VideoDetailView(),
                              arguments: filtered[i],
                            ),
                            onBookmark: () => ctrl
                                .toggleVideoBookmark(filtered[i].id),
                          ),
                        ),
                        childCount: filtered.length,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreSheet(BuildContext context, AppColorExtension ext) {
    Get.bottomSheet(
      _MoreSheet(video: widget.video, ext: ext),
      isScrollControlled: true,
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

// ── Category Filter Bar ───────────────────────────────────────────────────────
class _CategoryFilterBar extends StatelessWidget {
  final ContentController ctrl;
  final String selectedCategory;
  final ValueChanged<String> onSelect;
  final AppColorExtension ext;

  const _CategoryFilterBar({
    required this.ctrl,
    required this.selectedCategory,
    required this.onSelect,
    required this.ext,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cats = ctrl.categories;
      return Container(
        color: ext.background,
        height: 52,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: cats.length,
          separatorBuilder: (_, i) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final cat = cats[i];
            final isSelected =
                cat.toLowerCase() == selectedCategory.toLowerCase();
            return GestureDetector(
              onTap: () => onSelect(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.goldGradient : null,
                  color: isSelected ? null : ext.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.gold : ext.border,
                    width: isSelected ? 0 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.3),
                            blurRadius: 6,
                          )
                        ]
                      : [],
                ),
                child: Text(
                  cat.capitalize!,
                  style: TextStyle(
                    color: isSelected ? Colors.black : ext.textSecondary,
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

// ── Title Section ─────────────────────────────────────────────────────────────
class _TitleSection extends StatelessWidget {
  final VideoModel video;
  final AppColorExtension ext;
  final ThemeData theme;
  const _TitleSection(
      {required this.video, required this.ext, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              video.title,
              style: TextStyle(
                color: ext.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: Get.back,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: ext.surface,
                shape: BoxShape.circle,
                border: Border.all(color: ext.border),
              ),
              child: Icon(Icons.close_rounded,
                  size: 18, color: ext.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Chip ─────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w500)),
    ]);
  }
}

// ── Description Section ───────────────────────────────────────────────────────
class _DescriptionSection extends StatelessWidget {
  final VideoModel video;
  final AppColorExtension ext;
  final bool expanded;
  final VoidCallback onToggle;

  const _DescriptionSection({
    required this.video,
    required this.ext,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              video.category.capitalize!,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          if (video.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            AnimatedCrossFade(
              firstChild: Text(
                video.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: ext.textSecondary, fontSize: 14, height: 1.6),
              ),
              secondChild: Text(
                video.description,
                style: TextStyle(
                    color: ext.textSecondary, fontSize: 14, height: 1.6),
              ),
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
            GestureDetector(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  expanded ? 'Show less ▲' : 'Show more ▼',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Action Bar ────────────────────────────────────────────────────────────────
class _ActionBar extends StatelessWidget {
  final VideoModel video;
  final AppColorExtension ext;
  final bool liked;
  final int likeCount;
  final VoidCallback onLike;
  final VoidCallback onMore;

  const _ActionBar({
    required this.video,
    required this.ext,
    required this.liked,
    required this.likeCount,
    required this.onLike,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Like
          _ActionBtn(
            icon: liked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
            label: likeCount > 0 ? likeCount.toString() : 'Like',
            color: liked ? AppColors.gold : ext.textSecondary,
            onTap: onLike,
            ext: ext,
          ),

          // Bookmark
          Obx(() {
            final ctrl = Get.find<ContentController>();
            final isBookmarked =
                ctrl.videos
                    .firstWhereOrNull((v) => v.id == video.id)
                    ?.isBookmarked ??
                    video.isBookmarked;
            return _ActionBtn(
              icon: isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_outline_rounded,
              label: 'Save',
              color: isBookmarked ? AppColors.gold : ext.textSecondary,
              onTap: () => ctrl.toggleVideoBookmark(video.id),
              ext: ext,
            );
          }),

          // Share
          _ActionBtn(
            icon: Icons.share_outlined,
            label: 'Share',
            color: ext.textSecondary,
            onTap: () => SharePlus.instance.share(
              ShareParams(
                text: '🎬 ${video.title}\n\nWatch on Luy Money!',
                subject: video.title,
              ),
            ),
            ext: ext,
          ),

          // Download (coming soon)
          _ActionBtn(
            icon: Icons.download_outlined,
            label: 'Download',
            color: ext.textSecondary,
            onTap: () => Get.snackbar(
              'Coming Soon',
              'Download feature will be available soon.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: ext.surface,
              colorText: ext.textPrimary,
              margin: const EdgeInsets.all(12),
              borderRadius: 12,
              duration: const Duration(seconds: 2),
            ),
            ext: ext,
          ),

          // More
          _ActionBtn(
            icon: Icons.more_horiz_rounded,
            label: 'More',
            color: ext.textSecondary,
            onTap: onMore,
            ext: ext,
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final AppColorExtension ext;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.ext,
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
            Text(
              label,
              style: TextStyle(color: color, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── More Bottom Sheet ─────────────────────────────────────────────────────────
class _MoreSheet extends StatelessWidget {
  final VideoModel video;
  final AppColorExtension ext;
  const _MoreSheet({required this.video, required this.ext});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 32),
      decoration: BoxDecoration(
        color: ext.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ext.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Thumbnail + title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: video.thumbnailUrl.isNotEmpty
                    ? Image.network(
                        video.thumbnailUrl,
                        width: 80,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, err, st) => Container(
                          width: 80,
                          height: 50,
                          color: AppColors.gold.withValues(alpha: 0.2),
                          child: const Icon(Icons.play_circle_outline,
                              color: AppColors.gold),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: AppColors.goldGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.play_arrow_rounded,
                            color: Colors.black, size: 28),
                      ),
              ),
              const SizedBox(width: 12),
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
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video.durationFormatted,
                      style:
                          TextStyle(color: ext.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          Divider(color: ext.border, height: 1),
          const SizedBox(height: 8),

          _SheetTile(
            icon: Icons.share_outlined,
            iconColor: Colors.blue,
            title: 'Share Video',
            ext: ext,
            onTap: () {
              Get.back();
              SharePlus.instance.share(ShareParams(
                text: '🎬 ${video.title}\n\nWatch on Luy Money!',
                subject: video.title,
              ));
            },
          ),
          _SheetTile(
            icon: Icons.link_rounded,
            iconColor: Colors.teal,
            title: 'Copy Link',
            ext: ext,
            onTap: () {
              Get.back();
              Clipboard.setData(ClipboardData(text: video.videoUrl));
              Get.snackbar('Copied!', 'Video link copied to clipboard.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: ext.surface,
                  colorText: ext.textPrimary,
                  margin: const EdgeInsets.all(12),
                  borderRadius: 12,
                  icon: const Icon(Icons.check_circle_outline,
                      color: AppColors.gold),
                  duration: const Duration(seconds: 2));
            },
          ),
          _SheetTile(
            icon: Icons.playlist_add_rounded,
            iconColor: Colors.purple,
            title: 'Add to Playlist',
            ext: ext,
            onTap: () {
              Get.back();
              Get.snackbar('Coming Soon', 'Playlist feature will be available soon.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: ext.surface,
                  colorText: ext.textPrimary,
                  margin: const EdgeInsets.all(12),
                  borderRadius: 12,
                  duration: const Duration(seconds: 2));
            },
          ),
          _SheetTile(
            icon: Icons.download_outlined,
            iconColor: Colors.green,
            title: 'Download Video',
            ext: ext,
            onTap: () {
              Get.back();
              Get.snackbar('Coming Soon', 'Download feature will be available soon.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: ext.surface,
                  colorText: ext.textPrimary,
                  margin: const EdgeInsets.all(12),
                  borderRadius: 12,
                  duration: const Duration(seconds: 2));
            },
          ),
          _SheetTile(
            icon: Icons.open_in_browser_rounded,
            iconColor: Colors.orange,
            title: 'Open in YouTube',
            ext: ext,
            onTap: () {
              Get.back();
              Get.snackbar('Opening...', 'Launching YouTube.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: ext.surface,
                  colorText: ext.textPrimary,
                  margin: const EdgeInsets.all(12),
                  borderRadius: 12,
                  duration: const Duration(seconds: 2));
            },
          ),
          _SheetTile(
            icon: Icons.flag_outlined,
            iconColor: Colors.red,
            title: 'Report Video',
            ext: ext,
            onTap: () {
              Get.back();
              _showReportDialog(ext);
            },
          ),
        ],
      ),
    );
  }

  void _showReportDialog(AppColorExtension ext) {
    Get.dialog(
      AlertDialog(
        backgroundColor: ext.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Report Video',
            style: TextStyle(
                color: ext.textPrimary, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Why are you reporting this video?',
                style: TextStyle(color: ext.textSecondary, fontSize: 14)),
            const SizedBox(height: 16),
            ...[
              'Inappropriate content',
              'Spam or misleading',
              'Copyright violation',
              'Other',
            ].map((reason) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.radio_button_unchecked,
                      color: AppColors.gold, size: 20),
                  title: Text(reason,
                      style:
                          TextStyle(color: ext.textPrimary, fontSize: 14)),
                  onTap: () {
                    Get.back();
                    Get.snackbar('Report Sent', 'Thank you for your report.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: ext.surface,
                        colorText: ext.textPrimary,
                        margin: const EdgeInsets.all(12),
                        borderRadius: 12,
                        duration: const Duration(seconds: 2));
                  },
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final AppColorExtension ext;
  final VoidCallback onTap;

  const _SheetTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.ext,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: ext.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
