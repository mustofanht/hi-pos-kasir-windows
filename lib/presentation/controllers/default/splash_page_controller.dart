import 'dart:async';

import 'package:jaya_propertiy/app/main/app_route.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/display_util.dart';

class SplashPageController extends GetxController {
  SplashPageController();
  
  @override
  void onInit() {
    sessionCheck();
    // displayUtil.showDisplay(selectedScreens.value.id);
    displayUtil.displayCustomer(null);
    super.onInit();
  }

  sessionCheck() {
    Timer(const Duration(seconds: 3), () {
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
