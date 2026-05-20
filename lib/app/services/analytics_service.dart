import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';

class AnalyticsService extends GetxService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // ── Content ───────────────────────────────────────────────────────────────
  Future<void> logContentViewed({
    required String type, // 'video' | 'article'
    required String id,
    required String title,
  }) async {
    await _analytics.logEvent(
      name: 'content_viewed',
      parameters: {'type': type, 'content_id': id, 'title': title},
    );
  }

  Future<void> logVideoCompleted({
    required String id,
    required int durationSeconds,
  }) async {
    await _analytics.logEvent(
      name: 'video_completed',
      parameters: {'video_id': id, 'duration_seconds': durationSeconds},
    );
  }

  Future<void> logArticleBookmarked(String id) async {
    await _analytics.logEvent(
      name: 'article_bookmarked',
      parameters: {'article_id': id},
    );
  }

  // ── Subscription ──────────────────────────────────────────────────────────
  Future<void> logSubscriptionStarted({
    required String planId,
    required double price,
  }) async {
    await _analytics.logEvent(
      name: 'subscription_started',
      parameters: {'plan_id': planId, 'price': price},
    );
    await _analytics.logPurchase(
      currency: 'USD',
      value: price,
      items: [AnalyticsEventItem(itemId: planId, price: price)],
    );
  }

  Future<void> logSubscriptionRenewed({
    required String planId,
    required double price,
  }) async {
    await _analytics.logEvent(
      name: 'subscription_renewed',
      parameters: {'plan_id': planId, 'price': price},
    );
  }

  Future<void> logSubscriptionExpired() async {
    await _analytics.logEvent(name: 'subscription_expired');
  }

  // ── Settings ──────────────────────────────────────────────────────────────
  Future<void> logLanguageSwitched({
    required String from,
    required String to,
  }) async {
    await _analytics.logEvent(
      name: 'language_switched',
      parameters: {'from': from, 'to': to},
    );
  }

  Future<void> logThemeSwitched({
    required String from,
    required String to,
  }) async {
    await _analytics.logEvent(
      name: 'theme_switched',
      parameters: {'from': from, 'to': to},
    );
  }

  // ── Support ───────────────────────────────────────────────────────────────
  Future<void> logSupportOpened(String channel) async {
    await _analytics.logEvent(
      name: 'support_opened',
      parameters: {'channel': channel}, // 'telegram' | 'in_app'
    );
  }

  // ── Auth ──────────────────────────────────────────────────────────────────
  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  // ── User properties ───────────────────────────────────────────────────────
  Future<void> setUserProperties({
    required String userId,
    required String plan,
  }) async {
    await _analytics.setUserId(id: userId);
    await _analytics.setUserProperty(name: 'subscription_plan', value: plan);
  }
}
