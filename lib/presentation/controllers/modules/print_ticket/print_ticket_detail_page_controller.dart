import 'package:either_dart/either.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/common/custom_table_data.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order.dart';
import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order_entity.dart';
import 'package:jaya_propertiy/domain/entities/order/response_create_ticket_no_entity.dart';
import 'package:jaya_propertiy/domain/entities/order/vw_order_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_dialog.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/print_ticket/print_ticket_page_controller.dart';

class PrintTicketDetailPageController extends GetxController {
  PrintTicketDetailPageController();

  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];

  final parentController = Get.find<PrintTicketPageController>();

  final detailListColumnHeader = <CustomTableData>[].obs;
  var selected = <TrnDetailOrder>[].obs;
  var selectAll = false.obs;
  final isLoading = false.obs;

  final parentModel = VwOrderEntity().obs;

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
    selected.clear();
    if (value!) {
      for (var element in model.value.detailOrderModels!) {
        selected.add(element);
      }
    }
    update();
  }

  void toggleSelect(TrnDetailOrder modelSelected, bool? value) {
    if (value!) {
      selected.add(modelSelected);
    } else {
      selected.remove(modelSelected);
    }
    selectAll.value = selected.length == model.value.detailOrderModels!.length;
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
    parentModel.value = VwOrderEntity();
    parentController.update();
  }

  doSendEmail() {
    dialog.paymentSendProofOfPayment(
      title: 'Send Email WA',
      labelButton: 'Close',
      onSendEmail: (val) {
        logger.safeLog('Email : ${val}');
        var result = _service.message.sendEmail(
          authToken: _authToken,
          phoneNumber: int.parse(val),
          message: _buildBodyMessage(),
        );
        result.fold(
          (left) => alert.error('Error', 'Send Wa Internal Server Error'),
          (right) => alert.success('Success', 'Send Wa Sucess'),
        );
      },
      onSendWa: (val) {
        logger.safeLog('WA : ${val}');
        var result = _service.message.sendWa(
          authToken: _authToken,
          phoneNumber: int.parse(val),
          message: _buildBodyMessage(),
        );
        result.fold(
          (left) => alert.error('Error', 'Send Wa Internal Server Error'),
          (right) => alert.success('Success', 'Send Wa Sucess'),
        );
      },
      onNewOrder: () {
        Get.back();
      },
    );
  }

  String _buildBodyMessage() {
    String bodyMsg = '';
    bodyMsg += 'Your Ticket';
    for (var element in selected) {
      bodyMsg += 'Product Name : ${element.productName}';
    }
    return bodyMsg;
  }

  doActiveTicket() {
    dialog.dialogCustomerLeftRight(
      title: 'Aktivasi Tiket',
      msg: 'Apakah anda yakin akan aktivasi?',
      labelLeft: 'No',
      labelRight: 'Yes',
      onLeft: () {
        Get.back();
      },
      onRight: () async {
        Get.back();
        try {
          if (model.value.orderNumber != null) {
            await createTicketNo(model.value.orderNumber!);
            alert.success('Success', 'Berhasil Aktivasi Tiket');
          } else {
            alert.error('Error', 'Terjadi Kesalahan , hubungi admin');
          }
        } catch (e) {
          logger.safeLog(e);
          alert.error('Error', 'Terjadi Kesalahan , hubungi admin');
        }
      },
    );
  }

  doPrintTicket() async {
    try {
      if (model.value.orderNumber != null) {
        await createTicketNo(model.value.orderNumber!);
      } else {
        alert.error('Error', 'Terjadi Kesalahan , hubungi admin');
      }
      List<ResponseCreateTicketNoEntity> listCreateTicket =
          await createTicketNo(
        model.value.orderNumber!,
      );
    } catch (e) {
      logger.safeLog(e);
      alert.error('Error', 'Terjadi Kesalahan , hubungi admin');
    }
  }

  Future<List<ResponseCreateTicketNoEntity>> createTicketNo(
    String orderNo,
  ) async {
    try {
      List<ResponseCreateTicketNoEntity> dataList = [];
      var result = await _service.order.orderService.createTicketNo(
        authToken: _authToken,
        reffNo: orderNo,
      );

      result.fold(
        (l) {
          logger.safeLog(l);
          logger.safeLog('Create Ticket No Error 1');
          alert.error('Error', 'Terjadi Kesalahan!');
        },
        (r) {
          logger.safeLog('Create Ticket No Success');
          logger.safeLog(r);
          dataList = r;
        },
      );
      return dataList;
    } catch (e) {
      logger.safeLog('Create Ticket No Error 2');
      logger.safeLog(e.toString());
      return [];
    }
  }
}
