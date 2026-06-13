import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../data/models/comment_model.dart';
import '../../../data/models/content_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
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
      return _YoutubeVideoDetail(video: video);
    }

    return Scaffold(
      appBar: AppBar(title: Text(video.title)),
      body: const Center(child: Text('Video player not available')),
    );
  }
}

// ── YouTube player wrapper (owns the controller lifecycle) ───────────────────
class _YoutubeVideoDetail extends StatefulWidget {
  final VideoModel video;
  const _YoutubeVideoDetail({required this.video});

  @override
  State<_YoutubeVideoDetail> createState() => _YoutubeVideoDetailState();
}

class _YoutubeVideoDetailState extends State<_YoutubeVideoDetail> {
  late YoutubePlayerController _ytController;
  late VideoModel _currentVideo;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentVideo = widget.video;
    _ytController = YoutubePlayerController(
      initialVideoId: _currentVideo.youtubeVideoId,
      flags: const YoutubePlayerFlags(autoPlay: true),
    );
    Get.find<ContentController>().listenToComments(_currentVideo.id);
  }

  @override
  void dispose() {
    _ytController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Switch to another video in-place, reusing the same player/WebView
  // instead of pushing a new route (creating a new WebView per "More
  // Videos" tap breaks playback after a couple of navigations).
  void _selectVideo(VideoModel video) {
    if (video.hostType != VideoHostType.youtube) {
      Get.off(() => const VideoDetailView(), arguments: video);
      return;
    }
    setState(() => _currentVideo = video);
    _ytController.load(video.youtubeVideoId);
    Get.find<ContentController>().listenToComments(video.id);
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(controller: _ytController),
      builder: (ctx, player) => _VideoDetailScaffold(
        video: _currentVideo,
        player: player,
        scrollController: _scrollController,
        onSelectVideo: _selectVideo,
      ),
    );
  }
}

// ── Main Scaffold ─────────────────────────────────────────────────────────────
class _VideoDetailScaffold extends StatefulWidget {
  final VideoModel video;
  final Widget player;
  final ScrollController scrollController;
  final ValueChanged<VideoModel> onSelectVideo;
  const _VideoDetailScaffold({
    required this.video,
    required this.player,
    required this.scrollController,
    required this.onSelectVideo,
  });

  @override
  State<_VideoDetailScaffold> createState() => _VideoDetailScaffoldState();
}

class _VideoDetailScaffoldState extends State<_VideoDetailScaffold> {
  bool _descExpanded = false;
  late String _selectedCategory; // for the filter bar below

  @override
  void initState() {
    super.initState();
    // Default: show all videos (not filtered)
    _selectedCategory = 'all';
  }

  @override
  void didUpdateWidget(covariant _VideoDetailScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video.id != widget.video.id) {
      setState(() => _descExpanded = false);
    }
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
              controller: widget.scrollController,
              slivers: [
                // Description (below player, before title)
                if (widget.video.description.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _DescriptionSection(
                      video: widget.video,
                      ext: ext,
                      expanded: _descExpanded,
                      onToggle: () =>
                          setState(() => _descExpanded = !_descExpanded),
                    ),
                  ),
                  SliverToBoxAdapter(
                      child: Divider(height: 1, color: ext.border)),
                ],

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
                    onMore: () => _showMoreSheet(context, ext),
                  ),
                ),

                SliverToBoxAdapter(child: Divider(height: 1, color: ext.border)),

                // ── Comments section ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
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
                        'Comments',
                        style: TextStyle(
                          color: ext.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Obx(() => Text(
                            '(${ctrl.comments.length})',
                            style: TextStyle(
                              color: ext.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                    ]),
                  ),
                ),

                SliverToBoxAdapter(
                  child: _CommentInput(video: widget.video, ext: ext, ctrl: ctrl),
                ),

                Obx(() {
                  if (ctrl.comments.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'No comments yet',
                            style:
                                TextStyle(color: ext.textSecondary, fontSize: 14),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _CommentTile(
                          comment: ctrl.comments[i],
                          ext: ext,
                          canDelete: ctrl.canDeleteComment(ctrl.comments[i]),
                          onDelete: () => ctrl.deleteComment(
                              widget.video.id, ctrl.comments[i].id),
                        ),
                        childCount: ctrl.comments.length,
                      ),
                    ),
                  );
                }),

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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: VideoCard(
                            video: filtered[i],
                            showChannelInfo: false,
                            onTap: () {
                              final auth = Get.find<AuthService>();
                              if (filtered[i].isPremium &&
                                  !auth.hasActiveSubscription) {
                                Get.toNamed(Routes.SUBSCRIPTION);
                              } else {
                                widget.onSelectVideo(filtered[i]);
                              }
                            },
                            onBookmark: () =>
                                ctrl.toggleVideoBookmark(filtered[i].id),
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
    if (video.description.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
      ),
    );
  }
}

// ── Action Bar ────────────────────────────────────────────────────────────────
class _ActionBar extends StatelessWidget {
  final VideoModel video;
  final AppColorExtension ext;
  final VoidCallback onMore;

  const _ActionBar({
    required this.video,
    required this.ext,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Like
          Obx(() {
            final ctrl = Get.find<ContentController>();
            final isLiked =
                ctrl.videos
                    .firstWhereOrNull((v) => v.id == video.id)
                    ?.isLiked ??
                    video.isLiked;
            final likeCount = video.viewCount ~/ 10 + (isLiked ? 1 : 0);
            return _ActionBtn(
              icon: isLiked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
              label: likeCount > 0 ? likeCount.toString() : 'Like',
              color: isLiked ? AppColors.gold : ext.textSecondary,
              onTap: () => ctrl.toggleVideoLike(video.id),
              ext: ext,
            );
          }),

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

// ── Comment Input ─────────────────────────────────────────────────────────────
class _CommentInput extends StatelessWidget {
  final VideoModel video;
  final AppColorExtension ext;
  final ContentController ctrl;

  const _CommentInput({
    required this.video,
    required this.ext,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    final user = Get.find<AuthService>().currentUser.value;
    final hasAvatar = user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.gold.withValues(alpha: 0.2),
            backgroundImage: hasAvatar ? NetworkImage(user.avatarUrl!) : null,
            child: hasAvatar
                ? null
                : Text(
                    (user?.name.isNotEmpty == true
                            ? user!.name[0]
                            : '?')
                        .toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: ctrl.commentController,
              minLines: 1,
              maxLines: 4,
              style: TextStyle(color: ext.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: TextStyle(color: ext.textSecondary, fontSize: 14),
                filled: true,
                fillColor: ext.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: ext.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: ext.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppColors.gold),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => ctrl.isSendingComment.value
              ? const SizedBox(
                  width: 36,
                  height: 36,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.gold),
                  ),
                )
              : GestureDetector(
                  onTap: () => ctrl.addComment(video.id),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      gradient: AppColors.goldGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.black, size: 18),
                  ),
                )),
        ],
      ),
    );
  }
}

// ── Comment Tile ──────────────────────────────────────────────────────────────
class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  final AppColorExtension ext;
  final bool canDelete;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.comment,
    required this.ext,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar =
        comment.userAvatarUrl != null && comment.userAvatarUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.gold.withValues(alpha: 0.2),
            backgroundImage:
                hasAvatar ? NetworkImage(comment.userAvatarUrl!) : null,
            child: hasAvatar
                ? null
                : Text(
                    comment.userName.isNotEmpty
                        ? comment.userName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(
                      comment.userName,
                      style: TextStyle(
                        color: ext.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatRelativeTime(comment.createdAt),
                    style: TextStyle(color: ext.textSecondary, fontSize: 11),
                  ),
                  if (canDelete) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDelete,
                      child: Icon(Icons.delete_outline_rounded,
                          size: 16, color: ext.textSecondary),
                    ),
                  ],
                ]),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: TextStyle(
                      color: ext.textSecondary, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatRelativeTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${dt.month}/${dt.day}/${dt.year}';
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
