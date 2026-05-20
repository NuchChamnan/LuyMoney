import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/video_card.dart';
import '../../../shared/widgets/category_chips.dart';
import '../controllers/content_controller.dart';

class VideosView extends GetView<ContentController> {
  const VideosView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('videos'.tr),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              onChanged: controller.onSearch,
              decoration: InputDecoration(
                hintText: 'search'.tr,
                prefixIcon: const Icon(Icons.search_rounded),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Obx(() => CategoryChips(
            categories: controller.categories,
            selectedCategory: controller.selectedCategory.value,
            onSelected: controller.filterByCategory,
          )),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingVideos.value && controller.videos.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                );
              }
              if (controller.videos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.video_library_outlined,
                          size: 64, color: AppColors.gold),
                      const SizedBox(height: 16),
                      Text('no_results'.tr,
                          style: theme.textTheme.titleMedium),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                itemCount: controller.videos.length +
                    (controller.hasMoreVideos.value ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == controller.videos.length) {
                    controller.loadVideos();
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.gold),
                      ),
                    );
                  }
                  final video = controller.videos[i];
                  return VideoCard(
                    video: video,
                    isBookmarked: controller.bookmarkedVideos.any((v) => v.id == video.id),
                    onBookmark: () => controller.toggleVideoBookmark(video.id),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
