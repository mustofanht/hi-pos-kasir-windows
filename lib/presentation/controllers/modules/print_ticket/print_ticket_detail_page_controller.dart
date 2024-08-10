import 'package:either_dart/either.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/common/generate_print_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/printer_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/common/custom_table_data.dart';
import 'package:jaya_propertiy/data/models/order/order_addon_model.dart';
import 'package:jaya_propertiy/data/models/order/order_model.dart';
import 'package:jaya_propertiy/data/models/order/order_ticket_model.dart';
import 'package:jaya_propertiy/data/models/order/order_voucher_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/auth/user_entity.dart';
import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order.dart';
import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order_entity.dart';
import 'package:jaya_propertiy/domain/entities/order/vw_order_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_dialog.dart';
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

  doActiveTicket() {}

  doPrintTicket() async {
    // // var printController = Get.put(PrintController());
    // var printController = Get.find<PrintController>();
    // bool bluetoothIsEnabled = await printController.bluetoothIsEnabled();
    // if (bluetoothIsEnabled) {
    //   // var paymentPrintController = Get.put(PaymentPrintController());
    //   // var gatePrintController = Get.put(GatePrintController());
    //   // await printController.printPaymentTiket(
    //   //   body,
    //   //   paymentPrintController,
    //   //   gatePrintController,
    //   // );;
    //   alert.warning('Warning', 'Action on under construction');
    // } else {
    //   alert.error('Error', 'bluetooth is off, please turn it on first');
    // }
    
    // try {
    //   if (printerUtil.currPrinter != null) {
    //     String locationName = "";
    //     UserEntity? user = await common.getUser(
    //       authToken: _authToken,
    //     );
    //     if (user != null) {
    //       locationName = user.locationName!;
    //     }

    //     List<OrderTicketModel> ticketList = detailModel.value.detailOrderModels!
    //         .map(
    //           (e) => OrderTicketModel(
    //             totalTicket: e.quantity!,
    //             totalAmount: e.total!,
    //           ),
    //         )
    //         .toList();
    //     List<OrderAddonModel> productList = detailModel.value.detailOrderModels!
    //         .map(
    //           (e) => OrderAddonModel(
    //             ordadTotalAddon: e.quantity!,
    //             ordadTotalAmount: e.total!,
    //           ),
    //         )
    //         .toList();
    //     List<OrderVoucherModel> voucherList =
    //         detailModel.value.detailOrderModels!
    //             .map(
    //               (e) => OrderVoucherModel(
    //                 ordvcTotalVoucher: e.quantity!,
    //                 ordvcTotalAmount: e.total!,
    //               ),
    //             )
    //             .toList();

    //     OrderModel orderModel = OrderModel(
    //       orderTotalItem: parentModel.value.orderTotalItem!,
    //       orderTotalAmt: detailModel.value.orderTotalAmt!,
    //       orderUnitId: 0,
    //       orderLoacationId: 0,
    //       orderPaidBy: detailModel.value.orderPaidBy!,
    //       orderStatus: detailModel.value.orderStatus!,
    //       listTicket: ticketList,
    //       listProduct: productList,
    //       listVoucher: voucherList,
    //     );

    //     List<int> data = [];
    //     data = await generatePrintUtil.dataPaymentTiketPrint(
    //       locationName: locationName,
    //       paperSize: PaperSize.mm80,
    //       body: orderModel,
    //     );
    //     if (orderModel.listCreateTicket != null) {
    //       int count = 1;
    //       int totalPak = orderModel.listCreateTicket!.length;
    //       for (var element in orderModel.listCreateTicket!) {
    //         List<int> dataPrint = await generatePrintUtil.dataGatePrint(
    //           locationName: locationName,
    //           paperSize: PaperSize.mm80,
    //           reffNo: element.ticketNo!,
    //           pakOf: count,
    //           pakTotal: totalPak,
    //           qrCode: element.ticketNo!,
    //           expiredAt: dateTimeUtil.now(format: dateFormat.dateDDMMMMYYYY),
    //           ticketName: element.ticketName,
    //         );
    //         data.addAll(dataPrint);
    //         count++;
    //       }
    //     }

    //     await printerUtil.print(printerUtil.currPrinter!, data);
    //     Get.back();
    //   } else {
    //     alert.error('Error', 'please check connection printer');
    //   }
    // } catch (e) {
    //   logger.safeLog(e);
    //   alert.error('Error', 'Terjadi Kesalahan , hubungi admin');
    // }
  }
}
