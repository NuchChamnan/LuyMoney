import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  late final GetStorage _box;

  Future<StorageService> init() async {
    _box = GetStorage();
    return this;
  }

  T? read<T>(String key) => _box.read<T>(key);
  Future<void> write(String key, dynamic value) => _box.write(key, value);
  Future<void> remove(String key) => _box.remove(key);
  Future<void> erase() => _box.erase();
  bool hasData(String key) => _box.hasData(key);

  // Specific keys
  static const String themeKey = 'theme';
  static const String langKey = 'lang';
  static const String rememberEmailKey = 'remember_email';
  static const String biometricKey = 'biometric_enabled';
  static const String notifSubKey = 'notif_subscription';
  static const String notifContentKey = 'notif_content';
  static const String notifPromoKey = 'notif_promo';
  static const String bookmarkedVideosKey = 'bookmarked_videos';
  static const String bookmarkedArticlesKey = 'bookmarked_articles';
  static const String likedVideosKey = 'liked_videos';
  static const String likedArticlesKey = 'liked_articles';
  static const String pinnedArticlesKey = 'pinned_articles';
  static const String readNotificationsKey = 'read_notifications';

  // Bookmarks
  List<String> get bookmarkedVideoIds =>
      _box.read<List>(bookmarkedVideosKey)?.cast<String>() ?? [];

  List<String> get bookmarkedArticleIds =>
      _box.read<List>(bookmarkedArticlesKey)?.cast<String>() ?? [];

  Future<void> toggleVideoBookmark(String id) async {
    final ids = bookmarkedVideoIds;
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    await write(bookmarkedVideosKey, ids);
  }

  Future<void> toggleArticleBookmark(String id) async {
    final ids = bookmarkedArticleIds;
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    await write(bookmarkedArticlesKey, ids);
  }

  bool isVideoBookmarked(String id) => bookmarkedVideoIds.contains(id);
  bool isArticleBookmarked(String id) => bookmarkedArticleIds.contains(id);

  // Likes
  List<String> get likedVideoIds =>
      _box.read<List>(likedVideosKey)?.cast<String>() ?? [];

  Future<void> toggleVideoLike(String id) async {
    final ids = likedVideoIds;
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    await write(likedVideosKey, ids);
  }

  bool isVideoLiked(String id) => likedVideoIds.contains(id);

  List<String> get likedArticleIds =>
      _box.read<List>(likedArticlesKey)?.cast<String>() ?? [];

  Future<void> toggleArticleLike(String id) async {
    final ids = likedArticleIds;
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    await write(likedArticlesKey, ids);
  }

  bool isArticleLiked(String id) => likedArticleIds.contains(id);

  // Pins (kept locally per-device — pinned posts surface at the top of the list)
  List<String> get pinnedArticleIds =>
      _box.read<List>(pinnedArticlesKey)?.cast<String>() ?? [];

  Future<void> toggleArticlePinned(String id) async {
    final ids = pinnedArticleIds;
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    await write(pinnedArticlesKey, ids);
  }

  bool isArticlePinned(String id) => pinnedArticleIds.contains(id);

  // Notifications read-state (per-device — admin_notifications has no per-user doc)
  List<String> get readNotificationIds =>
      _box.read<List>(readNotificationsKey)?.cast<String>() ?? [];

  Future<void> markNotificationRead(String id) async {
    final ids = readNotificationIds;
    if (!ids.contains(id)) {
      ids.add(id);
      await write(readNotificationsKey, ids);
    }
  }

  bool isNotificationRead(String id) => readNotificationIds.contains(id);
}
