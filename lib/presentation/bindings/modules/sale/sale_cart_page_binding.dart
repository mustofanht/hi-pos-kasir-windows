import 'package:get/get.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_cart_page_controller.dart';

class SaleCartPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SaleCartPageController>(() => SaleCartPageController());
  }
}
