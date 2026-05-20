import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../services/auth_service.dart';
import '../app_routes.dart';

class SubscriptionMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    if (!authService.hasActiveSubscription) {
      return const RouteSettings(name: Routes.SUBSCRIPTION);
    }
    return null;
  }
}
