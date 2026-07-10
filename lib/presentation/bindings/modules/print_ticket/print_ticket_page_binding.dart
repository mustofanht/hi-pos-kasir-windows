import 'package:get/get.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/print_ticket/print_ticket_page_controller.dart';

class PrintTicketPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrintTicketPageController>(() => PrintTicketPageController());
  }
}
