import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../data/models/banner_model.dart';
import '../../../data/models/content_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';

class HomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final StorageService _storage = Get.find<StorageService>();
  final _firestore = FirebaseFirestore.instance;

  final currentIndex   = 0.obs;
  final recentVideos   = <VideoModel>[].obs;
  final recentArticles = <ArticleModel>[].obs;
  final banners        = <BannerModel>[].obs;
  final isLoading      = false.obs;
  final totalVideos    = 0.obs;
  final totalArticles  = 0.obs;
  final totalTopics    = 0.obs;
  final unreadNotifications = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadRecentContent();
    loadUnreadNotifications();
  }

  Future<void> loadUnreadNotifications() async {
    try {
      final snap = await _firestore
          .collection('admin_notifications')
          .orderBy('sentAt', descending: true)
          .limit(100)
          .get();
      final readIds = _storage.readNotificationIds;
      var count = 0;
      for (final doc in snap.docs) {
        final target = doc.data()['target'] ?? 'all';
        final isRelevant = target == 'all' ||
            (target == 'active' && hasActiveSubscription) ||
            (target == 'expiring' && isExpiringSoon);
        if (isRelevant && !readIds.contains(doc.id)) count++;
      }
      unreadNotifications.value = count;
    } catch (e) {
      Get.log('Error loading unread notifications: $e');
    }
  }

  Future<void> loadRecentContent() async {
    isLoading.value = true;
    try {
      // Run all three queries in parallel instead of sequentially —
      // each has its own 10s timeout, so awaiting one-by-one could
      // make the home screen wait up to 30s in the worst case.
      final results = await Future.wait([
        _firestore
            .collection('videos')
            .orderBy('publishedAt', descending: true)
            .limit(5)
            .get()
            .timeout(const Duration(seconds: 10)),
        _firestore
            .collection('articles')
            .orderBy('publishedAt', descending: true)
            .limit(5)
            .get()
            .timeout(const Duration(seconds: 10)),
        _firestore
            .collection('categories')
            .get()
            .timeout(const Duration(seconds: 10)),
        _firestore
            .collection('banners')
            .orderBy('sortOrder')
            .get()
            .timeout(const Duration(seconds: 10)),
      ]);

      final videosSnap = results[0];
      recentVideos.value =
          videosSnap.docs.map((d) => VideoModel.fromFirestore(d)).toList();
      totalVideos.value = videosSnap.docs.length;

      final articlesSnap = results[1];
      recentArticles.value =
          articlesSnap.docs.map((d) => ArticleModel.fromFirestore(d)).toList();
      totalArticles.value = articlesSnap.docs.length;

      final catSnap = results[2];
      totalTopics.value = catSnap.docs.length;

      final bannersSnap = results[3];
      banners.value = bannersSnap.docs
          .map((d) => BannerModel.fromFirestore(d))
          .where((b) => b.isActive)
          .toList();
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
