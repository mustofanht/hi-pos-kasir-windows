import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_ticket_page_controller.dart';
import 'package:get/get.dart';

class SaleTicketPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SaleTicketPageController>(() => SaleTicketPageController());
  }
}
