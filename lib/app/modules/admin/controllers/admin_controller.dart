import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/banner_model.dart';
import '../../../data/models/content_model.dart';
import '../../../data/models/subscription_model.dart';
import '../../../data/models/chat_model.dart';
import '../../../shared/utils/app_utils.dart';

class AdminController extends GetxController {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();

  // ── Tab ─────────────────────────────────────────────────────────────────────
  final currentTab = 0.obs;

  // ── Users ────────────────────────────────────────────────────────────────────
  final users = <UserModel>[].obs;
  final userSearch = ''.obs;
  final isLoadingUsers = false.obs;
  final userStatusFilter = 'all'.obs; // all | active | expired | free

  // ── Content ──────────────────────────────────────────────────────────────────
  final videos = <VideoModel>[].obs;
  final articles = <ArticleModel>[].obs;
  final isLoadingContent = false.obs;
  final contentTab = 0.obs; // 0=videos, 1=articles

  // ── Categories ───────────────────────────────────────────────────────────────
  final categories = <String>[
    'finance', 'investment', 'mindset', 'trading', 'savings', 'business',
  ].obs;

  // ── Banners ──────────────────────────────────────────────────────────────────
  final banners = <BannerModel>[].obs;
  final isLoadingBanners = false.obs;
  final isUploadingBannerImage = false.obs;

  // ── Analytics ────────────────────────────────────────────────────────────────
  final totalUsers = 0.obs;
  final activeUsers = 0.obs;
  final expiredUsers = 0.obs;
  final freeUsers = 0.obs;
  final monthlyRevenue = 0.0.obs;
  final totalRevenue = 0.0.obs;
  final isLoadingAnalytics = false.obs;
  final revenueData = <Map<String, dynamic>>[].obs;

  // ── Notification ─────────────────────────────────────────────────────────────
  final notifTitle = ''.obs;
  final notifBody = ''.obs;
  final notifTarget = 'all'.obs;

  // ── Support Chats ─────────────────────────────────────────────────────────────
  final adminChats = <Map<String, dynamic>>[].obs;
  final isLoadingChats = false.obs;
  final selectedChatUserId = ''.obs;
  final selectedChatUserName = ''.obs;
  final selectedChatMessages = <ChatModel>[].obs;
  final isSendingReply = false.obs;
  final adminReplyController = TextEditingController();

  // ── Form controllers ─────────────────────────────────────────────────────────
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
    fetchAnalytics();
    fetchContent();
    fetchAdminChats();
    fetchCategories();
    fetchBanners();
    debounce(userSearch, (_) => fetchUsers(), time: const Duration(milliseconds: 400));
  }

  @override
  void onClose() {
    adminReplyController.dispose();
    super.onClose();
  }

  // ── Users ─────────────────────────────────────────────────────────────────
  Future<void> fetchUsers() async {
    isLoadingUsers.value = true;
    try {
      Query query = _db.collection('users').orderBy('createdAt', descending: true);

      if (userSearch.value.isNotEmpty) {
        // Simple client-side filter (Firestore doesn't support LIKE)
      }

      final snap = await query.limit(50).get();
      var list = snap.docs.map((d) => UserModel.fromFirestore(d)).toList();

      // Attach subscription data
      list = await Future.wait(list.map((u) async {
        final subSnap = await _db
            .collection('subscriptions')
            .where('userId', isEqualTo: u.id)
            .where('isActive', isEqualTo: true)
            .limit(1)
            .get();

        SubscriptionModel? sub;
        if (subSnap.docs.isNotEmpty) {
          sub = SubscriptionModel.fromFirestore(subSnap.docs.first);
        }
        return u.copyWith(subscription: sub);
      }));

      // Filter
      if (userSearch.value.isNotEmpty) {
        final q = userSearch.value.toLowerCase();
        list = list.where((u) {
          return u.name.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q);
        }).toList();
      }

      if (userStatusFilter.value == 'active') {
        list = list
            .where((u) => u.subscription != null && !u.subscription!.isExpired)
            .toList();
      } else if (userStatusFilter.value == 'expired') {
        list = list
            .where((u) => u.subscription != null && u.subscription!.isExpired)
            .toList();
      } else if (userStatusFilter.value == 'free') {
        list = list.where((u) => u.subscription == null).toList();
      }

      users.value = list;
    } catch (e) {
      AppSnackbar.error('Failed to load users: $e');
    } finally {
      isLoadingUsers.value = false;
    }
  }

  Future<void> extendUserSubscription(UserModel user, int days) async {
    try {
      final subSnap = await _db
          .collection('subscriptions')
          .where('userId', isEqualTo: user.id)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (subSnap.docs.isEmpty) {
        // Create new subscription
        final now = DateTime.now();
        await _db.collection('subscriptions').add({
          'userId': user.id,
          'planId': 'admin_grant',
          'startDate': Timestamp.fromDate(now),
          'expiryDate': Timestamp.fromDate(now.add(Duration(days: days))),
          'isActive': true,
          'paymentMethod': 'admin',
          'transactionId': 'admin_${DateTime.now().millisecondsSinceEpoch}',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        final doc = subSnap.docs.first;
        final currentExpiry = (doc['expiryDate'] as Timestamp).toDate();
        final newExpiry = currentExpiry.add(Duration(days: days));
        await doc.reference.update({
          'expiryDate': Timestamp.fromDate(newExpiry),
        });
      }

      AppSnackbar.success('Subscription extended by $days days');
      await fetchUsers();
    } catch (e) {
      AppSnackbar.error('Error: $e');
    }
  }

  Future<void> deactivateUser(UserModel user) async {
    try {
      await _db.collection('users').doc(user.id).update({'isActive': false});
      AppSnackbar.success('User deactivated');
      await fetchUsers();
    } catch (e) {
      AppSnackbar.error('Error: $e');
    }
  }

  Future<void> deleteUser(UserModel user) async {
    try {
      await _db.collection('users').doc(user.id).delete();
      AppSnackbar.success('User deleted');
      await fetchUsers();
    } catch (e) {
      AppSnackbar.error('Error: $e');
    }
  }

  Future<void> promoteToAdmin(UserModel user) async {
    try {
      await _db.collection('users').doc(user.id).update({'role': 'admin'});
      AppSnackbar.success('${user.name} is now an Admin 👑');
      await fetchUsers();
    } catch (e) {
      AppSnackbar.error('Error: $e');
    }
  }

  Future<void> demoteFromAdmin(UserModel user) async {
    try {
      await _db.collection('users').doc(user.id).update({'role': 'user'});
      AppSnackbar.success('${user.name} is now a regular User');
      await fetchUsers();
    } catch (e) {
      AppSnackbar.error('Error: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      AppSnackbar.success('Password reset email sent to $email');
    } catch (e) {
      AppSnackbar.error('Failed to send reset email: $e');
    }
  }

  // ── Analytics ──────────────────────────────────────────────────────────────
  Future<void> fetchAnalytics() async {
    isLoadingAnalytics.value = true;
    try {
      final usersSnap = await _db.collection('users').get();
      totalUsers.value = usersSnap.docs.length;

      final subsSnap = await _db
          .collection('subscriptions')
          .where('isActive', isEqualTo: true)
          .get();

      int active = 0, expired = 0;
      double revenue = 0;

      for (final doc in subsSnap.docs) {
        final data = doc.data();
        final expiry = (data['expiryDate'] as Timestamp).toDate();
        if (DateTime.now().isAfter(expiry)) {
          expired++;
        } else {
          active++;
        }
      }

      // Revenue (from all-time subscriptions)
      final allSubsSnap = await _db.collection('subscriptions').get();
      for (final doc in allSubsSnap.docs) {
        final planId = doc.data()['planId'] as String? ?? '';
        revenue += _planPrice(planId);
      }

      activeUsers.value = active;
      expiredUsers.value = expired;
      freeUsers.value = totalUsers.value - subsSnap.docs.length;
      totalRevenue.value = revenue;

      // Monthly revenue (current month)
      final startOfMonth = DateTime(
          DateTime.now().year, DateTime.now().month, 1);
      final monthSnap = await _db
          .collection('subscriptions')
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .get();

      double monthly = 0;
      for (final doc in monthSnap.docs) {
        monthly += _planPrice(doc.data()['planId'] as String? ?? '');
      }
      monthlyRevenue.value = monthly;

      // Build revenue chart data (last 6 months)
      _buildRevenueChartData(allSubsSnap.docs);
    } catch (e) {
      AppSnackbar.error('Failed to load analytics: $e');
    } finally {
      isLoadingAnalytics.value = false;
    }
  }

  void _buildRevenueChartData(List<QueryDocumentSnapshot> docs) {
    final now = DateTime.now();
    final months = <String, double>{};

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final key = '${month.year}-${month.month.toString().padLeft(2, '0')}';
      months[key] = 0;
    }

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt = data['createdAt'];
      if (createdAt == null) continue;
      final date = (createdAt as Timestamp).toDate();
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      if (months.containsKey(key)) {
        months[key] = (months[key] ?? 0) + _planPrice(data['planId'] as String? ?? '');
      }
    }

    revenueData.value = months.entries
        .map((e) => {'month': e.key, 'revenue': e.value})
        .toList();
  }

  double _planPrice(String planId) {
    switch (planId) {
      case 'monthly': return 5.0;
      case 'quarterly': return 12.0;
      case 'biannual': return 20.0;
      case 'annual': return 35.0;
      default: return 0.0;
    }
  }

  // ── Content ────────────────────────────────────────────────────────────────
  Future<void> fetchContent() async {
    isLoadingContent.value = true;
    try {
      final videosSnap = await _db
          .collection('videos')
          .orderBy('publishedAt', descending: true)
          .limit(30)
          .get();
      videos.value = videosSnap.docs.map(VideoModel.fromFirestore).toList();

      final articlesSnap = await _db
          .collection('articles')
          .orderBy('publishedAt', descending: true)
          .limit(30)
          .get();
      articles.value = articlesSnap.docs.map(ArticleModel.fromFirestore).toList();
    } catch (e) {
      AppSnackbar.error('Failed to load content: $e');
    } finally {
      isLoadingContent.value = false;
    }
  }

  Future<void> addVideo({
    required String title,
    required String videoUrl,
    required String category,
    required String description,
  }) async {
    if (title.isEmpty || videoUrl.isEmpty) {
      AppSnackbar.error('Title and Video URL are required');
      return;
    }
    isLoading.value = true;
    try {
      await _db.collection('videos').add({
        'title': title,
        'description': description,
        'videoUrl': videoUrl,
        'thumbnailUrl': '',
        'hostType': 'youtube',
        'category': (category.isEmpty ? 'finance' : category).toLowerCase(),
        'isPremium': true,
        'viewCount': 0,
        'durationSeconds': 0,
        'publishedAt': Timestamp.fromDate(DateTime.now()),
        'createdAt': FieldValue.serverTimestamp(),
      });
      await fetchContent();
      AppSnackbar.success('Video added successfully');
    } catch (e) {
      AppSnackbar.error('Failed to add video: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addArticle({
    required String title,
    required String coverImageUrl,
    required String category,
    required String description,
  }) async {
    if (title.isEmpty) {
      AppSnackbar.error('Title is required');
      return;
    }
    isLoading.value = true;
    try {
      await _db.collection('articles').add({
        'title': title,
        'excerpt': description.length > 100 ? '${description.substring(0, 100)}...' : description,
        'content': description,
        'coverImageUrl': coverImageUrl,
        'authorName': 'Luy Money',
        'category': (category.isEmpty ? 'finance' : category).toLowerCase(),
        'isPremium': true,
        'viewCount': 0,
        'readTimeMinutes': 5,
        'publishedAt': Timestamp.fromDate(DateTime.now()),
        'createdAt': FieldValue.serverTimestamp(),
      });
      await fetchContent();
      AppSnackbar.success('Article added successfully');
    } catch (e) {
      AppSnackbar.error('Failed to add article: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Categories ─────────────────────────────────────────────────────────────
  Future<void> fetchCategories() async {
    try {
      final snap = await _db.collection('categories').get();
      if (snap.docs.isNotEmpty) {
        final remote = snap.docs
            .map((d) => (d.data()['name'] as String? ?? '').toLowerCase())
            .where((s) => s.isNotEmpty)
            .toList();
        for (final c in remote) {
          if (!categories.contains(c)) categories.add(c);
        }
      } else {
        // First time: seed default categories to Firestore
        for (final c in categories) {
          await _db.collection('categories').add({'name': c});
        }
      }
    } catch (e) {
      Get.log('fetchCategories error: $e');
    }
  }

  Future<void> addCategory(String name) async {
    final clean = name.trim().toLowerCase();
    if (clean.isEmpty || categories.contains(clean)) return;
    try {
      await _db.collection('categories').add({'name': clean});
      categories.add(clean);
      AppSnackbar.success('Category "$clean" added');
    } catch (e) {
      AppSnackbar.error('Failed to add category: $e');
    }
  }

  Future<void> updateCategory(String oldName, String newName) async {
    final clean = newName.trim().toLowerCase();
    if (clean.isEmpty || clean == oldName) return;
    try {
      final snap = await _db.collection('categories')
          .where('name', isEqualTo: oldName).limit(1).get();
      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.update({'name': clean});
      }
      final idx = categories.indexOf(oldName);
      if (idx >= 0) categories[idx] = clean;
      AppSnackbar.success('Category updated');
    } catch (e) {
      AppSnackbar.error('Failed to update: $e');
    }
  }

  Future<void> deleteCategory(String name) async {
    try {
      final snap = await _db.collection('categories')
          .where('name', isEqualTo: name).limit(1).get();
      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.delete();
      }
      categories.remove(name);
      AppSnackbar.success('Category removed');
    } catch (e) {
      AppSnackbar.error('Failed to delete: $e');
    }
  }

  // ── Banners ────────────────────────────────────────────────────────────────

  /// Picks an image from the device gallery and uploads it to Firebase
  /// Storage under `banners/`, returning the public download URL.
  Future<String?> pickAndUploadBannerImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return null;

    isUploadingBannerImage.value = true;
    try {
      final ext = picked.path.split('.').last;
      final ref = _storage
          .ref('banners/${DateTime.now().millisecondsSinceEpoch}.$ext');
      await ref.putFile(File(picked.path));
      return await ref.getDownloadURL();
    } catch (e) {
      AppSnackbar.error('Failed to upload image: $e');
      return null;
    } finally {
      isUploadingBannerImage.value = false;
    }
  }

  Future<void> fetchBanners() async {
    isLoadingBanners.value = true;
    try {
      final snap = await _db.collection('banners').orderBy('sortOrder').get();
      banners.value = snap.docs.map(BannerModel.fromFirestore).toList();
    } catch (e) {
      AppSnackbar.error('Failed to load banners: $e');
    } finally {
      isLoadingBanners.value = false;
    }
  }

  Future<void> addBanner({
    required String imageUrl,
    required String title,
    required String linkUrl,
  }) async {
    if (imageUrl.isEmpty) {
      AppSnackbar.error('Image URL is required');
      return;
    }
    isLoading.value = true;
    try {
      final nextOrder = banners.isEmpty
          ? 0
          : banners.map((b) => b.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
      await _db.collection('banners').add({
        'imageUrl': imageUrl,
        'title': title,
        'linkUrl': linkUrl,
        'sortOrder': nextOrder,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await fetchBanners();
      AppSnackbar.success('Banner added successfully');
    } catch (e) {
      AppSnackbar.error('Failed to add banner: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateBanner(
    BannerModel banner, {
    required String imageUrl,
    required String title,
    required String linkUrl,
  }) async {
    if (imageUrl.isEmpty) {
      AppSnackbar.error('Image URL is required');
      return;
    }
    isLoading.value = true;
    try {
      await _db.collection('banners').doc(banner.id).update({
        'imageUrl': imageUrl,
        'title': title,
        'linkUrl': linkUrl,
      });
      await fetchBanners();
      AppSnackbar.success('Banner updated');
    } catch (e) {
      AppSnackbar.error('Failed to update banner: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleBannerActive(BannerModel banner) async {
    try {
      await _db
          .collection('banners')
          .doc(banner.id)
          .update({'isActive': !banner.isActive});
      await fetchBanners();
    } catch (e) {
      AppSnackbar.error('Failed to update banner: $e');
    }
  }

  Future<void> deleteBanner(String id) async {
    try {
      await _db.collection('banners').doc(id).delete();
      await fetchBanners();
      AppSnackbar.success('Banner deleted');
    } catch (e) {
      AppSnackbar.error('Failed to delete banner: $e');
    }
  }

  /// Move a banner up (-1) or down (+1) by swapping sortOrder with its neighbor.
  Future<void> reorderBanner(BannerModel banner, int direction) async {
    final idx = banners.indexOf(banner);
    final swapIdx = idx + direction;
    if (idx < 0 || swapIdx < 0 || swapIdx >= banners.length) return;
    final other = banners[swapIdx];
    try {
      await _db.collection('banners').doc(banner.id).update({'sortOrder': other.sortOrder});
      await _db.collection('banners').doc(other.id).update({'sortOrder': banner.sortOrder});
      await fetchBanners();
    } catch (e) {
      AppSnackbar.error('Failed to reorder banners: $e');
    }
  }

  Future<void> deleteVideo(String id) async {
    await _db.collection('videos').doc(id).delete();
    await fetchContent();
    AppSnackbar.success('Video deleted');
  }

  Future<void> deleteArticle(String id) async {
    await _db.collection('articles').doc(id).delete();
    await fetchContent();
    AppSnackbar.success('Article deleted');
  }

  // ── Support Chats ──────────────────────────────────────────────────────────
  Future<void> fetchAdminChats() async {
    isLoadingChats.value = true;
    try {
      final snap = await _db
          .collection('chats')
          .orderBy('lastMessageAt', descending: true)
          .limit(50)
          .get();
      adminChats.value = snap.docs
          .map((d) => {'id': d.id, ...d.data()})
          .toList();
    } catch (e) {
      Get.log('fetchAdminChats error: $e');
    } finally {
      isLoadingChats.value = false;
    }
  }

  void selectChat(String userId, String userName) {
    selectedChatUserId.value = userId;
    selectedChatUserName.value = userName;
    _listenToChatMessages(userId);
    // Clear unread badge
    _db.collection('chats').doc(userId)
        .update({'unreadByAdmin': 0}).catchError((_) {});
  }

  StreamSubscription? _chatSub;

  void _listenToChatMessages(String userId) {
    _chatSub?.cancel();
    selectedChatMessages.clear();
    _chatSub = _db
        .collection('chats')
        .doc(userId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .listen((snap) {
      selectedChatMessages.value =
          snap.docs.map((d) => ChatModel.fromFirestore(d)).toList();
    });
  }

  Future<void> sendAdminReply() async {
    final text = adminReplyController.text.trim();
    if (text.isEmpty || selectedChatUserId.value.isEmpty) return;
    isSendingReply.value = true;
    adminReplyController.clear();
    try {
      final msg = {
        'senderId': 'admin',
        'message': text,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'text',
        'isFromAdmin': true,
      };
      await _db
          .collection('chats')
          .doc(selectedChatUserId.value)
          .collection('messages')
          .add(msg);
      await _db.collection('chats').doc(selectedChatUserId.value).set({
        'lastMessage': text,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unreadByAdmin': 0,
      }, SetOptions(merge: true));
      await fetchAdminChats();
    } catch (e) {
      AppSnackbar.error('Failed to send reply: $e');
    } finally {
      isSendingReply.value = false;
    }
  }

  // ── Notifications ──────────────────────────────────────────────────────────
  Future<void> sendPushNotification() async {
    if (notifTitle.value.isEmpty || notifBody.value.isEmpty) {
      AppSnackbar.error('Title and message are required');
      return;
    }
    isLoading.value = true;
    try {
      // Save to Firestore — Cloud Function picks it up and sends FCM
      await _db.collection('admin_notifications').add({
        'title': notifTitle.value,
        'body': notifBody.value,
        'target': notifTarget.value,
        'sentAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      AppSnackbar.success('Notification queued for delivery');
      notifTitle.value = '';
      notifBody.value = '';
    } catch (e) {
      AppSnackbar.error('Failed: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
