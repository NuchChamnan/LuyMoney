import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/comment_model.dart';
import '../../../data/models/content_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';

class ContentController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storage = Get.find<StorageService>();
  final AuthService _authService = Get.find<AuthService>();

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

  // Comments (for the currently-viewed video or article)
  final comments = <CommentModel>[].obs;
  final commentController = TextEditingController();
  final isSendingComment = false.obs;
  String? _commentsKey;
  StreamSubscription<QuerySnapshot>? _commentsSub;

  @override
  void onInit() {
    super.onInit();
    _loadCategories();
    loadVideos(refresh: true);
    loadArticles(refresh: true);
    debounce(searchQuery, (_) => _applyFilters(),
        time: const Duration(milliseconds: 300));
  }

  @override
  void onClose() {
    _commentsSub?.cancel();
    commentController.dispose();
    super.onClose();
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
        return v.copyWith(
          isBookmarked: _storage.isVideoBookmarked(v.id),
          isLiked: _storage.isVideoLiked(v.id),
        );
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
        return a.copyWith(
          isBookmarked: _storage.isArticleBookmarked(a.id),
          isLiked: _storage.isArticleLiked(a.id),
          isPinned: _storage.isArticlePinned(a.id),
        );
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
    // Pinned articles surface at the top, newest-first within each group.
    list.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.publishedAt.compareTo(a.publishedAt);
    });
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

  // ── Likes ──────────────────────────────────────────────────────────────────
  Future<void> toggleVideoLike(String id) async {
    await _storage.toggleVideoLike(id);
    final i = _allVideos.indexWhere((v) => v.id == id);
    if (i != -1) {
      _allVideos[i] =
          _allVideos[i].copyWith(isLiked: _storage.isVideoLiked(id));
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

  Future<void> toggleArticleLike(String id) async {
    await _storage.toggleArticleLike(id);
    final i = _allArticles.indexWhere((a) => a.id == id);
    if (i != -1) {
      _allArticles[i] =
          _allArticles[i].copyWith(isLiked: _storage.isArticleLiked(id));
      _applyArticleFilter();
    }
  }

  // ── Pin (kept locally — surfaces the post at the top of the list) ──────────
  Future<void> toggleArticlePinned(String id) async {
    await _storage.toggleArticlePinned(id);
    final i = _allArticles.indexWhere((a) => a.id == id);
    if (i != -1) {
      _allArticles[i] =
          _allArticles[i].copyWith(isPinned: _storage.isArticlePinned(id));
      _applyArticleFilter();
    }
  }

  List<VideoModel>   get bookmarkedVideos   =>
      _allVideos.where((v) => v.isBookmarked).toList();
  List<ArticleModel> get bookmarkedArticles =>
      _allArticles.where((a) => a.isBookmarked).toList();

  // ── View count ─────────────────────────────────────────────────────────────
  Future<void> incrementViewCount(String videoId) async {
    try {
      await _firestore.collection('videos').doc(videoId).update({
        'viewCount': FieldValue.increment(1),
      });
      // Optimistic local update so the UI reflects the new count immediately.
      final i = _allVideos.indexWhere((v) => v.id == videoId);
      if (i != -1) {
        _allVideos[i] =
            _allVideos[i].copyWith(viewCount: _allVideos[i].viewCount + 1);
        _applyVideoFilter();
      }
    } catch (e) {
      Get.log('Error incrementing view count: $e');
    }
  }

  // ── Comments (shared between videos and articles) ───────────────────────────
  // [parentCollection] is 'videos' or 'articles'.
  void listenToComments(String parentCollection, String docId) {
    final key = '$parentCollection/$docId';
    if (_commentsKey == key) return;
    _commentsKey = key;
    _commentsSub?.cancel();
    comments.clear();
    _commentsSub = _firestore
        .collection(parentCollection)
        .doc(docId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .listen((snap) {
      comments.value =
          snap.docs.map((d) => CommentModel.fromFirestore(d)).toList();
    });
  }

  Future<void> addComment(String parentCollection, String docId) async {
    final text = commentController.text.trim();
    final userId = _authService.firebaseUser?.uid;
    if (text.isEmpty || userId == null || isSendingComment.value) return;

    isSendingComment.value = true;
    commentController.clear();
    try {
      final user = _authService.currentUser.value;
      final comment = CommentModel(
        id: '',
        userId: userId,
        userName: user?.name ?? 'User',
        userAvatarUrl: user?.avatarUrl,
        text: text,
        createdAt: DateTime.now(),
      );
      await _firestore
          .collection(parentCollection)
          .doc(docId)
          .collection('comments')
          .add(comment.toMap());
    } catch (e) {
      Get.snackbar('Error', 'Failed to post comment',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSendingComment.value = false;
    }
  }

  Future<void> deleteComment(
      String parentCollection, String docId, String commentId) async {
    await _firestore
        .collection(parentCollection)
        .doc(docId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }

  bool canDeleteComment(CommentModel comment) {
    final userId = _authService.firebaseUser?.uid;
    return userId != null &&
        (comment.userId == userId || _authService.isAdmin);
  }
}
