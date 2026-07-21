import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_lapangan_page_controller.dart';
import 'package:get/get.dart';

class SaleLapanganPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SaleLapanganPageController>(() => SaleLapanganPageController());
  }
}
