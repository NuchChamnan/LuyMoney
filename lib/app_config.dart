enum AppEnvironment { dev, staging, prod }

class AppConfig {
  static const String appName = 'Luy Money';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  static AppEnvironment _environment = AppEnvironment.dev;

  static void setEnvironment(AppEnvironment env) {
    _environment = env;
  }

  static String get apiBaseUrl {
    switch (_environment) {
      case AppEnvironment.dev:
        return 'https://dev-api.luymoney.com';
      case AppEnvironment.staging:
        return 'https://staging-api.luymoney.com';
      case AppEnvironment.prod:
        return 'https://api.luymoney.com';
    }
  }

  static String get stripePublishableKey {
    switch (_environment) {
      case AppEnvironment.dev:
      case AppEnvironment.staging:
        return 'pk_test_YOUR_STRIPE_TEST_KEY';
      case AppEnvironment.prod:
        return 'pk_live_YOUR_STRIPE_LIVE_KEY';
    }
  }

  static String get telegramSupportUrl => 'https://t.me/LuyMoneySupport';
  static String get privacyPolicyUrl => 'https://luymoney.com/privacy';
  static String get termsOfServiceUrl => 'https://luymoney.com/terms';
  static String get faqUrl => 'https://luymoney.com/faq';

  // ABA Pay
  static String get abaPayMerchantId => 'YOUR_ABA_MERCHANT_ID';
  static String get abaPayPublicKey => 'YOUR_ABA_PUBLIC_KEY';
}
