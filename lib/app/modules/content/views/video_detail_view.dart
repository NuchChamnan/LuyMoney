import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../data/models/content_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../controllers/content_controller.dart';

class VideoDetailView extends GetView<ContentController> {
  const VideoDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final VideoModel video = Get.arguments as VideoModel;
    final theme = Theme.of(context);

    if (video.hostType == VideoHostType.youtube) {
      final ytController = YoutubePlayerController(
        initialVideoId: video.youtubeVideoId,
        flags: const YoutubePlayerFlags(autoPlay: true),
      );

      return YoutubePlayerBuilder(
        player: YoutubePlayer(controller: ytController),
        builder: (context, player) => Scaffold(
          appBar: AppBar(title: Text(video.title, maxLines: 1)),
          body: Column(
            children: [
              player,
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(video.title,
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.visibility_outlined,
                              size: 16,
                              color: theme.colorScheme.onSurface.withOpacity(0.5)),
                          const SizedBox(width: 4),
                          Text('${video.viewCount} views',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5))),
                          const SizedBox(width: 16),
                          const Icon(Icons.timer_outlined,
                              size: 16, color: AppColors.gold),
                          const SizedBox(width: 4),
                          Text(video.durationFormatted,
                              style: const TextStyle(
                                  color: AppColors.gold, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(video.category.capitalize!,
                            style: const TextStyle(
                                color: AppColors.gold, fontSize: 12)),
                      ),
                      const SizedBox(height: 16),
                      Text(video.description, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(video.title)),
      body: const Center(child: Text('Video player not available')),
    );
  }
}
