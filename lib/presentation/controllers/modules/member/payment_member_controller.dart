import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/display_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/order_util.dart';
import 'package:jaya_propertiy/app/utils/constant/message_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/customer/customer_display_model.dart';
import 'package:jaya_propertiy/data/models/customer/customer_payment_model.dart';
import 'package:jaya_propertiy/data/models/order/order_member_model.dart';
import 'package:jaya_propertiy/data/models/order/split_payment_leg_model.dart';
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

  /// Split payment: 1 panggilan createOrder berisi 2 leg sekaligus (lihat
  /// [OrderMemberModel.splitPayments]). Kalau salah satu leg QRIS, backend
  /// menahan order 'belum lunas' sampai leg itu dikonfirmasi -- tampilkan
  /// dialog tunggu+QR persis seperti [doPaymentQris], tapi kuncinya
  /// [paymentNo] leg itu sendiri (bukan nomor order). Kalau tidak ada leg
  /// QRIS (mis. cash+EDC), member sudah langsung terdaftar & lunas begitu
  /// createOrder sukses.
  doSplitPayment({required OrderMemberModel body, Rxn<String>? orderNo}) async {
    try {
      loading.popUpLoading();
      var result = await _service.member.createOrder(
        authToken: _authToken,
        body: body,
      );
      Get.back();

      String? msg;
      ResponseOrderEntity? data;
      result.fold(
        (l) {
          logger.safeLog(l);
          msg = l;
        },
        (r) {
          data = r.data;
          orderNo?.value = r.data?.orderNumber;
        },
      );
      if (msg != null && msg!.isNotEmpty) {
        alert.error('Error', msg!);
        return;
      }

      SplitPaymentLegModel? legQris;
      for (final leg in (data?.splitPayments ?? [])) {
        if (leg.qrisUrl != null && leg.qrisUrl!.isNotEmpty) {
          legQris = leg;
          break;
        }
      }

      if (legQris == null) {
        // Tidak ada leg QRIS (mis. cash+EDC) -- member sudah langsung lunas.
        body.orderMemberNo = data?.trnDetailOrderMember?.memberNo;
        body.orderMemberExpiredDate = data?.trnDetailOrderMember?.memberExpiredDate;
        await orderMemberUtil.showPaymentMemberSuccessAlert(
            _authToken, body, orderNo);
        return;
      }

      // Ada leg QRIS -- tunggu konfirmasi sama seperti pembayaran QRIS tunggal.
      orderPaymentNo.value = legQris.paymentNo;
      body.orderReffno = legQris.paymentNo;
      body.qrCode = legQris.qrisUrl;

      await displayUtil.getDisplay();
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
          msg: 'Sebagian pembayaran split ini lewat QRIS. Tagihan sudah '
              'dibuat dan menunggu pembayaran leg ini.',
          onCheck: () => _handlePaymentCheck(body, orderNo),
          onCancle: () => Get.back(),
        );
      } else {
        dialog.waitingPayment(
          title: 'Menunggu Pembayaran',
          msg: 'Sebagian pembayaran split ini lewat QRIS. Tagihan sudah '
              'dibuat dan menunggu pembayaran leg ini.',
          onCheck: () => _handlePaymentCheck(body, orderNo),
          onCancle: () => Get.back(),
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

    /// mst_payment.pymnt_category metode yang dipilih; lihat catatan yang sama
    /// pada OrderPaymentController.doOrderPayment.
    String? paymentCategory,
  }) async {
    try {
      final bool isCash = paymentCategory == PaymentMethod.CASH;

      // Display the waiting payment alert
      await dialog.waitingPaymentEdc(
        title: 'Menunggu Proses Transaksi',
        msg: isCash
            ? 'Masukkan uang yang diterima, lalu lanjutkan.'
            : 'Silahkan mengisi reference',
        showReffInput: !isCash,
        // Samakan dengan transaksi tiket/produk: TUNAI menampilkan kolom
        // "Uang Diterima" + Kembalian yang dihitung live, bukan cuma field
        // reference yang disembunyikan.
        showUangDiterima: isCash,
        totalTagihan: body.totalPrice ?? 0,
        onNext: (val, uangDiterima) async {
          logger.safeLog('isProcessing : $isProcessing');
          if (isProcessing.value) return;
          // Uang tunai yang diterima tidak boleh kurang dari tagihan --
          // ditolak di sini, SEBELUM order dibuat, sama seperti transaksi
          // tiket/produk (lihat OrderPaymentController.doOrderPayment).
          if (isCash &&
              (uangDiterima == null || uangDiterima < (body.totalPrice ?? 0))) {
            alert.error(
              'Uang Diterima Kurang',
              'Uang yang diterima harus minimal sebesar total tagihan '
                  '(${common.currencyFormat(body.totalPrice ?? 0)}).',
            );
            return;
          }
          isProcessing.value = true;
          // Tunai tidak punya nomor reference, tetapi backend pendaftaran member
          // menolak orderReffno null ("Reffno tidak boleh null"), jadi diisi '-'.
          final String reffNo = isCash ? '-' : val;
          if (reffNo != '') {
            body.orderReffno = reffNo;
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
