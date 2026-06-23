import 'package:get/get.dart';
import '../../content/controllers/content_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    // ArticleCard's Like/Save/Pin actions call Get.find<ContentController>()
    // directly, but Home only loads ContentBinding when navigating into
    // Videos/Articles — register it here too so those actions work from
    // the Home feed as well.
    Get.lazyPut<ContentController>(() => ContentController());
  }
}
