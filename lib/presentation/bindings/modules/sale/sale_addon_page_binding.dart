import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_addon_page_controller.dart';
import 'package:get/get.dart';

class SaleAddonPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SaleAddonPageController>(() => SaleAddonPageController());
  }
}
