import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../services/auth_service.dart';
import '../app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    if (!authService.isLoggedIn) {
      return const RouteSettings(name: Routes.LOGIN);
    }
    return null;
  }
}
