import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../data/models/content_model.dart';
import '../../../services/storage_service.dart';

class ContentController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storage = Get.find<StorageService>();

  // All data (unfiltered)
  final _allVideos   = <VideoModel>[].obs;
  final _allArticles = <ArticleModel>[].obs;

  // Displayed (filtered)
  final videos   = <VideoModel>[].obs;
  final articles = <ArticleModel>[].obs;

  final isLoadingVideos   = false.obs;
  final isLoadingArticles = false.obs;
  final searchQuery       = ''.obs;
  final selectedCategory  = 'all'.obs;
  final categories        = <String>['all'].obs;

  final hasMoreVideos   = false.obs;
  final hasMoreArticles = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCategories();
    loadVideos(refresh: true);
    loadArticles(refresh: true);
    debounce(searchQuery, (_) => _applyFilters(),
        time: const Duration(milliseconds: 300));
  }

  Future<void> _loadCategories() async {
    try {
      final snap = await _firestore
          .collection('categories')
          .get()
          .timeout(const Duration(seconds: 10));
      final remote = snap.docs
          .map((d) => (d.data()['name'] as String? ?? '').toLowerCase())
          .where((s) => s.isNotEmpty)
          .toList();
      if (remote.isNotEmpty) {
        categories.value = ['all', ...remote];
      } else {
        // Default fallback
        categories.value = [
          'all', 'finance', 'investment', 'mindset',
          'trading', 'savings', 'business',
        ];
      }
    } catch (e) {
      categories.value = [
        'all', 'finance', 'investment', 'mindset',
        'trading', 'savings', 'business',
      ];
    }
  }

  // ── Load from Firestore (simple orderBy only — no composite index needed) ──
  Future<void> loadVideos({bool refresh = false}) async {
    isLoadingVideos.value = true;
    try {
      final snap = await _firestore
          .collection('videos')
          .orderBy('publishedAt', descending: true)
          .limit(100)
          .get()
          .timeout(const Duration(seconds: 10));

      _allVideos.value = snap.docs.map((d) {
        final v = VideoModel.fromFirestore(d);
        return v.copyWith(isBookmarked: _storage.isVideoBookmarked(v.id));
      }).toList();

      _applyVideoFilter();
    } catch (e) {
      Get.log('Error loading videos: $e');
    } finally {
      isLoadingVideos.value = false;
    }
  }

  Future<void> loadArticles({bool refresh = false}) async {
    isLoadingArticles.value = true;
    try {
      final snap = await _firestore
          .collection('articles')
          .orderBy('publishedAt', descending: true)
          .limit(100)
          .get()
          .timeout(const Duration(seconds: 10));

      _allArticles.value = snap.docs.map((d) {
        final a = ArticleModel.fromFirestore(d);
        return a.copyWith(isBookmarked: _storage.isArticleBookmarked(a.id));
      }).toList();

      _applyArticleFilter();
    } catch (e) {
      Get.log('Error loading articles: $e');
    } finally {
      isLoadingArticles.value = false;
    }
  }

  // ── Client-side filter (category + search) ────────────────────────────────
  void _applyFilters() {
    _applyVideoFilter();
    _applyArticleFilter();
  }

  void _applyVideoFilter() {
    var list = _allVideos.toList();
    if (selectedCategory.value != 'all') {
      list = list
          .where((v) =>
              v.category.toLowerCase() ==
              selectedCategory.value.toLowerCase())
          .toList();
    }
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list
          .where((v) =>
              v.title.toLowerCase().contains(q) ||
              v.category.toLowerCase().contains(q))
          .toList();
    }
    videos.value = list;
  }

  void _applyArticleFilter() {
    var list = _allArticles.toList();
    if (selectedCategory.value != 'all') {
      list = list
          .where((a) =>
              a.category.toLowerCase() ==
              selectedCategory.value.toLowerCase())
          .toList();
    }
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list
          .where((a) =>
              a.title.toLowerCase().contains(q) ||
              a.category.toLowerCase().contains(q) ||
              a.excerpt.toLowerCase().contains(q))
          .toList();
    }
    articles.value = list;
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  void onSearch(String query) {
    searchQuery.value = query;
  }

  // ── Bookmarks ──────────────────────────────────────────────────────────────
  Future<void> toggleVideoBookmark(String id) async {
    await _storage.toggleVideoBookmark(id);
    final i = _allVideos.indexWhere((v) => v.id == id);
    if (i != -1) {
      _allVideos[i] = _allVideos[i].copyWith(
          isBookmarked: _storage.isVideoBookmarked(id));
      _applyVideoFilter();
    }
  }

  Future<void> toggleArticleBookmark(String id) async {
    await _storage.toggleArticleBookmark(id);
    final i = _allArticles.indexWhere((a) => a.id == id);
    if (i != -1) {
      _allArticles[i] = _allArticles[i].copyWith(
          isBookmarked: _storage.isArticleBookmarked(id));
      _applyArticleFilter();
    }
  }

  List<VideoModel>   get bookmarkedVideos   =>
      _allVideos.where((v) => v.isBookmarked).toList();
  List<ArticleModel> get bookmarkedArticles =>
      _allArticles.where((a) => a.isBookmarked).toList();
}
