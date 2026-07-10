import 'package:get/get.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/proofofpayment/bukti_pembayaran_page_controller.dart';

class BuktiPembayaranPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BuktiPembayaranPageController>(
        () => BuktiPembayaranPageController());
  }
}
