import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/video_card.dart';
import '../controllers/content_controller.dart';

class SavedVideosView extends GetView<ContentController> {
  const SavedVideosView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('saved_videos'.tr)),
      body: Obx(() {
        final saved = controller.bookmarkedVideos;
        if (saved.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bookmark_border_rounded,
                    size: 64, color: AppColors.gold),
                const SizedBox(height: 16),
                Text('no_results'.tr, style: theme.textTheme.titleMedium),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          itemCount: saved.length,
          itemBuilder: (_, i) {
            final video = saved[i];
            return VideoCard(
              video: video,
              isBookmarked: true,
              onBookmark: () => controller.toggleVideoBookmark(video.id),
              onTap: () {
                final auth = Get.find<AuthService>();
                if (video.isPremium && !auth.hasActiveSubscription) {
                  Get.toNamed(Routes.SUBSCRIPTION);
                } else {
                  Get.toNamed(Routes.VIDEO_DETAIL, arguments: video);
                }
              },
            );
          },
        );
      }),
    );
  }
}
