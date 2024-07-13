import 'package:jaya_propertiy/app/main/app_route.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:get/get.dart';

class SlidePageController extends GetxController {
  checkIsLogin() {
    logger.safeLog('Done');
    Get.offAllNamed(
      RouteName.loginPage,
    );
  }
}
