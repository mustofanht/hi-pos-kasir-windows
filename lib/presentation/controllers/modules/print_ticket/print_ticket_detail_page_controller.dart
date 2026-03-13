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
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/auth/user_entity.dart';
import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order_entity.dart';
import 'package:jaya_propertiy/domain/entities/order/response_create_ticket_no_entity.dart';
import 'package:jaya_propertiy/domain/entities/order/vw_order_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_dialog.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/print_ticket/print_ticket_page_controller.dart';

class PrintTicketDetailPageController extends GetxController {
  final PrintTicketPageController parentController;
  PrintTicketDetailPageController({required this.parentController});

  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];

  final statusPembayaran = RxString('N');
  final statusCetak = RxString('N');

  // final parentController = Get.find<PrintTicketPageController>();

  final detailListColumnHeader = <CustomTableData>[].obs;
  // var selected = <TrnDetailOrder>[].obs;
  // var selectAll = false.obs;
  final isLoading = false.obs;

  final parentModel = VwOrderEntity().obs;

  final model = TrnDetailOrderEntity().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    doPrepared();
  }

  doPrepared() async {
    isLoading.value = true;
    await setListHeaderColumn();
    parentModel.value = parentController.selectedData.value;
    await getDetail();
    isLoading.value = false;

    statusPembayaran.value = parentModel.value.pymntStatus ?? 'N';
    statusCetak.value = parentModel.value.statusCetak ?? 'N';

    logger.safeLog('ORD NO : ${parentModel.value.orderNumber}');
    logger.safeLog('STS PAYMENT : ${statusPembayaran.value}');
    logger.safeLog('STS PRINT : ${statusCetak.value}');
    update();
  }

  getDetail() async {
    try {
      var result;
      result = await _service.order.orderService.getDetailOrder(
        authToken: _authToken,
        orderNo: parentModel.value.orderNumber,
      );
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

  // void toggleSelectAll(bool? value) {
  //   selectAll.value = value ?? false;
  //   selected.clear();
  //   if (value!) {
  //     for (var element in model.value.detailOrderModels!) {
  //       selected.add(element);
  //     }
  //   }
  //   update();
  // }

  // void toggleSelect(TrnDetailOrder modelSelected, bool? value) {
  //   if (value!) {
  //     selected.add(modelSelected);
  //   } else {
  //     selected.remove(modelSelected);
  //   }
  //   selectAll.value = selected.length == model.value.detailOrderModels!.length;
  //   update();
  // }

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
    logger.safeLog('BACK TO INQ');
    // final parentController = Get.find<PrintTicketPageController>();
    parentController.openDetail.value = false;
    parentController.doSearch();
    // parentController.doRefresh();
    // parentController.searchController.text = '';
    parentModel.value = VwOrderEntity();
    parentController.update();
  }

  doSendEmail() {
    dialog.paymentSendProofOfPayment(
      title: 'Send Email WA',
      labelButton: 'Close',
      onSendEmail: (val) {
        loading.popUpLoading();
        logger.safeLog('Email : $val');
        try {
          var result = _service.message.sendEmail(
            authToken: _authToken,
            orderNo: model.value.orderNumber ?? '',
            mailTo: val,
            message: _buildBodyMessage(),
          );
          result.fold(
            (left) {
              if (Get.isDialogOpen == true) Get.back();
              alert.error('Error', left);
            },
            (right) {
              if (Get.isDialogOpen == true) Get.back();
              alert.success('Success', 'Send Email Sucess');
            },
          );
        } catch (e) {
          if (Get.isDialogOpen == true) Get.back();
          alert.error('Error', 'Send Email Internal Server Error');
        }
      },
      onSendWa: (val) {
        loading.popUpLoading();
        logger.safeLog('WA : $val');
        try {
          var result = _service.message.sendWa(
            authToken: _authToken,
            orderNo: model.value.orderNumber ?? '',
            phoneNumber: int.parse(val),
            message: _buildBodyMessage(),
          );
          result.fold(
            (left) {
              if (Get.isDialogOpen == true) Get.back();
              alert.error('Error', left);
            },
            (right) {
              if (Get.isDialogOpen == true) Get.back();
              alert.success('Success', 'Send Wa Sucess');
            },
          );
        } catch (e) {
          if (Get.isDialogOpen == true) Get.back();
          alert.error('Error', 'Send Wa Internal Server Error');
        }
      },
      onNewOrder: () {
        Get.back();
      },
    );
  }

  String _buildBodyMessage() {
    String bodyMsg = '';
    bodyMsg += 'Your Ticket';
    // for (var element in selected) {
    //   bodyMsg += 'Product Name : ${element.productName}';
    // }
    return bodyMsg;
  }

  doActiveTicket() {
    // if (model.value.paymentDetail?.pymntStatus == 'P' ||
    //     model.value.orderStatus == 'C') {
    if (parentModel.value.otdtlStatus == 'Y') {
      alert.warning('Warning', 'Sudah melakukan aktifasi tiket');
    } else {
      dialog.dialogActiovcationTicket(
        title: 'Aktivasi Tiket',
        msg: 'Apakah anda yakin akan aktivasi?',
        onNext: (reasonVal) async {
          try {
            if (model.value.orderNumber != null) {
              await createTicketNo(
                orderNo: model.value.orderNumber!,
                reason: reasonVal,
                status: 'P',
              );
              Get.back();
              doBack();
              // await doPrepared();
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
      // dialog.dialogCustomerLeftRight(
      //   title: 'Aktivasi Tiket',
      //   msg: 'Apakah anda yakin akan aktivasi?',
      //   labelLeft: 'No',
      //   labelRight: 'Yes',
      //   onLeft: () {
      //     Get.back();
      //   },
      //   onRight: () async {
      //     Get.back();
      //     try {
      //       if (model.value.orderNumber != null) {
      //         await createTicketNo(model.value.orderNumber!);
      //         await doPrepared();
      //         alert.success('Success', 'Berhasil Aktivasi Tiket');
      //       } else {
      //         alert.error('Error', 'Terjadi Kesalahan , hubungi admin');
      //       }
      //     } catch (e) {
      //       logger.safeLog(e);
      //       alert.error('Error', 'Terjadi Kesalahan , hubungi admin');
      //     }
      //   },
      // );
    }
  }

  doVerifiedPrintTicket() {
    bool isValid = true;
    // if (model.value.paymentDetail?.pymntStatus != 'P' &&
    //     model.value.orderStatus != 'C') {
    if (parentModel.value.otdtlStatus != 'Y') {
      alert.warning('Warning',
          'Tidak bisa melakukan print tiket, Karena tiket belum aktif');
      isValid = false;
    }
    return isValid;
  }

  doPrintTicket() async {
    try {
      if (doVerifiedPrintTicket()) {
        if (printerUtil.currPrinter != null) {
          List<ResponseCreateTicketNoEntity> listCreateTicket = [];
          if (model.value.orderNumber != null) {
            listCreateTicket = await createTicketNo(
              orderNo: model.value.orderNumber!,
              status: 'C',
            );
          } else {
            alert.error('Error', 'Terjadi Kesalahan , silahkan hubungi admin');
            return;
          }

          String locationName = "";
          UserEntity? user = await common.getUser(
            authToken: _authToken,
          );
          if (user != null) {
            locationName = user.locationName!;
          }

          List<int> data = [];
          if (listCreateTicket.isNotEmpty) {
            int count = 1;
            int totalPak = listCreateTicket.length;
            String reffNo = model.value.paymentDetail?.pymntReffno ?? '';
            for (var element in listCreateTicket) {
              // String reffNo = element.ticketNo ?? '';
              List<int> dataPrint = await generatePrintUtil.dataGatePrint(
                locationName: locationName,
                paperSize: PaperSize.mm80,
                orderNo: parentModel.value.orderNumber ?? '',
                reffNo: reffNo,
                pakOf: count,
                pakTotal: totalPak,
                qrCode: element.ticketNo!,
                // expiredAt: dateTimeUtil.now(format: dateFormat.dateDDMMMMYYYY),
                expiredAt: dateTimeUtil.getFormattedDate(
                  date: element.ticketActiveDate!.toLocal(),
                  format: dateFormat.dateDDMMMMYYYY,
                ),
                ticketName: element.ticketName,
                paymentDate: parentModel.value.orderDate ?? DateTime.now(),
              );
              data.addAll(dataPrint);
              count++;
            }
            await printerUtil.print(printerUtil.currPrinter!, data);
          } else {
            alert.error('Error', 'Data Empty');
          }
        } else {
          alert.error('Error', 'please check connection printer');
          printerUtil.connectPrinter();
        }
      }
    } catch (e) {
      logger.safeLog(e);
      alert.error('Error', 'Terjadi Kesalahan , hubungi admin');
    }
  }

  Future<List<ResponseCreateTicketNoEntity>> createTicketNo({
    required String orderNo,
    String? reason,
    required String status,
  }) async {
    try {
      List<ResponseCreateTicketNoEntity> dataList = [];
      var result = await _service.order.orderService.createTicketNo(
        authToken: _authToken,
        reffNo: orderNo,
        status: status,
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
