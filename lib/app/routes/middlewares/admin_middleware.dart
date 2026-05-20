import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../services/auth_service.dart';
import '../app_routes.dart';

class AdminMiddleware extends GetMiddleware {
  @override
  int? get priority => 3;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    if (!authService.isAdmin) {
      return const RouteSettings(name: Routes.HOME);
    }
    return null;
  }
}
