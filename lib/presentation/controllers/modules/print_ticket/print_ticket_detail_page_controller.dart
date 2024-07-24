import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/data/models/common/custom_table_data.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/print_ticket/print_ticket_page_controller.dart';

class PrintTicketDetailPageController extends GetxController {
  PrintTicketDetailPageController();

  final listColumnHeader = <CustomTableData>[].obs;
  var selected = List<bool>.generate(100, (index) => false).obs;
  var selectAll = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    setListHeaderColumn();
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }


  void toggleSelectAll(bool? value) {
    selectAll.value = value ?? false;
    for (int i = 0; i < selected.length; i++) {
      selected[i] = selectAll.value;
    }
    update();
  }

  void toggleSelect(int index, bool? value) {
    selected[index] = value ?? false;
    selectAll.value = selected.every((element) => element);
    update();
  }

  setListHeaderColumn() {
    listColumnHeader.add(
      CustomTableData(
        id: 'ticket',
        columnName: 'Tiket',
        alignment: Alignment.centerLeft,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'qty',
        columnName: 'Quantity',
        alignment: Alignment.center,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'itemPrice',
        columnName: 'Item Price',
        alignment: Alignment.centerRight,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'Discount',
        columnName: 'Discount',
        alignment: Alignment.centerRight,
      ),
    );
    listColumnHeader.add(
      CustomTableData(
        id: 'total',
        columnName: 'Total',
        alignment: Alignment.centerRight,
      ),
    );
    update();
  }

  doBack() {
    final parentController = Get.find<PrintTicketPageController>();
    parentController.openDetail.value = false;
    parentController.update();
  }
}
