import 'dart:async';

import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/display_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/order_util.dart';
import 'package:jaya_propertiy/app/utils/constant/message_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/customer/customer_display_model.dart';
import 'package:jaya_propertiy/data/models/customer/customer_payment_model.dart';
import 'package:jaya_propertiy/data/models/order/order_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_dialog.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';

class OrderController extends GetxController {
  OrderController();
  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];
  DisplayUtil displayUtil = DisplayUtil();

  final orderPaymentNo = Rxn<String>(null);

  doPaymentQris({required OrderModel body, Rxn<String>? orderNo}) async {
    try {
      // create Order and waiting the prosess of payment
      loading.popUpLoading();
      String? msg = await _doCreateOrderQr(body: body, orderNo: orderNo);
      Get.back();
      if (msg != null && msg.isNotEmpty) {
        logger.safeLog('message : $msg');
        alert.error('Error', msg);
        return;
      }
      // Display the waiting payment alert
      if (orderPaymentNo.value == null) {
        alert.error('Payment Error', 'Terjadi Kesalahan');
        return;
      }

      await displayUtil.getDisplay();
      logger.safeLog('QR CODE : ${body.qrCode}');
      logger.safeLog('DISPLAY L : ${displayUtil.displays.length}');
      if (displayUtil.displays.length == 1) {
        await displayUtil.updateSecondDisplay(
          CustomerDisplay(
            key: CustomerDisplayAction.PAYMENT,
            value: CustomerPayment(
              orderNo: orderNo?.value,
              qrCode: body.qrCode,
              type: PaymentMethod.QRIS,
              isSuccess: false,
            ).toJson(),
          ).toJson(),
        );

        dialog.waitingPaymentWithQr(
          title: 'Menunggu Pembayaran',
          qrCode: body.qrCode,
          msg:
              'Tagihan anda telah dibuat dan sekarang menunggu pembayaran.\nKami membuatnya mudah bagi anda untuk menyelesaikan\npembayaran dengan cepat',
          onCheck: () => _handlePaymentCheck(body, orderNo),
          onCancle: () {
            Get.back();
          },
        );
      } else {
        dialog.waitingPayment(
          title: 'Menunggu Pembayaran',
          msg:
              'Tagihan anda telah dibuat dan sekarang menunggu pembayaran.\nKami membuatnya mudah bagi anda untuk menyelesaikan\npembayaran dengan cepat',
          onCheck: () => _handlePaymentCheck(body, orderNo),
          onCancle: () {
            Get.back();
          },
        );
      }
    } catch (e) {
      logger.safeLog(e);
      alert.error('Error', 'Unexpected Error');
    }
  }

  Future<bool> _checkPaymentStatus(OrderModel body) async {
    try {
      bool isSuccess = false;
      var result = await _service.payment.paymentOrderSercvice.cekPaymnet(
        authToken: _authToken,
        orderNo: orderPaymentNo.value!,
      );
      result.fold(
        (l) {
          logger.safeLog(l);
          logger.safeLog('Cek Payment Error 1');
          alert.error('Error', 'Terjadi Kesalahan!');
        },
        (r) {
          logger.safeLog('Create Order Success');
          logger.safeLog(r.data?.toJson());
          isSuccess = r.data?.status == PaymentStatus.Success;
          // body.listCreateTicket = r.data?.listTicket;
        },
      );
      return isSuccess;
    } catch (e) {
      logger.safeLog(e);
      alert.error("Cek Payment", 'Terjadi Kesalahan');
      return false;
    }
  }

  _handlePaymentCheck(
    OrderModel body,
    Rxn<String>? orderNo,
  ) async {
    try {
      var isSuccess = await _checkPaymentStatus(body);
      if (isSuccess) {
        Get.back();
        orderUtil.showPaymentSuccessAlert(_authToken, body, orderNo);
        // _showPaymentSuccessAlert(body);
        displayUtil.updateSecondDisplay(
          CustomerDisplay(
            key: CustomerDisplayAction.PAYMENT,
            value: CustomerPayment(
              type: PaymentMethod.QRIS,
              isSuccess: true,
            ).toJson(),
          ).toJson(),
        );
      } else {
        alert.warning('Warning', 'Payment In Process');
      }
    } catch (e) {
      logger.safeLog(e);
      alert.error('Error', 'Payment Error');
    }
  }

  Future<String?> _doCreateOrderQr(
      {required OrderModel body, Rxn<String>? orderNo}) async {
    try {
      var result = await _service.order.orderService.createOrder(
        authToken: _authToken,
        body: body,
        // reffNo: orderNo?.value,
      );

      String? msg;

      result.fold(
        (l) {
          logger.safeLog(l);
          logger.safeLog('Create Order Error 1');
          // alert.error('Error', l);
          msg = l;
        },
        (r) {
          logger.safeLog('Create Order Success');
          logger.safeLog(r.data);

          displayUtil.updateSecondDisplay(
            CustomerDisplay(
              key: CustomerDisplayAction.PAYMENT,
              value: CustomerPayment(
                type: PaymentMethod.QRIS,
                qrCode: r.data?.qrisUrl,
                isSuccess: false,
              ).toJson(),
            ).toJson(),
          );

          orderNo?.value = r.data?.orderNumber;
          orderPaymentNo.value = r.data?.orderPaymentNo;
          body.orderReffno = r.data?.orderPaymentNo;
          body.qrCode = r.data?.qrisUrl;
        },
      );
      return Future.value(msg);
    } catch (e) {
      logger.safeLog(e);
      logger.safeLog('Create Order Error 2');
      // alert.error('Error', e.toString());
      return e.toString();
    }
  }
}

class OrderPaymentController extends GetxController {
  OrderPaymentController();
  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];
  var isProcessing = false.obs;

  doOrderPayment({required OrderModel body, Rxn<String>? orderNo}) async {
    try {
      // validation on create order service
      bool isSuccess = await doPreCreateOrderPayment(
        body: body,
        check: "N",
      );
      if (!isSuccess) return;

      // Display the waiting payment alert
      dialog.waitingPaymentEdc(
        title: 'Menunggu Proses Transaksi',
        msg: 'Silahkan mengisi reference',
        onNext: (val) async {
          logger.safeLog('isProcessing : $isProcessing');
          if (isProcessing.value) return;
          isProcessing.value = true;
          // create Order and waiting the prosess of payment
          // logger.safeLog('val : $val');
          if (val != '') {
            body.orderReffno = val;
            bool isSuccess = await _doCreateOrderPayment(
              body: body,
              orderNo: orderNo,
            );
            if (isSuccess) {
              await displayUtil.updateSecondDisplay(
                CustomerDisplay(
                  key: CustomerDisplayAction.PAYMENT,
                  value: CustomerPayment(
                    orderNo: orderNo?.value,
                    type: PaymentMethod.QRIS,
                    isSuccess: false,
                  ).toJson(),
                ).toJson(),
              );

              Get.back();
              loading.popUpLoading();
              await Future.delayed(const Duration(seconds: 1), () {});
              Get.back();
              // await orderUtil.handleOnPrintOrder(body);
              await orderUtil.showPaymentSuccessAlert(
                  _authToken, body, orderNo);
              // alert.success('Success', 'Payment Success');

              // isProcessing.value = false;
            }
            isProcessing.value = false;
          } else {
            alert.error(
              'Error',
              messagesConstant.requiredField('Nomor Refference'),
            );
            isProcessing.value = false;
          }
        },
      );
    } catch (e) {
      logger.safeLog(e);
      alert.error('Error', 'Unexpected Error');
      isProcessing.value = false;
    }
  }

  Future<bool> doPreCreateOrderPayment({
    required OrderModel body,
    required String check,
  }) async {
    try {
      var result;
      result = await _service.order.orderService.preCreateOrder(
        authToken: _authToken,
        body: body,
        check: check,
      );

      bool isSuccess = false;
      result.fold(
        (l) {
          logger.safeLog(l);
          logger.safeLog('Pre Create Order Error 1');
          // alert.error('Error', 'Terjadi Kesalahan!');
          alert.error('Error', l);
          isSuccess = false;
        },
        (r) {
          logger.safeLog('Pre Create Order Success');
          logger.safeLog(r.data);
          // orderNo?.value = r.data?.orderNumber;
          isSuccess = true;
        },
      );
      return Future.value(isSuccess);
    } catch (e) {
      logger.safeLog(e);
      logger.safeLog('Create Order Error 2');
      alert.error('Error', 'Terjadi Kesalahan!');
      return Future.value(false);
    }
  }

  Future<bool> _doCreateOrderPayment({
    required OrderModel body,
    Rxn<String>? orderNo,
  }) async {
    try {
      var result;
      result = await _service.order.orderService.createOrder(
        authToken: _authToken,
        body: body,
        reffNo: orderNo?.value,
      );

      bool isSuccess = false;
      result.fold(
        (l) {
          logger.safeLog(l);
          logger.safeLog('Create Order Error 1');
          // alert.error('Error', 'Terjadi Kesalahan!');
          alert.error('Error', l);
          isSuccess = false;
        },
        (r) {
          logger.safeLog('Create Order Success');
          logger.safeLog(r.data);
          orderNo?.value = r.data?.orderNumber;
          isSuccess = true;
        },
      );
      return Future.value(isSuccess);
    } catch (e) {
      logger.safeLog(e);
      logger.safeLog('Create Order Error 2');
      alert.error('Error', 'Terjadi Kesalahan!');
      return Future.value(false);
    }
  }
}

// class OrderUtil {
//   final _service = MainService();
//   DisplayUtil displayUtil = DisplayUtil();

//   showPaymentSuccessAlert(
//     AuthToken authToken,
//     OrderModel body,
//     Rxn<String>? orderNo,
//   ) async {
//     await _createTicket(authToken, body, orderNo, 'P');
//     dialog.paymentQrSuccess(
//       title: 'Success Pembayaran Telah Berhasil',
//       msg: 'Terimakasih telah menggunakan layanan pembayaran kami.',
//       onSendProofOfPayment: () async {
//         Get.back();
//         loading.popUpLoading();
//         await Future.delayed(const Duration(seconds: 1), () {});
//         Get.back();
//         await _handleSendProofOfPayment(authToken, body);
//       },
//       onPrint: () async {
//         if (printerUtil.currPrinter != null) {
//           Get.back();
//           loading.popUpLoading();
//           await Future.delayed(const Duration(seconds: 1), () {});
//           Get.back();
//           await _handleOnPrintOrder(authToken, body, orderNo);
//         } else {
//           alert.error('Error', 'please check connection printer');
//           printerUtil.connectPrinter();
//         }
//       },
//     );
//   }

//   _handleSendProofOfPayment(
//     AuthToken authToken,
//     OrderModel body,
//   ) {
//     logger.safeLog('NO WA : ${body.orderPhoneNumber}');
//     logger.safeLog('EMAIL : ${body.orderEmail}');
//     dialog.paymentSendProofOfPayment(
//       title: 'Pembayaran Berhasil',
//       orderEmailValue: body.orderEmail != ' ' ? body.orderEmail : null,
//       orderNoWaValue:
//           body.orderPhoneNumber != ' ' ? body.orderPhoneNumber : null,
//       // orderNoWaValue: body.orderPhoneNumber,
//       onSendEmail: (val) {
//         logger.safeLog('Email : ${val}');
//         var result = _service.message.sendEmail(
//           authToken: authToken,
//           phoneNumber: int.parse(val),
//           message: 'Thanks For Order ${body.orderReffno}',
//         );
//         result.fold(
//           (left) => alert.error('Error', 'Send Wa Internal Server Error'),
//           (right) => alert.success('Success', 'Send Wa Sucess'),
//         );
//       },
//       onSendWa: (val) {
//         logger.safeLog('WA : ${val}');
//         var result = _service.message.sendWa(
//           authToken: authToken,
//           phoneNumber: int.parse(val),
//           message: 'Thanks For Order ${body.orderReffno}',
//         );
//         result.fold(
//           (left) => alert.error('Error', 'Send Wa Internal Server Error'),
//           (right) => alert.success('Success', 'Send Wa Sucess'),
//         );
//       },
//       onNewOrder: _handleNewOrder,
//     );
//   }

//   _handleNewOrder() async {
//     Get.back();
//     loading.popUpLoading();
//     await Future.delayed(const Duration(seconds: 1), () {});
//     await orderUtil.doRefreshCustomerDisplay(paymentMethod: PaymentMethod.QRIS);
//     await orderUtil.clearOrder();
//     Get.back();
//   }

//   _handleOnPrintOrder(
//     AuthToken authToken,
//     OrderModel body,
//     Rxn<String>? orderNo,
//   ) async {
//     await _createTicket(authToken, body, orderNo, 'C');
//     logger.safeLog('TEST : ${body.toJson()}');

//     logger.safeLog('LIST PRINTER : ${printerUtil.currPrinter}');
//     printerUtil.connectPrinter();
//     if (printerUtil.currPrinter != null) {
//       String locationName = "";
//       String kasirName = "";
//       UserEntity? user = await common.getUser(
//         authToken: authToken,
//       );
//       if (user != null) {
//         locationName = user.locationName!;
//       }
//       kasirName = sessionUtil.getUserName();

//       List<int> data = [];
//       data = await generatePrintUtil.dataPaymentTiketPrint(
//         locationName: locationName,
//         kasirName: kasirName,
//         paperSize: PaperSize.mm80,
//         body: body,
//       );
//       if (body.listCreateTicket != null) {
//         int count = 1;
//         int totalPak = body.listCreateTicket!.length;
//         String reffNo = body.orderReffno ?? '';
//         for (var element in body.listCreateTicket!) {
//           // String reffNo = element.ticketNo ?? '';
//           List<int> dataPrint = await generatePrintUtil.dataGatePrint(
//             locationName: locationName,
//             paperSize: PaperSize.mm80,
//             orderNo: body.orderNumber ?? '',
//             reffNo: reffNo,
//             pakOf: count,
//             pakTotal: totalPak,
//             qrCode: element.ticketNo!,
//             // expiredAt: dateTimeUtil.now(format: dateFormat.dateDDMMMMYYYY),
//             expiredAt: dateTimeUtil.getFormattedDate(
//               date: element.ticketActiveDate!.toLocal(),
//               format: dateFormat.dateDDMMMMYYYY,
//             ),
//             ticketName: element.ticketName,
//             paymentDate: body.paymentDate ?? DateTime.now(),
//           );
//           data.addAll(dataPrint);
//           count++;
//         }
//       }

//       Get.back();
//       loading.popUpLoading();
//       await printerUtil.print(printerUtil.currPrinter!, data);
//       await doRefreshCustomerDisplay(
//         paymentMethod: PaymentMethod.QRIS,
//       );
//       await clearOrder();
//       Get.back();
//     } else {
//       alert.error('Error', 'please check connection printer');
//       printerUtil.connectPrinter();
//     }
//   }

//   Future<void> _createTicket(AuthToken authToken, OrderModel body,
//       Rxn<String>? orderNo, String status) async {
//     if (orderNo?.value != null) {
//       List<ResponseCreateTicketNoEntity> listCreateTicket =
//           await createTicketNo(
//         authToken,
//         orderNo!.value!,
//         status,
//       );
//       body.paymentDate = DateTime.now();
//       body.orderNumber = orderNo.value ?? '';
//       body.listCreateTicket = listCreateTicket;
//     }
//   }

//   Future<List<ResponseCreateTicketNoEntity>> createTicketNo(
//       AuthToken authToken, String orderNo, String status) async {
//     try {
//       List<ResponseCreateTicketNoEntity> dataList = [];
//       var result = await _service.order.orderService.createTicketNo(
//           authToken: authToken, reffNo: orderNo, status: status);

//       result.fold(
//         (l) {
//           logger.safeLog(l);
//           logger.safeLog('Create Ticket No Error 1');
//           alert.error('Error', 'Terjadi Kesalahan!');
//         },
//         (r) {
//           logger.safeLog('Create Ticket No Success');
//           logger.safeLog(r);
//           dataList = r;
//         },
//       );
//       return dataList;
//     } catch (e) {
//       logger.safeLog('Create Ticket No Error 2');
//       logger.safeLog(e.toString());
//       return [];
//     }
//   }

//   doRefreshCustomerDisplay({required String paymentMethod}) {
//     displayUtil.updateSecondDisplay(
//       CustomerDisplay(
//         key: CustomerDisplayAction.PAYMENT,
//         value: CustomerPayment(
//           type: paymentMethod,
//           isSuccess: false,
//         ).toJson(),
//       ).toJson(),
//     );
//   }

//   clearOrder() {
//     final saleController = Get.find<SaleCartPageController>();
//     saleController.clearCartOrder();
//   }
// }

// OrderUtil orderUtil = OrderUtil();
