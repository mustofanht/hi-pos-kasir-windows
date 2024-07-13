import 'dart:async';

import 'package:jaya_propertiy/app/main/app_route.dart';
import 'package:get/get.dart';

class SplashPageController extends GetxController {
  SplashPageController();

  sessionCheck() {
    Timer(const Duration(seconds: 5), () {
      // if (sessionUtil.isActive()) {
      //   // final controller = Get.put(null); // To Sign In Page
      //   logger.safeLog('Is Active');
      // } else {
      //   // for check connection if connection is
      // }

      Get.offAllNamed(
        RouteName.loginPage,
        arguments: {
          "first_login": true,
        },
      );
    });
  }
}
