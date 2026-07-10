import 'package:jaya_propertiy/presentation/controllers/default/slide_page_controller.dart';
import 'package:get/get.dart';

class SlidePageBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SlidePageController>(() => SlidePageController());
  }
}
