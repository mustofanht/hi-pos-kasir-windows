import 'package:get/get.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/shift/shift_page_controller.dart';

class ShiftPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShiftPageController>(() => ShiftPageController());
  }
}
