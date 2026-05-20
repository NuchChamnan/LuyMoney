import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/content_model.dart';
import '../../domain/repositories/content_repository.dart';

class ContentRepositoryImpl implements ContentRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Videos ─────────────────────────────────────────────────────────────────
  @override
  Future<List<VideoModel>> getVideos({
    int limit = 10,
    VideoModel? lastVideo,
    String? category,
    String? query,
  }) async {
    Query q = _db
        .collection('videos')
        .orderBy('publishedAt', descending: true)
        .limit(limit);

    if (category != null && category != 'All') {
      q = q.where('category', isEqualTo: category);
    }

    if (lastVideo != null) {
      final lastDoc = await _db.collection('videos').doc(lastVideo.id).get();
      q = q.startAfterDocument(lastDoc);
    }

    final snap = await q.get();
    var videos = snap.docs.map(VideoModel.fromFirestore).toList();

    if (query != null && query.isNotEmpty) {
      final lower = query.toLowerCase();
      videos = videos.where((v) {
        return v.title.toLowerCase().contains(lower) ||
            v.description.toLowerCase().contains(lower) ||
            v.category.toLowerCase().contains(lower);
      }).toList();
    }

    return videos;
  }

  @override
  Future<VideoModel?> getVideoById(String id) async {
    final doc = await _db.collection('videos').doc(id).get();
    if (!doc.exists) return null;
    return VideoModel.fromFirestore(doc);
  }

  @override
  Future<void> incrementVideoView(String id) async {
    await _db.collection('videos').doc(id).update({
      'viewCount': FieldValue.increment(1),
    });
  }

  @override
  Future<void> createVideo(VideoModel video) async {
    await _db.collection('videos').doc(video.id).set(video.toFirestore());
  }

  @override
  Future<void> updateVideo(VideoModel video) async {
    await _db.collection('videos').doc(video.id).update(video.toFirestore());
  }

  @override
  Future<void> deleteVideo(String id) async {
    await _db.collection('videos').doc(id).delete();
  }

  @override
  Future<List<VideoModel>> getBookmarkedVideos(List<String> ids) async {
    if (ids.isEmpty) return [];
    final futures = ids.map((id) => getVideoById(id));
    final results = await Future.wait(futures);
    return results.whereType<VideoModel>().toList();
  }

  // ── Articles ────────────────────────────────────────────────────────────────
  @override
  Future<List<ArticleModel>> getArticles({
    int limit = 10,
    ArticleModel? lastArticle,
    String? category,
    String? query,
  }) async {
    Query q = _db
        .collection('articles')
        .orderBy('publishedAt', descending: true)
        .limit(limit);

    if (category != null && category != 'All') {
      q = q.where('category', isEqualTo: category);
    }

    if (lastArticle != null) {
      final lastDoc =
          await _db.collection('articles').doc(lastArticle.id).get();
      q = q.startAfterDocument(lastDoc);
    }

    final snap = await q.get();
    var articles = snap.docs.map(ArticleModel.fromFirestore).toList();

    if (query != null && query.isNotEmpty) {
      final lower = query.toLowerCase();
      articles = articles.where((a) {
        return a.title.toLowerCase().contains(lower) ||
            a.excerpt.toLowerCase().contains(lower) ||
            a.category.toLowerCase().contains(lower);
      }).toList();
    }

    return articles;
  }

  @override
  Future<ArticleModel?> getArticleById(String id) async {
    final doc = await _db.collection('articles').doc(id).get();
    if (!doc.exists) return null;
    return ArticleModel.fromFirestore(doc);
  }

  @override
  Future<void> createArticle(ArticleModel article) async {
    await _db
        .collection('articles')
        .doc(article.id)
        .set(article.toFirestore());
  }

  @override
  Future<void> updateArticle(ArticleModel article) async {
    await _db
        .collection('articles')
        .doc(article.id)
        .update(article.toFirestore());
  }

  @override
  Future<void> deleteArticle(String id) async {
    await _db.collection('articles').doc(id).delete();
  }

  @override
  Future<List<ArticleModel>> getBookmarkedArticles(List<String> ids) async {
    if (ids.isEmpty) return [];
    final futures = ids.map((id) => getArticleById(id));
    final results = await Future.wait(futures);
    return results.whereType<ArticleModel>().toList();
  }
}
