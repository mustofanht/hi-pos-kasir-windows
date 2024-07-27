import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/common/custom_table_data.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order_entity.dart';
import 'package:jaya_propertiy/domain/entities/order/trn_order_entity.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/print_ticket/print_ticket_page_controller.dart';

class PrintTicketDetailPageController extends GetxController {
  PrintTicketDetailPageController();

  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];

  final parentController = Get.find<PrintTicketPageController>();

  final detailListColumnHeader = <CustomTableData>[].obs;
  var selected = List<bool>.generate(100, (index) => false).obs;
  var selectAll = false.obs;
  final isLoading = false.obs;

  final parentModel = TrnOrderEntity().obs;

  final model = TrnDetailOrderEntity().obs;

  doPrepared() async {
    isLoading.value = true;
    await setListHeaderColumn();
    parentModel.value = parentController.selectedData.value;
    await getDetail();
    isLoading.value = false;
    update();
  }

  getDetail() async {
    try {
      var result;
      result = await _service.order.orderService.getDetailOrder(
          authToken: _authToken, orderNo: parentModel.value.orderNumber);
      result.fold((l) {
        logger.safeLog(l);
      }, (r) {
        model.value = r.data;
      });
    } catch (e) {
      logger.safeLog(e);
    }
    update();
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
    detailListColumnHeader.clear();
    detailListColumnHeader.add(
      CustomTableData(
        id: 'productName',
        columnName: 'Tiket',
        alignment: Alignment.centerLeft,
      ),
    );
    detailListColumnHeader.add(
      CustomTableData(
        id: 'quantity',
        columnName: 'Quantity',
        alignment: Alignment.center,
      ),
    );
    detailListColumnHeader.add(
      CustomTableData(
        id: 'price',
        columnName: 'Item Price',
        alignment: Alignment.centerRight,
      ),
    );
    // detailListColumnHeader.add(
    //   CustomTableData(
    //     id: 'Discount',
    //     columnName: 'Discount',
    //     alignment: Alignment.centerRight,
    //   ),
    // );
    detailListColumnHeader.add(
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
    parentModel.value = TrnOrderEntity();
    parentController.update();
  }
}
