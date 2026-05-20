import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static const String _channelId = 'luy_money_channel';
  static const String _channelName = 'Luy Money';
  static const String _channelDesc = 'Luy Money Notifications';

  Future<NotificationService> init() async {
    await _initLocalNotifications();
    await _initFCM();
    return this;
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> _initFCM() async {
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(
        title: message.notification?.title ?? 'Luy Money',
        body: message.notification?.body ?? '',
      );
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void _onNotificationTap(NotificationResponse response) {
    Get.log('Notification tapped: ${response.payload}');
  }

  Future<void> scheduleExpiryReminders(DateTime expiryDate) async {
    await cancelAllReminders();
    await _schedule7DayReminder(expiryDate);
    await _schedule1DayReminder(expiryDate);
    await _scheduleExpiryNotification(expiryDate);
  }

  Future<void> _schedule7DayReminder(DateTime expiryDate) async {
    final scheduledDate = expiryDate.subtract(const Duration(days: 7));
    if (scheduledDate.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: 1,
        title: 'Luy Money',
        body: '⏰ Your subscription expires in 7 days. Renew now!',
        scheduledDate: scheduledDate,
      );
    }
  }

  Future<void> _schedule1DayReminder(DateTime expiryDate) async {
    final scheduledDate = expiryDate.subtract(const Duration(days: 1));
    if (scheduledDate.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: 2,
        title: 'Luy Money',
        body: '🔔 Last day! Your subscription expires tomorrow.',
        scheduledDate: scheduledDate,
      );
    }
  }

  Future<void> _scheduleExpiryNotification(DateTime expiryDate) async {
    if (expiryDate.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: 3,
        title: 'Luy Money',
        body: '🔒 Your subscription has expired. Renew to access content.',
        scheduledDate: expiryDate,
      );
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await _localNotifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  Future<void> cancelAllReminders() async {
    await _localNotifications.cancel(id: 1);
    await _localNotifications.cancel(id: 2);
    await _localNotifications.cancel(id: 3);
  }

  Future<String?> getFCMToken() async {
    return await _fcm.getToken();
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Get.log('Background FCM message: ${message.messageId}');
}
