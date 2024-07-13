import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/display_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/app/utils/constant/message_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/cart/cart_addon_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_ticket_mode.dart';
import 'package:jaya_propertiy/data/models/cart/cart_voucher_model.dart';
import 'package:jaya_propertiy/data/models/order/order_addon_model.dart';
import 'package:jaya_propertiy/data/models/order/order_model.dart';
import 'package:jaya_propertiy/data/models/order/order_ticket_model.dart';
import 'package:jaya_propertiy/data/models/order/order_voucher_model.dart';
import 'package:jaya_propertiy/domain/entities/common/custom_id_name_entity.dart';
import 'package:jaya_propertiy/domain/entities/order/response_order_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/order/order_controller.dart';

class SalePageController extends GetxController {
  SalePageController();
  // final _service = MainService();
  DisplayUtil displayUtil = DisplayUtil();
  // final _authToken = Get.arguments[argConstant.authToken];

  final openPayment = RxBool(false);

  var tabIndex = 0.obs;
  void changeTabIndex(int index) {
    tabIndex.value = index;
  }

  final orderNameController = TextEditingController();
  final emailController = TextEditingController();
  final noWaController = TextEditingController();
  final referenceIdController = TextEditingController();
  final paymentType = <CustomIdNameEntity>[].obs;
  final selectedPaymentType = CustomIdNameEntity().obs;

  // final showReffId = true.obs;

  final totalOrderQty = RxInt(0);
  final totalOrderAmnt = RxDouble(0);
  final addonList = RxList<CartAddon>([]);
  final ticketList = RxList<CartTicket>([]);
  final voucherList = RxList<CartVoucher>([]);

  var orderEntity = Rxn<ResponseOrderEntity>(null);

  doSelectPaymentType(CustomIdNameEntity value) {
    selectedPaymentType.value = value;
    // showReffId.value =
    //     value.id != PaymentMethod.QRIS && value.id != PaymentMethod.EDC;
    update();
  }

  doPrepared() {
    // showReffId.value = true;
    totalOrderAmnt.value = totalOrderAmnt.value;
    doInitialValueDropdown();
  }

  doInitialValueDropdown() {
    paymentType.clear();
    paymentType.insert(
      0,
      CustomIdNameEntity(
        id: null,
        name: ' --- Pilih Pembayaran --- ',
      ),
    );
    paymentType.insert(
      1,
      CustomIdNameEntity(
        id: PaymentMethod.QRIS,
        name: 'Qris',
      ),
    );
    paymentType.insert(
      2,
      CustomIdNameEntity(
        id: PaymentMethod.EDC,
        name: 'EDC',
      ),
    );
    paymentType.insert(
      3,
      CustomIdNameEntity(
        id: PaymentMethod.TRAVELOKA,
        name: 'Traveloka',
      ),
    );
    paymentType.insert(
      4,
      CustomIdNameEntity(
        id: PaymentMethod.TICKET,
        name: 'Tiket',
      ),
    );
    selectedPaymentType.value = paymentType.first;
  }

  bool doVerifyRequest() {
    bool isValid = true;
    if (isValid && orderNameController.text.isEmpty) {
      isValid = false;
      alert.error(
          "Terjadi Kesalahan!", messagesConstant.requiredField("Name Pemesan"));
    }

    if (isValid && emailController.text.isEmpty) {
      isValid = false;
      alert.error(
          "Terjadi Kesalahan!", messagesConstant.requiredField("Email"));
    }
    if (isValid && noWaController.text.isEmpty) {
      isValid = false;
      alert.error(
          "Terjadi Kesalahan!", messagesConstant.requiredField("No Wa"));
    }
    if (isValid && selectedPaymentType.value.id == null) {
      isValid = false;
      alert.error('Warning', 'Pilih Pembayaran terlebih dahulu!');
    }
    if (isValid && selectedPaymentType.value.id == PaymentMethod.TICKET ||
        selectedPaymentType.value.id == PaymentMethod.TRAVELOKA) {
      if (isValid && referenceIdController.text.isEmpty) {
        isValid = false;
        alert.error("Terjadi Kesalahan!",
            messagesConstant.requiredField("Refference ID"));
      }
    }
    return isValid;
  }

  doPayment() {
    if (doVerifyRequest()) {
      final OrderController orderController = Get.put(OrderController());
      if (selectedPaymentType.value.id == PaymentMethod.QRIS) {
        orderController.doPaymentQris(
          body: getBodyOrder(),
        );
        // doPaymentQris();
      } else if (selectedPaymentType.value.id == PaymentMethod.EDC) {
        orderController.doPaymentEdc(
          body: getBodyOrder(),
        );
        // doPaymentEdc();
      } else {
        alert.error('Error', 'Please please select payment method');
      }
    }
  }

  // doPaymentQris() async {
  //   alert.waitingPayment(
  //     title: 'Menunggu Pembayaran',
  //     msg:
  //         'Tagihan anda telah di buat dan sekarang menunggu pembayaran.\nKami membuatnya mudah bagi anda untuk menyelesaikan\npembayaran dengan cepat',
  //     onCheck: () {
  //       // Get.back();
  //       // cek payment
  //       try {
  //         var isSuccess = true;
  //         if (isSuccess) {
  //           Get.back();
  //           alert.paymentQrSuccess(
  //               title: 'Success Pembayaran Telah Berhasil',
  //               msg: 'Terimakasih telah menggunakan layanan pembayaran kami.',
  //               onSendProofOfPayment: () {
  //                 Get.back();
  //                 alert.paymentSendProofOfPayment(
  //                   title: 'Pembayaran Berhasil',
  //                   onSendEmail: () {
  //                     Get.back();
  //                   },
  //                   onSendWa: () {
  //                     Get.back();
  //                   },
  //                   onNewOrder: () {
  //                     Get.back();
  //                     Timer(
  //                       Duration(seconds: 3),
  //                       () {
  //                         Get.dialog(
  //                           loading.simpleLoading(),
  //                           barrierDismissible: false,
  //                         );
  //                         Get.back();
  //                       },
  //                     );
  //                   },
  //                 );
  //               },
  //               onPrint: () {
  //                 Get.back();
  //               });
  //         } else {
  //           alert.warning('Warning', 'Payment In Process');
  //         }
  //       } catch (e) {
  //         logger.safeLog(e);
  //         alert.error('Error', 'Payment Error');
  //       }
  //     },
  //     onCancle: () {
  //       Get.back();
  //     },
  //   );

  //   var qrCodeBase64 = codeDummy.getQrCodeDummy();
  //   try {
  //     var result;
  //     result = await _service.order.orderService
  //         .createOrder(authToken: _authToken, body: getBodyOrder());

  //     result.fold(
  //       (l) {
  //         logger.safeLog(l);
  //         logger.safeLog('Create Order Error 1');
  //         alert.error('Error', 'Terjadi Kesalahan!');
  //       },
  //       (r) {
  //         logger.safeLog('Create Order Success');
  //         logger.safeLog(r.data);
  //         orderEntity.value = r.data;
  //         // orderNo.value = r
  //       },
  //     );
  //     displayUtil.updateSecondDisplay(
  //       CustomerDisplay(
  //         key: CustomerDisplayAction.PAYMENT,
  //         value: {PaymentMethod.QRIS: qrCodeBase64},
  //       ).toJson(),
  //     );
  //   } catch (e) {
  //     logger.safeLog(e);
  //     logger.safeLog('Create Order Error 2');
  //     alert.error('Error', 'Terjadi Kesalahan!');
  //   }
  // }

  // doPaymentEdc() {
  //   try {
  //     // alert.
  //   } catch (e) {
  //     logger.safeLog('e');
  //     alert.error('Error', 'Terjadi Kesalahan!');
  //   }
  // }

  OrderModel getBodyOrder() {
    List<OrderTicketModel> listTicket = [];
    List<OrderAddonModel> listProduct = [];
    List<OrderVoucherModel> listVoucher = [];

    if (ticketList.isNotEmpty) {
      listTicket.addAll(
        ticketList.map(
          (element) => OrderTicketModel(
            ordtcTicketId: element.ticket?.ticketId,
            totalTicket: element.qtyOrder!,
            totalAmount: element.totalPrice!,
          ),
        ),
      );
    }
    if (addonList.isNotEmpty) {
      listProduct.addAll(
        addonList.map(
          (element) => OrderAddonModel(
            ordadAddonId: element.addon?.productId,
            ordadTotalAddon: element.qtyOrder!,
            ordadTotalAmount: element.totalPrice!,
          ),
        ),
      );
    }
    if (voucherList.isNotEmpty) {
      listVoucher.addAll(
        voucherList.map(
          (element) => OrderVoucherModel(
            ordvcVoucherId: element.voucher?.voucherId,
            ordvcTotalVoucher: element.qtyOrder!,
            ordvcTotalAmount: element.totalPrice!,
          ),
        ),
      );
    }

    return OrderModel(
      orderName: orderNameController.text,
      orderPhoneNumber: noWaController.text,
      orderEmail: emailController.text,
      orderTotalItem: totalOrderQty.value,
      orderTotalAmt: totalOrderAmnt.value,
      orderUnitId: sessionUtil.getUnitId()!,
      orderLoacationId: 1,
      orderPaidBy: PaymentMethod.QRIS,
      orderStatus: 'N',
      listTicket: listTicket,
      listProduct: listProduct,
      listVoucher: listVoucher,
    );
  }
}
