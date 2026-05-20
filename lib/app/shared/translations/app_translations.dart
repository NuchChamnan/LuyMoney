import 'package:get/get.dart';
import 'locales/en_us.dart';
import 'locales/km_kh.dart';
import 'locales/zh_cn.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'km_KH': kmKH,
        'zh_CN': zhCN,
      };
}
