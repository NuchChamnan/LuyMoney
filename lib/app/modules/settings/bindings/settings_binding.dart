import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../controllers/language_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());
    Get.lazyPut<LanguageController>(() => LanguageController());
  }
}
