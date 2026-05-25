import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../data/models/content_model.dart';
import '../../../services/auth_service.dart';

class HomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final _firestore = FirebaseFirestore.instance;

  final currentIndex   = 0.obs;
  final recentVideos   = <VideoModel>[].obs;
  final recentArticles = <ArticleModel>[].obs;
  final isLoading      = false.obs;
  final totalVideos    = 0.obs;
  final totalArticles  = 0.obs;
  final totalTopics    = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadRecentContent();
  }

  Future<void> loadRecentContent() async {
    isLoading.value = true;
    try {
      // Load recent videos
      final videosSnap = await _firestore
          .collection('videos')
          .orderBy('publishedAt', descending: true)
          .limit(5)
          .get()
          .timeout(const Duration(seconds: 10));
      recentVideos.value =
          videosSnap.docs.map((d) => VideoModel.fromFirestore(d)).toList();
      totalVideos.value = videosSnap.docs.length;

      // Load recent articles
      final articlesSnap = await _firestore
          .collection('articles')
          .orderBy('publishedAt', descending: true)
          .limit(5)
          .get()
          .timeout(const Duration(seconds: 10));
      recentArticles.value =
          articlesSnap.docs.map((d) => ArticleModel.fromFirestore(d)).toList();
      totalArticles.value = articlesSnap.docs.length;

      // Count categories
      final catSnap = await _firestore
          .collection('categories')
          .get()
          .timeout(const Duration(seconds: 10));
      totalTopics.value = catSnap.docs.length;
    } catch (e) {
      Get.log('Error loading home content: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) => currentIndex.value = index;
  void navigateTo(String route) => Get.toNamed(route);

  bool get hasActiveSubscription => _authService.hasActiveSubscription;
  bool get isExpiringSoon =>
      _authService.currentUser.value?.subscription?.isExpiringSoon ?? false;
  int get daysRemaining =>
      _authService.currentUser.value?.subscription?.daysRemaining ?? 0;
  String get userName =>
      _authService.currentUser.value?.name ??
      _authService.firebaseUser?.displayName ??
      '';
}
