import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/display_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
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

class SalePageController extends GetxController
    with SingleGetTickerProviderMixin {
  SalePageController();
  DisplayUtil displayUtil = DisplayUtil();

  TabController? tabController;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabController!.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (!tabController!.indexIsChanging) {
      changeTabIndex(tabController!.index);
    }
  }

  final openPayment = false.obs;

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
  final totalOrderQty = RxInt(0);
  final totalOrderAmnt = RxDouble(0);
  final addonList = RxList<CartAddon>([]);
  final ticketList = RxList<CartTicket>([]);
  final voucherList = RxList<CartVoucher>([]);

  var orderEntity = Rxn<ResponseOrderEntity>(null);

  final orderNo = Rxn<String>(null);

  refreshForm() {
    orderNo.value = null;
    orderNameController.text = '';
    emailController.text = '';
    noWaController.text = '';
    doInitialValueDropdown();
    doSelectPaymentType(
      CustomIdNameEntity(
        id: null,
        name: ' --- Pilih Pembayaran --- ',
      ),
    );
  }

  doSelectPaymentType(CustomIdNameEntity value) {
    selectedPaymentType.value = value;
    update();
  }

  doPrepared() {
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
    // if (isValid && emailController.text.isEmpty) {
    //   isValid = false;
    //   alert.error(
    //       "Terjadi Kesalahan!", messagesConstant.requiredField("Email"));
    // }
    // if (isValid && noWaController.text.isEmpty) {
    //   isValid = false;
    //   alert.error(
    //       "Terjadi Kesalahan!", messagesConstant.requiredField("No Wa"));
    // }
    if (isValid && selectedPaymentType.value.id == null) {
      isValid = false;
      alert.error('Warning', 'Pilih Pembayaran terlebih dahulu!');
    }
    return isValid;
  }

  doPayment() {
    if (doVerifyRequest()) {
      logger.safeLog('orderNo.value : ${orderNo.value}');
      final OrderController orderController = Get.put(OrderController());
      final OrderPaymentController orderPayment =
          Get.put(OrderPaymentController());
      if (selectedPaymentType.value.id == PaymentMethod.QRIS) {
        orderController.doPaymentQris(
          body: getBodyOrder(),
          orderNo: orderNo,
        );
      } else if (selectedPaymentType.value.id == PaymentMethod.EDC) {
        OrderModel body = getBodyOrder();
        body.orderPaidBy = PaymentMethod.EDC;
        orderPayment.doOrderPayment(
          body: body,
          orderNo: orderNo,
        );
      } else if (selectedPaymentType.value.id == PaymentMethod.TRAVELOKA) {
        OrderModel body = getBodyOrder();
        body.orderPaidBy = PaymentMethod.TRAVELOKA;
        orderPayment.doOrderPayment(
          body: body,
          orderNo: orderNo,
        );
      } else if (selectedPaymentType.value.id == PaymentMethod.TICKET) {
        OrderModel body = getBodyOrder();
        body.orderPaidBy = PaymentMethod.TICKET;
        orderPayment.doOrderPayment(
          body: body,
          orderNo: orderNo,
        );
      } else {
        alert.error('Error', 'Please please select payment method');
      }
    }
  }

  OrderModel getBodyOrder() {
    List<OrderTicketModel> listTicket = [];
    List<OrderAddonModel> listProduct = [];
    List<OrderVoucherModel> listVoucher = [];

    double totalTicketProduct = 0;
    int totalTotalTicketProduct = 0;

    if (ticketList.isNotEmpty) {
      listTicket.addAll(
        ticketList.map(
          (element) {
            totalTicketProduct += element.totalPrice!;
            totalTotalTicketProduct += element.qtyOrder??0;
            return OrderTicketModel(
              ticket: element.ticket,
              ordtcTicketId: element.ticket?.ticketId,
              totalTicket: element.qtyOrder!,
              totalAmount: element.totalPrice!,
            );
          },
        ),
      );
    }
    if (addonList.isNotEmpty) {
      listProduct.addAll(
        addonList.map(
          (element) {
            totalTicketProduct += element.totalPrice!;
            totalTotalTicketProduct += element.qtyOrder??0;
            return OrderAddonModel(
              addOn: element.addon,
              ordadAddonId: element.addon?.productId,
              ordadTotalAddon: element.qtyOrder!,
              ordadTotalAmount: element.totalPrice!,
            );
          },
        ),
      );
    }
    if (voucherList.isNotEmpty) {
      listVoucher.addAll(
        voucherList.map(
          (element) {
            double totalVouceher = element.totalPrice!;
            if (element.voucher != null &&
                element.voucher?.voucherUnitType == UnitType.PERCENT) {
              totalVouceher =
                  (totalTicketProduct * (element.totalPrice ?? 0) / 100);
            }
            return OrderVoucherModel(
              voucher: element.voucher,
              ordvcVoucherId: element.voucher?.voucherId,
              ordvcTotalVoucher: element.qtyOrder!,
              ordvcTotalAmount: totalVouceher,
            );
          },
        ),
      );
    }

    return OrderModel(
      orderName:
          orderNameController.text.isEmpty ? null : orderNameController.text,
      orderPhoneNumber:
          noWaController.text.isEmpty ? null : noWaController.text,
      orderEmail: emailController.text.isEmpty ? null : emailController.text,
      orderReffno: null,
      orderTotalItem: totalTotalTicketProduct,
      // orderTotalItem: totalOrderQty.value,
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
