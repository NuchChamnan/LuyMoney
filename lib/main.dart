import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app/routes/app_pages.dart';
import 'app/services/auth_service.dart';
import 'app/services/notification_service.dart';
import 'app/services/storage_service.dart';
import 'app/shared/themes/app_themes.dart';
import 'app/shared/translations/app_translations.dart';
import 'app/modules/settings/controllers/language_controller.dart';
import 'app_config.dart';
import 'firebase_options.dart';

// ABCDEF
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize App Check
  if (!kIsWeb) {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? AndroidDebugProvider()
          : AndroidPlayIntegrityProvider(),
    );
  } else {
    // Web requires reCAPTCHA — skip in development
    try {
      await FirebaseAppCheck.instance.activate(
        providerWeb: ReCaptchaEnterpriseProvider(''),
      );
    } catch (_) {}
  }

  await GetStorage.init();
  await Hive.initFlutter();
  tz.initializeTimeZones();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Controllers needed before first frame
  Get.put(ThemeController());
  Get.put(LanguageController());

  runApp(const LuyMoneyApp());

  // Initialize remaining services after first frame is rendered
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => AuthService().init());
  Get.putAsync(() => NotificationService().init());
}

class LuyMoneyApp extends StatelessWidget {
  const LuyMoneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final languageController = Get.find<LanguageController>();

    return Obx(
      () => GetMaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppThemes.getTheme(themeController.currentTheme.value),
        locale: languageController.currentLocale.value,
        fallbackLocale: const Locale('en', 'US'),
        translations: AppTranslations(),
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.noScaling),
            child: child!,
          );
        },
      ),
    );
  }
}

