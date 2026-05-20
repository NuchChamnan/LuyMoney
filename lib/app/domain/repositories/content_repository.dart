import '../../data/models/content_model.dart';

abstract class ContentRepository {
  Future<List<VideoModel>> getVideos({
    int limit = 10,
    VideoModel? lastVideo,
    String? category,
    String? query,
  });

  Future<List<ArticleModel>> getArticles({
    int limit = 10,
    ArticleModel? lastArticle,
    String? category,
    String? query,
  });

  Future<VideoModel?> getVideoById(String id);
  Future<ArticleModel?> getArticleById(String id);

  Future<void> incrementVideoView(String id);
  Future<void> createVideo(VideoModel video);
  Future<void> updateVideo(VideoModel video);
  Future<void> deleteVideo(String id);

  Future<void> createArticle(ArticleModel article);
  Future<void> updateArticle(ArticleModel article);
  Future<void> deleteArticle(String id);

  Future<List<VideoModel>> getBookmarkedVideos(List<String> ids);
  Future<List<ArticleModel>> getBookmarkedArticles(List<String> ids);
}
