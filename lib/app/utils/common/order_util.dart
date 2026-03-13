import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:get/get.dart';
import 'package:either_dart/either.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/common/display_util.dart';
import 'package:jaya_propertiy/app/utils/common/generate_member_print_util.dart';
import 'package:jaya_propertiy/app/utils/common/generate_print_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/printer_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/app/utils/constant/date_format_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/customer/customer_display_model.dart';
import 'package:jaya_propertiy/data/models/customer/customer_payment_model.dart';
import 'package:jaya_propertiy/data/models/order/order_member_model.dart';
import 'package:jaya_propertiy/data/models/order/order_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/auth/auth_token.dart';
import 'package:jaya_propertiy/domain/entities/auth/user_entity.dart';
import 'package:jaya_propertiy/domain/entities/order/response_create_ticket_no_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_dialog.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/cart_member_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/member_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_cart_page_controller.dart';

class OrderUtil {
  final _service = MainService();
  DisplayUtil displayUtil = DisplayUtil();

  showPaymentSuccessAlert(
    AuthToken authToken,
    OrderModel body,
    Rxn<String>? orderNo,
  ) async {
    await _createTicket(authToken, body, orderNo, 'P');
    dialog.paymentQrSuccess(
      title: 'Success Pembayaran Telah Berhasil',
      msg: 'Terimakasih telah menggunakan layanan pembayaran kami.',
      onSendProofOfPayment: () async {
        Get.back();
        loading.popUpLoading();
        await Future.delayed(const Duration(seconds: 1), () {});
        Get.back();
        await _handleSendProofOfPayment(authToken, body, orderNo?.value ?? '');
      },
      onPrint: () async {
        if (printerUtil.currPrinter != null) {
          Get.back();
          loading.popUpLoading();
          await Future.delayed(const Duration(seconds: 1), () {});
          Get.back();
          await _handleOnPrintOrder(authToken, body, orderNo);
        } else {
          alert.error('Error', 'please check connection printer');
          printerUtil.connectPrinter();
        }
      },
    );
  }

  _handleSendProofOfPayment(
    AuthToken authToken,
    OrderModel body,
    String orderNo,
  ) {
    logger.safeLog('_handleSendProofOfPayment ');
    dialog.paymentSendProofOfPayment(
      title: 'Pembayaran Berhasil',
      orderEmailValue: body.orderEmail != ' ' ? body.orderEmail : null,
      orderNoWaValue:
          body.orderPhoneNumber != ' ' ? body.orderPhoneNumber : null,
      // orderNoWaValue: body.orderPhoneNumber,
      onSendEmail: (val) async {
        loading.popUpLoading();
        logger.safeLog('_handleSendProofOfPayment Email : $val');
        try {
          var result = await _service.message.sendEmail(
            authToken: authToken,
            orderNo: orderNo,
            mailTo: val,
            message: 'Thanks For Order ${body.orderReffno}',
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
      onSendWa: (val) async {
        loading.popUpLoading();
        logger.safeLog('_handleSendProofOfPayment WA : $val');
        try {
          var result = await _service.message.sendWa(
            authToken: authToken,
            orderNo: orderNo,
            phoneNumber: int.parse(val),
            message: 'Thanks For Order ${body.orderReffno}',
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
      onNewOrder: _handleNewOrder,
    );
  }

  _handleNewOrder() async {
    Get.back();
    loading.popUpLoading();
    await Future.delayed(const Duration(seconds: 1), () {});
    await orderUtil.doRefreshCustomerDisplay(paymentMethod: PaymentMethod.QRIS);
    await orderUtil.clearOrder();
    Get.back();
  }

  _handleOnPrintOrder(
    AuthToken authToken,
    OrderModel body,
    Rxn<String>? orderNo,
  ) async {
    await _createTicket(authToken, body, orderNo, 'C');
    logger.safeLog('TEST : ${body.toJson()}');

    logger.safeLog('LIST PRINTER : ${printerUtil.currPrinter}');
    printerUtil.connectPrinter();
    if (printerUtil.currPrinter != null) {
      String locationName = "";
      String kasirName = "";
      UserEntity? user = await common.getUser(
        authToken: authToken,
      );
      if (user != null) {
        locationName = user.locationName!;
      }
      kasirName = sessionUtil.getUserName();

      List<int> data = [];
      data = await generatePrintUtil.dataPaymentTiketPrint(
        locationName: locationName,
        kasirName: kasirName,
        paperSize: PaperSize.mm80,
        body: body,
      );
      if (body.listCreateTicket != null) {
        int count = 1;
        int totalPak = body.listCreateTicket!.length;
        String reffNo = body.orderReffno ?? '';
        for (var element in body.listCreateTicket!) {
          // String reffNo = element.ticketNo ?? '';
          List<int> dataPrint = await generatePrintUtil.dataGatePrint(
            locationName: locationName,
            paperSize: PaperSize.mm80,
            orderNo: body.orderNumber ?? '',
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
            paymentDate: body.paymentDate ?? DateTime.now(),
          );
          data.addAll(dataPrint);
          count++;
        }
      }

      Get.back();
      loading.popUpLoading();
      await printerUtil.print(printerUtil.currPrinter!, data);
      await doRefreshCustomerDisplay(
        paymentMethod: PaymentMethod.QRIS,
      );
      await clearOrder();
      Get.back();
    } else {
      alert.error('Error', 'please check connection printer');
      printerUtil.connectPrinter();
    }
  }

  Future<void> _createTicket(AuthToken authToken, OrderModel body,
      Rxn<String>? orderNo, String status) async {
    if (orderNo?.value != null) {
      List<ResponseCreateTicketNoEntity> listCreateTicket =
          await createTicketNo(
        authToken,
        orderNo!.value!,
        status,
      );
      body.paymentDate = DateTime.now();
      body.orderNumber = orderNo.value ?? '';
      body.listCreateTicket = listCreateTicket;
    }
  }

  Future<List<ResponseCreateTicketNoEntity>> createTicketNo(
      AuthToken authToken, String orderNo, String status) async {
    try {
      List<ResponseCreateTicketNoEntity> dataList = [];
      var result = await _service.order.orderService.createTicketNo(
          authToken: authToken, reffNo: orderNo, status: status);

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

  doRefreshCustomerDisplay({required String paymentMethod}) {
    displayUtil.updateSecondDisplay(
      CustomerDisplay(
        key: CustomerDisplayAction.PAYMENT,
        value: CustomerPayment(
          type: paymentMethod,
          isSuccess: false,
        ).toJson(),
      ).toJson(),
    );
  }

  clearOrder() {
    final saleController = Get.find<SaleCartPageController>();
    saleController.clearCartOrder();
  }
}

class OrderMemberUtil {
  final _service = MainService();
  DisplayUtil displayUtil = DisplayUtil();

  showPaymentMemberSuccessAlert(
    AuthToken authToken,
    OrderMemberModel body,
    Rxn<String>? orderNo,
  ) async {
    await _createMemberTicket(authToken, body, orderNo, 'P');
    dialog.paymentQrSuccess(
      title: 'Success Pembayaran Telah Berhasil',
      msg: 'Terimakasih telah menggunakan layanan pembayaran kami.',
      onSendProofOfPayment: () async {
        Get.back();
        loading.popUpLoading();
        await Future.delayed(const Duration(seconds: 1), () {});
        Get.back();
        await _handleSendProofOfPayment(authToken, body, orderNo?.value ?? '');
      },
      onPrint: () async {
        if (printerUtil.currPrinter != null) {
          Get.back();
          loading.popUpLoading();
          await Future.delayed(const Duration(seconds: 1), () {});
          Get.back();
          await _handleOnPrintOrder(authToken, body, orderNo);
        } else {
          alert.error('Error', 'please check connection printer');
          printerUtil.connectPrinter();
        }
      },
    );
  }

  Future<void> _createMemberTicket(AuthToken authToken, OrderMemberModel body,
      Rxn<String>? orderNo, String status) async {
    if (orderNo?.value != null) {
      List<ResponseCreateTicketNoEntity> listCreateTicket =
          await createTicketNo(
        authToken,
        orderNo!.value!,
        status,
      );
      // body.paymentDate = DateTime.now();
      // body.orderNumber = orderNo.value ?? '';
      // body.listCreateTicket = listCreateTicket;
    }
  }

  _handleSendProofOfPayment(
    AuthToken authToken,
    OrderMemberModel body,
    String orderNo,
  ) {
    logger.safeLog('_handleSendProofOfPayment Member');
    dialog.paymentSendProofOfPayment(
      title: 'Pembayaran Berhasil',
      orderEmailValue: body.orderEmail != ' ' ? body.orderEmail : null,
      orderNoWaValue:
          body.orderPhoneNumber != ' ' ? body.orderPhoneNumber : null,
      // orderNoWaValue: body.orderPhoneNumber,
      onSendEmail: (val) async {
        loading.popUpLoading();
        logger.safeLog('_handleSendProofOfPayment Member Email : $val');
        try {
          var result = await _service.message.sendEmail(
            authToken: authToken,
            orderNo: orderNo,
            mailTo: val,
            message: 'Thanks For Order ${body.orderReffno}',
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
      onSendWa: (val) async {
        loading.popUpLoading();
        logger.safeLog('_handleSendProofOfPayment Member WA : $val');
        try {
          var result = await _service.message.sendWa(
            authToken: authToken,
            orderNo: orderNo,
            phoneNumber: int.parse(val),
            message: 'Thanks For Order ${body.orderReffno}',
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
      onNewOrder: _handleNewOrder,
    );
  }

  _handleNewOrder() async {
    Get.back();
    loading.popUpLoading();
    await Future.delayed(const Duration(seconds: 1), () {});
    await doRefreshCustomerDisplay(paymentMethod: PaymentMethod.QRIS);
    await clearOrderMember();
    Get.back();
  }

  _handleOnPrintOrder(
    AuthToken authToken,
    OrderMemberModel body,
    Rxn<String>? orderNo,
  ) async {
    await _createTicket(authToken, body, orderNo, 'C');
    logger.safeLog('TEST : ${body.toJson()}');

    logger.safeLog('LIST PRINTER : ${printerUtil.currPrinter}');
    printerUtil.connectPrinter();
    if (printerUtil.currPrinter != null) {
      String locationName = "";
      String kasirName = "";
      UserEntity? user = await common.getUser(
        authToken: authToken,
      );
      if (user != null) {
        locationName = user.locationName!;
      }
      kasirName = sessionUtil.getUserName();

      List<int> data = [];
      data = await generateMemberPrintUtil.paymentPrint(
        locationName: locationName,
        kasirName: kasirName,
        paperSize: PaperSize.mm80,
        paymentDate: DateTime.now(),
        body: body,
      );

      Get.back();
      loading.popUpLoading();
      await printerUtil.print(printerUtil.currPrinter!, data);
      await doRefreshCustomerDisplay(
        paymentMethod: PaymentMethod.QRIS,
      );
      await clearOrderMember();
      Get.back();
    } else {
      alert.error('Error', 'please check connection printer');
      printerUtil.connectPrinter();
    }
  }

  Future<void> _createTicket(AuthToken authToken, OrderMemberModel body,
      Rxn<String>? orderNo, String status) async {
    if (orderNo?.value != null) {
      List<ResponseCreateTicketNoEntity> listCreateTicket =
          await createTicketNo(
        authToken,
        orderNo!.value!,
        status,
      );
      // body.paymentDate = DateTime.now();
      // body.orderNumber = orderNo.value ?? '';
      // body.listCreateTicket = listCreateTicket;
    }
  }

  Future<List<ResponseCreateTicketNoEntity>> createTicketNo(
      AuthToken authToken, String orderNo, String status) async {
    try {
      List<ResponseCreateTicketNoEntity> dataList = [];
      var result = await _service.order.orderService.createTicketNo(
          authToken: authToken, reffNo: orderNo, status: status);

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

  doRefreshCustomerDisplay({required String paymentMethod}) {
    displayUtil.updateSecondDisplay(
      CustomerDisplay(
        key: CustomerDisplayAction.PAYMENT,
        value: CustomerPayment(
          type: paymentMethod,
          isSuccess: false,
        ).toJson(),
      ).toJson(),
    );
  }

  clearOrderMember() {
    logger.safeLog(':) clearOrderMember :(');
    if (Get.isRegistered<MemberPageController>()) {
      final headerController = Get.find<MemberPageController>();
      headerController.clearAndRefreshMenu();
    }
    if (Get.isRegistered<CartMemberController>()) {
      final headerController = Get.find<CartMemberController>();
      headerController.clearOrder();
    }
  }
}

OrderUtil orderUtil = OrderUtil();
OrderMemberUtil orderMemberUtil = OrderMemberUtil();
