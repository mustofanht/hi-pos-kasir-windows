import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/local_storage_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/cart/cart_addon_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_ticket_mode.dart';
import 'package:jaya_propertiy/data/models/cart/cart_voucher_model.dart';
import 'package:jaya_propertiy/data/models/customer/customer_display_model.dart';
import 'package:jaya_propertiy/data/models/customer/customer_payment_model.dart';
import 'package:jaya_propertiy/data/models/customer/customer_sale_cart_model.dart';

class CustomerSaleCartPageController extends GetxController {
  CustomerSaleCartPageController();

  var totalOrder = RxDouble(0);
  var paymentFee = RxDouble(0);
  var reffNo = RxString('');

  final addonList = RxList<CartAddon>([]);
  final ticketList = RxList<CartTicket>([]);
  final voucherList = RxList<CartVoucher>([]);
  late var orderList = Cart(
    cartTicketList: ticketList,
    cartVoucherList: voucherList,
    addonList: addonList,
  ).obs;

  // List<File> images = [];
  final images = <File>[].obs;

  // final showBarcode = RxBool(false);
  final qrCode = Rxn<String>(null);
  final showPaymentSuccess = RxBool(false);

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    doPrepared();

    // dummy test product list
    // addonList.add(CartAddon(
    //   qtyOrder: 1,
    //   addon: AddonEntity(
    //     minRentPrd: 1,
    //     productId: 1,
    //     productLoc: 1,
    //     productLocName: 'Loc',
    //     productName: 'Gabezo',
    //     productType: 'S',
    //   ),
    //   rentModel: CartRentModel(
    //     startDate: DateTime.now(),
    //     endDate: DateTime.now().add(const Duration(hours: 5)),
    //     newBuyPrice: 1000000,
    //     totalHours: 5,
    //   ),
    // ));
  }

  doPrepared() async {
    qrCode.value = null;
    showPaymentSuccess.value = false;

    await loadImages();

    logger.safeLog('IMAGE PROMO : ${images.length}');
    update();
  }

  updateDataCustomer(Object value) async {
    qrCode.value = null;
    showPaymentSuccess.value = false;

    try {
      if (value is Map<Object?, Object?>) {
        Map<String, dynamic> convertedValue =
            common.convertToMapStringDynamic(value);

        CustomerDisplay customerDisplay =
            CustomerDisplay.fromJson(convertedValue);

        if (customerDisplay.value != null) {
          if (customerDisplay.key == CustomerDisplayAction.ADD_CART) {
            logger.safeLog('ADD CART');
            doAddCart(customerDisplay.value!);
          } else if (customerDisplay.key == CustomerDisplayAction.PAYMENT) {
            logger.safeLog('PAYMENT QRIS');
            doShowPaymentQris(customerDisplay.value!);
            // showBarcode.value = true;
          }
        }
      }
    } catch (e) {
      logger.safeLog('error : ${e}');
    }
    await loadImages();
    update();
  }

  doShowPaymentQris(Map<String, dynamic> val) {
    try {
      CustomerPayment customerPayment = CustomerPayment.fromJson(val);
      logger.safeLog('customerPayment ${customerPayment.toJson()}');
      if (customerPayment.isSuccess) {
        showPaymentSuccess.value = true;
      } else if (customerPayment.qrCode != null) {
        qrCode.value = customerPayment.qrCode;
      }
      if (customerPayment.orderNo != null) {
        reffNo.value = customerPayment.orderNo ?? '';
      }
    } catch (e) {
      logger.safeLog(e);
    }
  }

  Image getQrImg() {
    return qrCode.value != null && qrCode.value!.contains('http')
        ? Image.network(qrCode.value!, fit: BoxFit.fill, errorBuilder:
            (BuildContext context, Object exception, StackTrace? stackTrace) {
            return const Center(child: Text('Img Not Found'));
          })
        : Image.asset(qrCode.value!, fit: BoxFit.fill, errorBuilder:
            (BuildContext context, Object exception, StackTrace? stackTrace) {
            return const Center(child: Text('Img Not Found'));
          });
  }

  doAddCart(Map<String, dynamic> val) {
    ticketList.clear();
    voucherList.clear();
    addonList.clear();
    CustomerSaleCart customerSaleCart = CustomerSaleCart.fromJson(val);

    if (customerSaleCart.ticketList != null) {
      ticketList.addAll(customerSaleCart.ticketList!);
    }
    if (customerSaleCart.voucherList != null) {
      voucherList.addAll(customerSaleCart.voucherList!);
    }
    if (customerSaleCart.addonList != null) {
      addonList.addAll(customerSaleCart.addonList!);
    }
    if (customerSaleCart.totalOrder != null) {
      totalOrder.value = customerSaleCart.totalOrder!;
    }
    if (customerSaleCart.paymentFee != null) {
      paymentFee.value = customerSaleCart.paymentFee ?? 0;
    }
  }

  Future<void> loadImages() async {
    // localStorage.getSavedImages().then((List<File> val) {
    //   images.addAll(val);
    // });
    // for (int i = 0; i < 10; i++) {
    //   images.add('https://picsum.photos/1000/1000');
    // }
    var listImage = await localStorage.getImagesPromoLocal();
    logger.safeLog('LIST IMAGE ADS : ${listImage.length}');
    images.clear();
    images.addAll(listImage);
    update();
  }
}
