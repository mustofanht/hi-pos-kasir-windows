import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/print_ticket/print_ticket_page_controller.dart';
import 'package:jaya_propertiy/presentation/views/modules/print_ticket/cek_order_detail_page.dart';
import 'package:jaya_propertiy/presentation/views/modules/print_ticket/cek_order_inq_page.dart';

class CekOrderPage extends GetView<PrintTicketPageController> {
  const CekOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    layoutStyle.init(context);

    return GetBuilder<PrintTicketPageController>(
      init: controller,
      tag: 'PrintTicketNewPage',
      builder: (controller) {
        return controller.openDetail.value
            ? const CekOrderDetailPage()
            : CekOrderInqPage(
                controller: controller,
              );
      },
    );
  }
}
