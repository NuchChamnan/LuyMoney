import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../data/models/notification_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';

class NotificationsController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _authService = Get.find<AuthService>();
  final _storage = Get.find<StorageService>();

  final notifications = <AppNotificationModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final snap = await _firestore
          .collection('admin_notifications')
          .orderBy('sentAt', descending: true)
          .limit(100)
          .get();

      final all = snap.docs.map(AppNotificationModel.fromFirestore).toList();
      notifications.value = all
          .where(_isRelevantToCurrentUser)
          .map((n) => n.copyWith(isRead: _storage.isNotificationRead(n.id)))
          .toList();
    } catch (e) {
      Get.log('Error loading notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool _isRelevantToCurrentUser(AppNotificationModel n) {
    switch (n.target) {
      case 'active':
        return _authService.hasActiveSubscription;
      case 'expiring':
        return _authService.currentUser.value?.subscription?.isExpiringSoon ??
            false;
      default:
        return true;
    }
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  Future<void> markAsRead(String id) async {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index == -1 || notifications[index].isRead) return;
    await _storage.markNotificationRead(id);
    notifications[index] = notifications[index].copyWith(isRead: true);
    notifications.refresh();
  }
}
