import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/display_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/order_util.dart';
import 'package:jaya_propertiy/app/utils/constant/message_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/customer/customer_display_model.dart';
import 'package:jaya_propertiy/data/models/customer/customer_payment_model.dart';
import 'package:jaya_propertiy/data/models/order/order_member_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/order/response_order_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_dialog.dart';
import 'package:jaya_propertiy/presentation/components/custom_loading.dart';

class PaymentMemberController extends GetxController {
  PaymentMemberController();
  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];
  DisplayUtil displayUtil = DisplayUtil();
  var isProcessing = false.obs;

  final orderPaymentNo = Rxn<String>(null);

  Future<bool> _checkPaymentStatus(OrderMemberModel body) async {
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
    OrderMemberModel body,
    Rxn<String>? orderNo,
  ) async {
    try {
      var isSuccess = await _checkPaymentStatus(body);
      if (isSuccess) {
        Get.back();
        orderMemberUtil.showPaymentMemberSuccessAlert(
            _authToken, body, orderNo);
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

  doPaymentQris({required OrderMemberModel body, Rxn<String>? orderNo}) async {
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

  Future<String?> _doCreateOrderQr(
      {required OrderMemberModel body, Rxn<String>? orderNo}) async {
    try {
      var result = await _service.member.createOrder(
        authToken: _authToken,
        body: body,
        // reffNo: orderNo?.value,
      );

      String? msg;

      result.fold(
        (l) {
          logger.safeLog(l);
          logger.safeLog('_doCreateOrderQr Error 1');
          // alert.error('Error', l);
          msg = l;
        },
        (r) {
          logger.safeLog('_doCreateOrderQr QRIS Success');
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
          ResponseOrderEntity? responsePaymentMember = r.data;
          orderNo?.value = responsePaymentMember?.orderNumber;
          orderPaymentNo.value = responsePaymentMember?.orderPaymentNo;
          body.orderReffno = responsePaymentMember?.orderPaymentNo;
          body.orderMemberNo =
              responsePaymentMember?.trnDetailOrderMember?.memberNo;
          body.orderMemberExpiredDate =
              responsePaymentMember?.trnDetailOrderMember?.memberExpiredDate;
          body.qrCode = responsePaymentMember?.qrisUrl;
        },
      );
      return Future.value(msg);
    } catch (e) {
      logger.safeLog(e);
      logger.safeLog('_doCreateOrderQr Error 2');
      // alert.error('Error', e.toString());
      return e.toString();
    }
  }

  // =========================================== EDC PAYMENT
  //
  Future<void> doOrderPaymentReffNo({
    required OrderMemberModel body,
    Rxn<String>? orderNo,
  }) async {
    try {
      // Display the waiting payment alert
      await dialog.waitingPaymentEdc(
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
              await orderMemberUtil.showPaymentMemberSuccessAlert(
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

  Future<bool> _doCreateOrderPayment({
    required OrderMemberModel body,
    Rxn<String>? orderNo,
  }) async {
    try {
      var result;
      result = await _service.member.createOrder(
        authToken: _authToken,
        body: body,
        reffNo: orderNo?.value,
      );

      bool isSuccess = false;
      result.fold(
        (l) {
          logger.safeLog(l);
          logger.safeLog('_doCreateOrderPayment Error 1');
          // alert.error('Error', 'Terjadi Kesalahan!');
          alert.error('Error', l);
          isSuccess = false;
        },
        (r) {
          logger.safeLog('_doCreateOrderPayment Success');
          logger.safeLog(r.data);
          ResponseOrderEntity? responsePaymentMember = r.data;
          orderNo?.value = responsePaymentMember?.orderNumber;
          body.orderMemberNo =
              responsePaymentMember?.trnDetailOrderMember?.memberNo;
          body.orderMemberExpiredDate =
              responsePaymentMember?.trnDetailOrderMember?.memberExpiredDate;
          isSuccess = true;
        },
      );
      return Future.value(isSuccess);
    } catch (e) {
      logger.safeLog(e);
      logger.safeLog('_doCreateOrderPayment Error 2');
      alert.error('Error', 'Terjadi Kesalahan!');
      return Future.value(false);
    }
  }
}
