import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/display_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/session_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/cart/cart_addon_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_ticket_mode.dart';
import 'package:jaya_propertiy/data/models/cart/cart_voucher_model.dart';
import 'package:jaya_propertiy/data/models/common/filter_model.dart';
import 'package:jaya_propertiy/data/models/order/order_addon_model.dart';
import 'package:jaya_propertiy/data/models/order/order_model.dart';
import 'package:jaya_propertiy/data/models/order/order_ticket_model.dart';
import 'package:jaya_propertiy/data/models/order/order_voucher_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/common/custom_id_name_entity.dart';
import 'package:jaya_propertiy/domain/entities/masterdata/mst_payment.dart';
import 'package:jaya_propertiy/domain/entities/order/response_order_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/order/order_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_cart_page_controller.dart';

class SalePageController extends GetxController
    with SingleGetTickerProviderMixin {
  SalePageController();
  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];
  DisplayUtil displayUtil = DisplayUtil();
  
  final scrollController = ScrollController();

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
  final alamatController = TextEditingController();
  final keteranganVoucher = TextEditingController();
  final paymentType = <CustomIdNameEntity>[].obs;
  final selectedPaymentType = CustomIdNameEntity().obs;
  final totalOrderQty = RxInt(0);
  final totalOrderAmnt = RxDouble(0);
  final addonList = RxList<CartAddon>([]);
  final ticketList = RxList<CartTicket>([]);
  final voucherList = RxList<CartVoucher>([]);

  var orderEntity = Rxn<ResponseOrderEntity>(null);

  final orderNo = Rxn<String>(null);

  final isLoadingPayment = false.obs;
  final mstPayments = <MstPayment>[].obs;

  doBackPayment() {
    openPayment.value = !openPayment.value;
    final SaleCartPageController saleCartPageController =
        Get.find<SaleCartPageController>();
    saleCartPageController.selectedMstPayment.value = MstPayment();
    saleCartPageController.calculateTotalOrder();
    update();
  }

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

    MstPayment mstPayment = mstPayments.firstWhere(
      (e) => e.pymntCode == value.id,
    );
    final SaleCartPageController saleCartPageController =
        Get.find<SaleCartPageController>();
    saleCartPageController.selectedMstPayment.value = mstPayment;
    saleCartPageController.calculateTotalOrder();
    update();
  }

  doPrepared() {
    doInitialValueDropdown();
  }

  doInitialValueDropdown() async {
    paymentType.clear();
    // paymentType.insert(
    //   0,
    //   CustomIdNameEntity(
    //     id: null,
    //     name: ' --- Pilih Pembayaran --- ',
    //   ),
    // );

    var result;
    List<FilterQuery> dataFilter = [];
    Map<String, dynamic> param = {
      'page': '0',
      'size': '999',
      'flMobile': 'Y',
    };

    isLoadingPayment.value = true;
    try {
      result = await _service.masterData.getAll(
        authToken: _authToken,
        dataFilter: dataFilter,
        paramsFilter: param,
      );

      result.fold((l) {
        logger.safeLog(l);
        isLoadingPayment.value = false;
      }, (r) {
        if (r.data != null) {
          mstPayments.value = r.data;
          for (var element in mstPayments) {
            paymentType.add(
              CustomIdNameEntity(
                id: element.pymntCode,
                name: element.pymntName,
              ),
            );
          }
        }
        isLoadingPayment.value = false;
      });
    } catch (e) {
      isLoadingPayment.value = false;
      logger.safeLog(e);
    }
    selectedPaymentType.value = paymentType.first;
    update();
  }

  bool doVerifyRequest() {
    bool isValid = true;
    // if (isValid && orderNameController.text.isEmpty) {
    //   isValid = false;
    //   alert.error(
    //       "Terjadi Kesalahan!", messagesConstant.requiredField("Name Pemesan"));
    // }
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

      MstPayment mstPayment = mstPayments.firstWhere(
        (e) => e.pymntCode == selectedPaymentType.value.id,
      );
      if (mstPayment.pymntCategory == PaymentMethod.QRIS) {
        OrderModel body = getBodyOrder(mstPayment.pymntCode!);
        logger.safeLog('ORDER BODY : ${body.toJson()}');
        orderController.doPaymentQris(
          body: body,
          orderNo: orderNo,
        );
      } else if (mstPayment.pymntCategory != PaymentMethod.QRIS) {
        OrderModel body = getBodyOrder(mstPayment.pymntCode!);
        logger.safeLog('ORDER BODY : ${body.toJson()}');
        orderPayment.doOrderPayment(
          body: body,
          orderNo: orderNo,
        );
      }
      // if (selectedPaymentType.value.id == PaymentMethod.QRIS) {
      //   orderController.doPaymentQris(
      //     body: getBodyOrder(),
      //     orderNo: orderNo,
      //   );
      // } else if (selectedPaymentType.value.id == PaymentMethod.EDC) {
      //   OrderModel body = getBodyOrder();
      //   body.orderPaidBy = PaymentMethod.EDC;
      //   orderPayment.doOrderPayment(
      //     body: body,
      //     orderNo: orderNo,
      //   );
      // } else if (selectedPaymentType.value.id == PaymentMethod.TRAVELOKA) {
      //   OrderModel body = getBodyOrder();
      //   body.orderPaidBy = PaymentMethod.TRAVELOKA;
      //   orderPayment.doOrderPayment(
      //     body: body,
      //     orderNo: orderNo,
      //   );
      // } else if (selectedPaymentType.value.id == PaymentMethod.TICKET) {
      //   OrderModel body = getBodyOrder();
      //   body.orderPaidBy = PaymentMethod.TICKET;
      //   orderPayment.doOrderPayment(
      //     body: body,
      //     orderNo: orderNo,
      //   );
      // } else {
      //   alert.error('Error', 'Please please select payment method');
      // }
    }
  }

  OrderModel getBodyOrder(String paymentMethod) {
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
            totalTotalTicketProduct += element.qtyOrder ?? 0;
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
            totalTotalTicketProduct += element.qtyOrder ?? 0;
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

    final SaleCartPageController saleCartPageController =
        Get.find<SaleCartPageController>();

    return OrderModel(
      orderName:
          orderNameController.text.isEmpty ? ' ' : orderNameController.text,
      orderPhoneNumber: noWaController.text.isEmpty ? ' ' : noWaController.text,
      orderEmail: emailController.text.isEmpty ? ' ' : emailController.text,
      orderReffno: null,
      orderTotalItem: totalTotalTicketProduct,
      custAddres: alamatController.text,
      orderVoucherDesc: keteranganVoucher.text,
      // orderTotalItem: totalOrderQty.value,
      orderTotalAmt: totalOrderAmnt.value,
      adminFeeAmt: saleCartPageController.getPricePayemntFee(),
      orderUnitId: sessionUtil.getUnitId()!,
      orderLoacationId: 1,
      orderPaidBy: paymentMethod,
      orderStatus: 'N',
      listTicket: listTicket,
      listProduct: listProduct,
      listVoucher: listVoucher,
    );
  }
}
