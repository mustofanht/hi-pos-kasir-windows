import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_voucher_page_controller.dart';
import 'package:get/get.dart';

class SaleVoucherPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SaleVoucherPageController>(() => SaleVoucherPageController());
  }
}
