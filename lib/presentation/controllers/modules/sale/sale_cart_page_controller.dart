import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/display_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/cart/cart_addon_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_deposit_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_rent_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_ticket_mode.dart';
import 'package:jaya_propertiy/data/models/cart/cart_potongan_model.dart';
import 'package:jaya_propertiy/data/models/cart/cart_voucher_model.dart';
import 'package:jaya_propertiy/data/models/customer/customer_display_model.dart';
import 'package:jaya_propertiy/data/models/customer/customer_sale_cart_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/domain/entities/masterdata/mst_payment.dart';
import 'package:jaya_propertiy/domain/entities/sale/addon_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/deposit_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/potongan_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/ticket_entity.dart';
import 'package:jaya_propertiy/domain/entities/sale/voucher_entity.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_dialog.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale_page_controller.dart';

class SaleCartPageController extends GetxController {
  SaleCartPageController();
  final SalePageController salePageController = Get.find<SalePageController>();
  DisplayUtil displayUtil = DisplayUtil();
  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];

  var totalOrderAmnt = RxDouble(0);
  var finalTotalOrderAmt = RxDouble(0);
  var totalOrderQty = RxInt(0);

  final addonList = RxList<CartAddon>([]);
  final ticketList = RxList<CartTicket>([]);
  final potonganList = RxList<CartPotongan>([]);
  final voucherList = RxList<CartVoucher>([]);
  final depositList = RxList<CartDeposit>([]);
  late var orderList = Cart(
    cartTicketList: ticketList,
    cartPotonganList: potonganList,
    cartVoucherList: voucherList,
    cartDepositList: depositList,
    addonList: addonList,
  ).obs;

  final selectedMstPayment = MstPayment().obs;

  final Map<int, TextEditingController> ticketControllers = {};

  TextEditingController getTicketController(int id, int qtyOrder) {
    if (!ticketControllers.containsKey(id)) {
      ticketControllers[id] = TextEditingController(text: qtyOrder.toString());
    }
    return ticketControllers[id]!;
  }

  addTicket(TicketEntity ticket) {
    ticketList.add(
      CartTicket(
        qtyOrder: ticket.ticketMinimum,
        ticket: ticket,
        totalPrice: (ticket.ticketMinimum ?? 0) * ticket.ticketPrice!,
      ),
    );
    ticketControllers[ticket.ticketId]?.text = ticket.ticketMinimum.toString();
    calculateTotalOrder();
  }

  onCompleteQtyTicketCart(CartTicket ticket) {
    logger.safeLog('QTY: ${ticketControllers[ticket.ticket?.ticketId]?.text}');
    logger.safeLog('MINIMUM: ${ticket.ticket?.ticketMinimum}');
    int qty = int.parse(ticketControllers[ticket.ticket?.ticketId]!.text);
    if (qty < (ticket.ticket?.ticketMinimum ?? 0)) {
      ticketControllers[ticket.ticket?.ticketId]?.text =
          ticket.ticket!.ticketMinimum.toString();
    }
    calculateTotalOrder();
  }

  onChangeQtyTicketCart(CartTicket ticket, int qty) {
    logger.safeLog('QTY: ${qty}');
    logger.safeLog('MINIMUM: ${ticket.ticket?.ticketMinimum}');
    if (qty < (ticket.ticket?.ticketMinimum ?? 0)) {
      return;
    }
    ticket.qtyOrder = qty;
    ticket.totalPrice = ((ticket.ticket!.ticketPrice ?? 0) * qty);
    calculateTotalOrder();
  }

  addTicketCart(CartTicket ticket) {
    ticket.qtyOrder = (ticket.qtyOrder ?? 0) + 1;
    ticket.totalPrice =
        ((ticket.totalPrice ?? 0) + (ticket.ticket!.ticketPrice ?? 0));
    ticketControllers[ticket.ticket?.ticketId]?.text =
        ticket.qtyOrder.toString();
    calculateTotalOrder();
  }

  removeTicket(CartTicket ticket) {
    ticket.qtyOrder = (ticket.qtyOrder ?? 0) - 1;
    ticket.totalPrice =
        (ticket.totalPrice ?? 0) - (ticket.ticket!.ticketPrice ?? 0);
    if (ticket.qtyOrder == 0) {
      removeListTicket(ticket);
    }
    ticketControllers[ticket.ticket?.ticketId]?.text =
        ticket.qtyOrder.toString();
    calculateTotalOrder();
  }

  removeListTicket(CartTicket ticket) {
    ticketControllers[ticket.ticket?.ticketId]?.clear();
    ticketList.remove(ticket);
    calculateTotalOrder();
  }

  addAddon(AddonEntity val) {
    addonList.add(
      CartAddon(
        qtyOrder: 1,
        totalPrice: val.productPrice ?? 0,
        addon: val,
      ),
    );
    calculateTotalOrder();
  }

  addAddonRent(AddonEntity val, CartRentModel rentModel) {
    addonList.add(
      CartAddon(
        qtyOrder: 1,
        totalPrice: val.productPrice!,
        addon: val,
        rentModel: rentModel,
      ),
    );
    calculateTotalOrder();
  }

  addAddonCart(CartAddon val) {
    if (val.rentModel != null) {
    } else {
      val.qtyOrder = (val.qtyOrder ?? 0) + 1;
      val.totalPrice = (val.totalPrice ?? 0) + (val.addon!.productPrice ?? 0);
      calculateTotalOrder();
    }
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

  addpotongan(PotonganEntity potongan) {
    potonganList.add(
      CartPotongan(
        qtyOrder: 1,
        totalPrice: potongan.voucherUnitValue!,
        potongan: potongan,
      ),
    );
    calculateTotalOrder();
  }

  removeListpotongan(CartPotongan potongan) {
    potonganList.remove(potongan);
    calculateTotalOrder();
  }

  addvoucher(VoucherEntity voucher) {
    voucherList.add(
      CartVoucher(
        qtyOrder: 1,
        totalPrice: 1 * voucher.vpUnitValue!,
        entity: voucher,
      ),
    );
    calculateTotalOrder();
  }

  addVoucherCart(CartVoucher voucher) {
    if (voucherList.isNotEmpty) {
      int qtyAllTiket = 0;
      for (var element in voucherList) {
        qtyAllTiket += (element.qtyOrder ?? 0);
      }
      // logger.safeLog('voucher.qtyOrder : ${voucher.qtyOrder}');
      // logger.safeLog('qtyAllTiket : $qtyAllTiket');
      // if (((voucher.qtyOrder ?? 0) + 1) > qtyAllTiket) {
      //   alert.warning('Warning', 'Qty Voucher tidak bisa melebihi qty tiket');
      //   return;
      // }
    }

    voucher.qtyOrder = (voucher.qtyOrder ?? 0) + 1;
    voucher.totalPrice =
        ((voucher.totalPrice ?? 0) + (voucher.entity!.vpUnitValue ?? 0));
    calculateTotalOrder();
  }

  removeListvoucher(CartVoucher voucher) {
    voucherList.remove(voucher);
    calculateTotalOrder();
  }

  removeVoucher(CartVoucher voucher) {
    voucher.qtyOrder = (voucher.qtyOrder ?? 0) - 1;
    voucher.totalPrice =
        (voucher.totalPrice ?? 0) - (voucher.entity!.vpUnitValue ?? 0);
    if (voucher.qtyOrder == 0) {
      removeListvoucher(voucher);
    }
    calculateTotalOrder();
  }

  adddeposit(DepositEntity deposit) {
    depositList.add(
      CartDeposit(
        qtyOrder: 1,
        totalPrice: deposit.dpAmount ?? 0,
        deposit: deposit,
      ),
    );
    calculateTotalOrder();
  }

  removeListdeposit(CartDeposit deposit) {
    depositList.remove(deposit);
    calculateTotalOrder();
  }

  void calculateTotalOrder() {
    double totalAmntFinal = 0;
    double totalAmnt = 0;
    int ticketTotalQtyVal = 0;

    if (ticketList.isNotEmpty) {
      totalAmnt += ticketList.fold(0, (sum, val) => sum + val.totalPrice!);
      ticketTotalQtyVal +=
          ticketList.fold(0, (sum, val) => sum + val.qtyOrder!);

      if (voucherList.isNotEmpty) {
        double discountAmount = 0;
        for (var element in voucherList) {
          discountAmount += element.totalPrice ?? 0;
          // if (element.entity!.vpUnitType == UnitType.PERCENT) {
          //   discountAmount +=
          //       totalAmnt * (element.entity!.vpUnitValue ?? 0) / 100;
          // } else {
          //   discountAmount +=
          //       element.entity!.vpUnitValue ?? 0 * (element.qtyOrder ?? 1);
          // }
          logger.safeLog('VOUCHER AMOUNT : $discountAmount ');
        }

        ticketTotalQtyVal +=
            voucherList.fold(0, (sum, val) => sum + val.qtyOrder!);

        totalAmnt = totalAmnt - discountAmount;
      }
    }
    if (addonList.isNotEmpty) {
      totalAmnt += addonList.fold(0, (sum, val) => sum + val.totalPrice!);
      ticketTotalQtyVal += addonList.fold(0, (sum, val) => sum + val.qtyOrder!);
    }

    totalAmntFinal = totalAmnt;

    if (potonganList.isNotEmpty) {
      double discountAmount = 0;
      for (var element in potonganList) {
        if (element.potongan!.voucherUnitType == UnitType.PERCENT) {
          discountAmount +=
              totalAmnt * (element.potongan!.voucherUnitValue ?? 0) / 100;
        } else {
          discountAmount += element.potongan!.voucherUnitValue ?? 0;
        }
        logger.safeLog('POTONGAN AMOUNT : $discountAmount ');
      }

      ticketTotalQtyVal +=
          potonganList.fold(0, (sum, val) => sum + val.qtyOrder!);

      totalAmntFinal = totalAmnt - discountAmount;
    }
    if (depositList.isNotEmpty) {
      double discountAmount = 0;
      for (var element in depositList) {
        discountAmount += element.deposit!.dpAmount ?? 0;
        logger.safeLog('DEPOSIT AMOUNT : $discountAmount ');
      }

      ticketTotalQtyVal +=
          depositList.fold(0, (sum, val) => sum + val.qtyOrder!);

      totalAmntFinal = totalAmnt - discountAmount;
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
    salePageController.potonganList(potonganList);
      salePageController.voucherList(voucherList);
      salePageController.depositList(depositList);
    salePageController.ticketList(ticketList);

    update();

    updateCustomer();
  }

  onPayment() {
    // logger.safeLog('TOTAL AMT : ${finalTotalOrderAmt.value}');
    // logger.safeLog('TICKERT LIST : ${ticketList.length}');
    // logger.safeLog('TICKERT LIST : ${ticketList.isEmpty}');
    // logger.safeLog('potongan LIST : ${potonganList.length}');
    // logger.safeLog('potongan LIST : ${potonganList.isEmpty}');
    // logger.safeLog(
    //     'VALID TO PAYMENT  : ${(finalTotalOrderAmt.value < 0 && potonganList.isEmpty && ticketList.isEmpty)}');
    if (finalTotalOrderAmt.value < 0 ||
        (addonList.isEmpty && ticketList.isEmpty)) {
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
      salePageController.potonganList(potonganList);
      salePageController.voucherList(voucherList);
      salePageController.depositList(depositList);
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
      potonganList.clear();
      voucherList.clear();
      depositList.clear();
      calculateTotalOrder();
      updateCustomer();
      // clear and back payment page
      salePageController.totalOrderQty(totalOrderQty.value);
      salePageController.totalOrderAmnt(finalTotalOrderAmt.value);
      salePageController.addonList(addonList);
      salePageController.potonganList(potonganList);
      salePageController.voucherList(voucherList);
      salePageController.depositList(depositList);
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
          potonganList: potonganList,
          voucherList: voucherList,
          depositList: depositList,
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

  onNextRental(
    CartRentModel cartRentModel,
    AddonEntity val,
    CartAddon? exists,
  ) async {
    Get.back();

    var result;
    val.productPrice = 0;

    if (exists != null) {
      addonList.remove(exists);
    }

    result = await _service.rental.getPriceRental(
      authToken: _authToken,
      hours: cartRentModel.totalHours!,
      productId: val.productId!,
      orderNoExtra: cartRentModel.transactionExtra?.orderNumber,
    );

    CartRentModel cartRentModelAdded = cartRentModel;

    result.fold(
      (l) {
        logger.safeLog(l);
      },
      (r) {
        logger.safeLog(r.data);
        if (ProductRentalType.HOURS == val.productType) {
          // if (cartRentModelAdded.isExtraTime!) {
          //   cartRentModelAdded.extraTimeBuyPrice = r.data;
          // } else {
          //   cartRentModelAdded.newBuyPrice = r.data;
          // }
          cartRentModelAdded.newBuyPrice = r.data;
        } else {}
        val.productPrice = r.data;

        addAddonRent(
          val,
          cartRentModelAdded,
        );
        update();
      },
    );
  }

  doUpdateRent(CartAddon cartAddOn) async {
    await dialog.selectHourRent(
      authToken: _authToken,
      entitiy: cartAddOn.addon!,
      detailModel: cartAddOn.rentModel,
      isExtraTime: cartAddOn.rentModel!.isExtraTime!,
      onNext: (cartRentModel) => onNextRental(
        cartRentModel,
        cartAddOn.addon!,
        cartAddOn,
      ),
    );
  }
}
