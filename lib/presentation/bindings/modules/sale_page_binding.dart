import 'package:jaya_propertiy/presentation/controllers/modules/sale_page_controller.dart';
import 'package:get/get.dart';

class SalePageBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SalePageController>(() => SalePageController());
  }
}
