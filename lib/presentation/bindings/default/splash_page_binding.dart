import 'package:jaya_propertiy/presentation/controllers/default/splash_page_controller.dart';
import 'package:get/get.dart';

class SplashPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashPageController>(() => SplashPageController());
  }
}
