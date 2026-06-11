import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AppEnvironment { dev, staging, prod }

class AppConfig {
  static AppEnvironment _environment = AppEnvironment.dev;

  static AppEnvironment get environment => _environment;
  static bool get isDev => _environment == AppEnvironment.dev;
  static bool get isStaging => _environment == AppEnvironment.staging;
  static bool get isProd => _environment == AppEnvironment.prod;

  static void setEnvironment(AppEnvironment env) {
    _environment = env;
  }

  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  static String get appName =>
      dotenv.env['APP_NAME'] ?? 'Luy Money';

  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://dev-api.luymoney.com';

  static String get stripePublishableKey =>
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';

  static String get abaPayMerchantId =>
      dotenv.env['ABA_MERCHANT_ID'] ?? '';

  static String get abaPayPublicKey =>
      dotenv.env['ABA_PUBLIC_KEY'] ?? '';

  static String get telegramSupportUrl =>
      dotenv.env['TELEGRAM_SUPPORT_URL'] ?? 'https://t.me/LuyMoneySupport';

  static String get privacyPolicyUrl =>
      dotenv.env['PRIVACY_POLICY_URL'] ?? 'https://luymoney.com/privacy';

  static String get termsOfServiceUrl =>
      dotenv.env['TERMS_URL'] ?? 'https://luymoney.com/terms';

  static String get faqUrl =>
      dotenv.env['FAQ_URL'] ?? 'https://luymoney.com/faq';
}
