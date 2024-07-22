import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/display_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/message_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/customer/customer_display_model.dart';
import 'package:jaya_propertiy/data/models/customer/customer_payment_model.dart';
import 'package:jaya_propertiy/data/models/order/order_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';
import 'package:jaya_propertiy/presentation/controllers/common/payment_print_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/common/print_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_cart_page_controller.dart';

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
      await _doCreateOrderQr(body: body, orderNo: orderNo);
      // Display the waiting payment alert
      if (orderPaymentNo.value == null) {
        alert.error('Payment Error', 'Terjadi Kesalahan');
        return;
      }
      alert.waitingPayment(
        title: 'Menunggu Pembayaran',
        msg:
            'Tagihan anda telah dibuat dan sekarang menunggu pembayaran.\nKami membuatnya mudah bagi anda untuk menyelesaikan\npembayaran dengan cepat',
        onCheck: () => _handlePaymentCheck(body),
        onCancle: () => Get.back(),
      );
    } catch (e) {
      logger.safeLog(e);
      alert.error('Error', 'Unexpected Error');
    }
  }

  Future<bool> _checkPaymentStatus() async {
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
        },
      );
      return isSuccess;
    } catch (e) {
      logger.safeLog(e);
      alert.error("Cek Payment", 'Terjadi Kesalahan');
      return false;
    }
  }

  _handlePaymentCheck(OrderModel body) async {
    try {
      var isSuccess = await _checkPaymentStatus();
      if (isSuccess) {
        Get.back();
        _showPaymentSuccessAlert(body);
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

  _showPaymentSuccessAlert(OrderModel body) {
    alert.paymentQrSuccess(
      title: 'Success Pembayaran Telah Berhasil',
      msg: 'Terimakasih telah menggunakan layanan pembayaran kami.',
      onSendProofOfPayment: () => _handleSendProofOfPayment(body),
      onPrint: () => _handleOnPrintOrder(body),
    );
  }

  _handleOnPrintOrder(OrderModel body) async {
    var printController = Get.put(PrintController());
    var paymentPrintController = Get.put(PaymentPrintController());
    await _printPaymentTiket(body, printController, paymentPrintController);
    await _doRefreshCustomerDisplay(paymentMethod: PaymentMethod.QRIS);
    await _clearOrder();
  }

  _printPaymentTiket(
    OrderModel body,
    PrintController printController,
    PaymentPrintController paymentPrintController,
  ) async {
    bool isConnectPrinter = await printController.isConnect();
    if (isConnectPrinter) {
      List<int> data = await paymentPrintController.dataPaymentTiketPrint(
        paperSize: PaperSize.mm80,
        body: body,
      );
      loading.popUpLoading();
      bool isPrinted = await printController.printTicket(
        data: data,
      );
      logger.safeLog('isPrinted : $isPrinted');
      if (isPrinted) {
        Get.back();
        Get.back();
      } else {
        await _printPaymentTiket(body, printController, paymentPrintController);
      }
    } else {
      alert.selectPrint(
        title: 'Select Printer',
        msg: 'Silahkan Pilih printer',
        onPrint: () async {
          await _printPaymentTiket(
            body,
            printController,
            paymentPrintController,
          );
        },
      );
    }
  }

  _handleSendProofOfPayment(OrderModel body) {
    Get.back();
    alert.paymentSendProofOfPayment(
      title: 'Pembayaran Berhasil',
      onSendEmail: (val) {
        logger.safeLog('Email : ${val}');
        var result = _service.message.sendWa(
          authToken: _authToken,
          phoneNumber: int.parse(val),
          message: 'Thanks For Order ${body.toJson()}',
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
          message: 'Thanks For Order ${body.toJson()}',
        );
        result.fold(
          (left) => alert.error('Error', 'Send Wa Internal Server Error'),
          (right) => alert.success('Success', 'Send Wa Sucess'),
        );
      },
      onNewOrder: _handleNewOrder,
    );
  }

  _handleNewOrder() {
    Get.back();
    Timer(Duration(seconds: 3), () {
      Get.dialog(
        loading.simpleLoading(),
        barrierDismissible: false,
      );
      Get.back();
      _doRefreshCustomerDisplay(paymentMethod: PaymentMethod.QRIS);
      _clearOrder();
    });
  }

  _doCreateOrderQr({required OrderModel body, Rxn<String>? orderNo}) async {
    try {
      var result = await _service.order.orderService.createOrder(
        authToken: _authToken,
        body: body,
        reffNo: orderNo?.value,
      );

      result.fold(
        (l) {
          logger.safeLog(l);
          logger.safeLog('Create Order Error 1');
          alert.error('Error', 'Terjadi Kesalahan!');
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
        },
      );
    } catch (e) {
      logger.safeLog(e);
      logger.safeLog('Create Order Error 2');
      alert.error('Error', 'Terjadi Kesalahan!');
    }
  }

  _doRefreshCustomerDisplay({required String paymentMethod}) {
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

  _clearOrder() {
    final saleController = Get.find<SaleCartPageController>();
    saleController.clearCartOrder();
  }
}

class OrderPaymentController extends GetxController {
  OrderPaymentController();
  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];

  doOrderPayment({required OrderModel body, Rxn<String>? orderNo}) {
    try {
      // Display the waiting payment alert
      alert.waitingPaymentEdc(
        title: 'Menunggu Proses Transaksi',
        msg: 'Silahkan mengisi reference',
        onNext: (val) async {
          // create Order and waiting the prosess of payment
          logger.safeLog('val : $val');
          if (val != '') {
            body.orderReffno = val;
            doCreateOrderPayment(body: body);

            final saleController = Get.find<SaleCartPageController>();
            saleController.clearCartOrder();
            Get.back();

            alert.success('Success', 'Payment Success');
          } else {
            alert.error(
              'Error',
              messagesConstant.requiredField('Nomor Refference'),
            );
          }
        },
      );
    } catch (e) {
      logger.safeLog(e);
      alert.error('Error', 'Unexpected Error');
    }
  }

  doCreateOrderPayment({required OrderModel body, Rxn<String>? orderNo}) async {
    try {
      var result;
      result = await _service.order.orderService.createOrder(
        authToken: _authToken,
        body: body,
        reffNo: orderNo?.value,
      );

      result.fold(
        (l) {
          logger.safeLog(l);
          logger.safeLog('Create Order Error 1');
          alert.error('Error', 'Terjadi Kesalahan!');
        },
        (r) {
          logger.safeLog('Create Order Success');
          logger.safeLog(r.data);
          orderNo?.value = r.data?.orderNumber;
        },
      );
    } catch (e) {
      logger.safeLog(e);
      logger.safeLog('Create Order Error 2');
      alert.error('Error', 'Terjadi Kesalahan!');
    }
  }
}
