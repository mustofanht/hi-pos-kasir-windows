import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/display_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/cart/cart_addon_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_ticket_mode.dart';
import 'package:jaya_propertiy/data/models/cart/cart_voucher_model.dart';
import 'package:jaya_propertiy/data/models/customer/customer_display_model.dart';
import 'package:jaya_propertiy/data/models/customer/customer_sale_cart_model.dart';
import 'package:jaya_propertiy/domain/entities/masterdata/mst_payment.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/ticket_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/voucher_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale_page_controller.dart';

class SaleCartPageController extends GetxController {
  SaleCartPageController();
  final SalePageController salePageController = Get.find<SalePageController>();
  DisplayUtil displayUtil = DisplayUtil();

  var totalOrderAmnt = RxDouble(0);
  var finalTotalOrderAmt = RxDouble(0);
  var totalOrderQty = RxInt(0);

  final addonList = RxList<CartAddon>([]);
  final ticketList = RxList<CartTicket>([]);
  final voucherList = RxList<CartVoucher>([]);
  late var orderList = Cart(
    cartTicketList: ticketList,
    cartVoucherList: voucherList,
    addonList: addonList,
  ).obs;

  final selectedMstPayment = MstPayment().obs;

  addTicket(TicketEntity ticket) {
    ticketList.add(
      CartTicket(
        qtyOrder: ticket.ticketMinimum,
        ticket: ticket,
        totalPrice: (ticket.ticketMinimum ?? 0) * ticket.ticketPrice!,
      ),
    );
    calculateTotalOrder();
  }

  addTicketCart(CartTicket ticket) {
    ticket.qtyOrder = (ticket.qtyOrder ?? 0) + 1;
    ticket.totalPrice =
        ((ticket.totalPrice ?? 0) + (ticket.ticket!.ticketPrice ?? 0));
    calculateTotalOrder();
  }

  removeTicket(CartTicket ticket) {
    ticket.qtyOrder = (ticket.qtyOrder ?? 0) - 1;
    ticket.totalPrice =
        (ticket.totalPrice ?? 0) - (ticket.ticket!.ticketPrice ?? 0);
    if (ticket.qtyOrder == 0) {
      removeListTicket(ticket);
    }
    calculateTotalOrder();
  }

  removeListTicket(CartTicket ticket) {
    ticketList.remove(ticket);
    calculateTotalOrder();
  }

  addAddon(AddonEntity val) {
    addonList.add(
      CartAddon(
        qtyOrder: 1,
        totalPrice: val.productPrice!,
        addon: val,
      ),
    );
    calculateTotalOrder();
  }

  addAddonCart(CartAddon val) {
    val.qtyOrder = (val.qtyOrder ?? 0) + 1;
    val.totalPrice = (val.totalPrice ?? 0) + (val.addon!.productPrice ?? 0);
    calculateTotalOrder();
  }

  removeAddon(CartAddon val) {
    val.qtyOrder = (val.qtyOrder ?? 0) - 1;
    val.totalPrice = (val.totalPrice ?? 0) - (val.addon!.productPrice ?? 0);
    if (val.qtyOrder == 0) {
      removeListAddon(val);
    }
    calculateTotalOrder();
  }

  removeListAddon(CartAddon val) {
    addonList.remove(val);
    calculateTotalOrder();
  }

  addVoucher(VoucherEntity voucher) {
    voucherList.add(
      CartVoucher(
        qtyOrder: 1,
        totalPrice: voucher.voucherUnitValue!,
        voucher: voucher,
      ),
    );
    calculateTotalOrder();
  }

  removeListVoucher(CartVoucher voucher) {
    voucherList.remove(voucher);
    calculateTotalOrder();
  }

  void calculateTotalOrder() {
    double totalAmntFinal = 0;
    double ticketTotalAmnt = 0;
    int ticketTotalQtyVal = 0;

    if (ticketList.isNotEmpty) {
      ticketTotalAmnt +=
          ticketList.fold(0, (sum, val) => sum + val.totalPrice!);
      ticketTotalQtyVal +=
          ticketList.fold(0, (sum, val) => sum + val.qtyOrder!);
    }
    if (addonList.isNotEmpty) {
      ticketTotalAmnt += addonList.fold(0, (sum, val) => sum + val.totalPrice!);
      ticketTotalQtyVal += addonList.fold(0, (sum, val) => sum + val.qtyOrder!);
    }

    if (voucherList.isNotEmpty) {
      double discountAmount = 0;
      for (var element in voucherList) {
        if (element.voucher!.voucherUnitType == UnitType.PERCENT) {
          discountAmount +=
              ticketTotalAmnt * (element.voucher!.voucherUnitValue ?? 0) / 100;
        } else {
          discountAmount += element.voucher!.voucherUnitValue ?? 0;
        }
        logger.safeLog('discount : ${discountAmount} ');
      }

      ticketTotalQtyVal +=
          voucherList.fold(0, (sum, val) => sum + val.qtyOrder!);

      totalAmntFinal = ticketTotalAmnt - discountAmount;
    } else {
      totalAmntFinal = ticketTotalAmnt;
    }
    totalOrderAmnt.value = totalAmntFinal > 0 ? totalAmntFinal : 0;
    double paymentFee = getPricePayemntFee();
    logger.safeLog('TOTAL PAYMENT : ${totalOrderAmnt.value}');
    logger.safeLog('FEE PAYMENT : $paymentFee');
    finalTotalOrderAmt.value = (totalOrderAmnt.value + paymentFee);
    totalOrderQty.value = ticketTotalQtyVal;

    salePageController.totalOrderQty(totalOrderQty.value);
    salePageController.totalOrderAmnt(finalTotalOrderAmt.value);
    salePageController.addonList(addonList);
    salePageController.voucherList(voucherList);
    salePageController.ticketList(ticketList);

    update();

    updateCustomer();
  }

  onPayment() {
    if (finalTotalOrderAmt.value < 0) {
      alert.warning('warning', 'Order cannot empty');
      return;
    }

    logger.safeLog('OPEN PAYMENT 1 : ${salePageController.openPayment.value}');
    if (salePageController.openPayment.value) {
      salePageController.doPayment();
    } else {
      salePageController.doPrepared();
      salePageController.totalOrderQty(totalOrderQty.value);
      salePageController.totalOrderAmnt(finalTotalOrderAmt.value);
      salePageController.addonList(addonList);
      salePageController.voucherList(voucherList);
      salePageController.ticketList(ticketList);
      salePageController.openPayment(true);
    }
    logger.safeLog('OPEN PAYMENT 2 : ${salePageController.openPayment.value}');
  }

  clearCartOrder() {
    try {
      selectedMstPayment.value = MstPayment();
      ticketList.clear();
      addonList.clear();
      voucherList.clear();
      calculateTotalOrder();
      updateCustomer();
      // clear and back payment page
      salePageController.totalOrderQty(totalOrderQty.value);
      salePageController.totalOrderAmnt(finalTotalOrderAmt.value);
      salePageController.addonList(addonList);
      salePageController.voucherList(voucherList);
      salePageController.ticketList(ticketList);
      salePageController.openPayment(false);
      salePageController.refreshForm();
      salePageController.update();
    } catch (e) {
      logger.safeLog(e);
    }
    Get.back();
    update();
  }

  updateCustomer() {
    displayUtil.updateSecondDisplay(
      CustomerDisplay(
        key: CustomerDisplayAction.ADD_CART,
        value: CustomerSaleCart(
          ticketList: ticketList,
          addonList: addonList,
          voucherList: voucherList,
          totalOrder: finalTotalOrderAmt.value,
          paymentFee: getPricePayemntFee(),
        ).toJson(),
      ).toJson(),
    );
  }

  double getPricePayemntFee() {
    if (selectedMstPayment.value.pymntFlBbnCust == 'Y') {
      if (selectedMstPayment.value.pymntTypeFee == UnitType.PERCENT) {
        return (totalOrderAmnt.value *
            (selectedMstPayment.value.pymntAdminFee ?? 0) /
            100);
      } else {
        return selectedMstPayment.value.pymntAdminFee ?? 0;
      }
    } else {
      return 0;
    }
  }
}
