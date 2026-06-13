abstract class Routes {
  Routes._();

  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const FORGOT_PASSWORD = '/forgot-password';
  static const HOME = '/home';
  static const SUBSCRIPTION = '/subscription';
  static const PAYMENT = '/payment';
  static const VIDEOS = '/content/videos';
  static const VIDEO_DETAIL = '/content/videos/:id';
  static const SAVED_VIDEOS = '/content/videos/saved';
  static const ARTICLES = '/content/articles';
  static const ARTICLE_DETAIL = '/content/articles/:id';
  static const SUPPORT = '/support';
  static const SETTINGS = '/settings';
  static const PROFILE = '/settings/profile';
  static const ADMIN = '/admin';
  static const ADMIN_USERS = '/admin/users';
  static const ADMIN_CONTENT = '/admin/content';
  static const ADMIN_ANALYTICS = '/admin/analytics';
  static const ADMIN_NOTIFICATIONS = '/admin/notifications';
}
