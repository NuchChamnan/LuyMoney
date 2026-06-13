import 'package:get/get.dart';

import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/splash_view.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/views/forgot_password_view.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';

import '../modules/subscription/bindings/subscription_binding.dart';
import '../modules/subscription/views/subscription_view.dart';
import '../modules/subscription/views/payment_view.dart';

import '../modules/content/bindings/content_binding.dart';
import '../modules/content/views/videos_view.dart';
import '../modules/content/views/video_detail_view.dart';
import '../modules/content/views/saved_videos_view.dart';
import '../modules/content/views/articles_view.dart';
import '../modules/content/views/article_detail_view.dart';

import '../modules/support/bindings/support_binding.dart';
import '../modules/support/views/support_view.dart';

import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/settings/views/profile_view.dart';

import '../modules/admin/bindings/admin_binding.dart';
import '../modules/admin/views/admin_view.dart';
import '../modules/admin/views/admin_users_view.dart';
import '../modules/admin/views/admin_content_view.dart';
import '../modules/admin/views/admin_analytics_view.dart';
import '../modules/admin/views/admin_notifications_view.dart';

import 'app_routes.dart';
import 'middlewares/auth_middleware.dart';
import 'middlewares/admin_middleware.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(name: Routes.SPLASH, page: () => const SplashView(), binding: AuthBinding()),
    GetPage(name: Routes.LOGIN, page: () => const LoginView(), binding: AuthBinding()),
    GetPage(name: Routes.REGISTER, page: () => const RegisterView(), binding: AuthBinding()),
    GetPage(name: Routes.FORGOT_PASSWORD, page: () => const ForgotPasswordView(), binding: AuthBinding()),

    GetPage(name: Routes.HOME, page: () => const HomeView(), binding: HomeBinding(),
        middlewares: [AuthMiddleware()]),

    GetPage(name: Routes.SUBSCRIPTION, page: () => const SubscriptionView(),
        binding: SubscriptionBinding(), middlewares: [AuthMiddleware()]),
    GetPage(name: Routes.PAYMENT, page: () => const PaymentView(),
        binding: SubscriptionBinding(), middlewares: [AuthMiddleware()]),

    GetPage(name: Routes.VIDEOS, page: () => const VideosView(),
        binding: ContentBinding(), middlewares: [AuthMiddleware()]),
    GetPage(name: Routes.SAVED_VIDEOS, page: () => const SavedVideosView(),
        binding: ContentBinding(), middlewares: [AuthMiddleware()]),
    GetPage(name: Routes.VIDEO_DETAIL, page: () => const VideoDetailView(),
        binding: ContentBinding(), middlewares: [AuthMiddleware()]),
    GetPage(name: Routes.ARTICLES, page: () => const ArticlesView(),
        binding: ContentBinding(), middlewares: [AuthMiddleware()]),
    GetPage(name: Routes.ARTICLE_DETAIL, page: () => const ArticleDetailView(),
        binding: ContentBinding(), middlewares: [AuthMiddleware()]),

    GetPage(name: Routes.SUPPORT, page: () => const SupportView(),
        binding: SupportBinding(), middlewares: [AuthMiddleware()]),

    GetPage(name: Routes.SETTINGS, page: () => const SettingsView(),
        binding: SettingsBinding(), middlewares: [AuthMiddleware()]),
    GetPage(name: Routes.PROFILE, page: () => const ProfileView(),
        binding: SettingsBinding(), middlewares: [AuthMiddleware()]),

    GetPage(name: Routes.ADMIN, page: () => const AdminView(),
        binding: AdminBinding(), middlewares: [AuthMiddleware(), AdminMiddleware()]),
    GetPage(name: Routes.ADMIN_USERS, page: () => const AdminUsersView(),
        binding: AdminBinding(), middlewares: [AuthMiddleware(), AdminMiddleware()]),
    GetPage(name: Routes.ADMIN_CONTENT, page: () => const AdminContentView(),
        binding: AdminBinding(), middlewares: [AuthMiddleware(), AdminMiddleware()]),
    GetPage(name: Routes.ADMIN_ANALYTICS, page: () => const AdminAnalyticsView(),
        binding: AdminBinding(), middlewares: [AuthMiddleware(), AdminMiddleware()]),
    GetPage(name: Routes.ADMIN_NOTIFICATIONS, page: () => const AdminNotificationsView(),
        binding: AdminBinding(), middlewares: [AuthMiddleware(), AdminMiddleware()]),
  ];
}
