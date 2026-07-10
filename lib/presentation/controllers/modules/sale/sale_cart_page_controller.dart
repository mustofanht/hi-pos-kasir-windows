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
import 'package:jaya_propertiy/domain/entities/member/member_valid.dart';
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

  final memberVoucher = false.obs;
  final memberValid = MemberValid().obs;

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
    checkQtyMemberVocuher();
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
    checkQtyMemberVocuher();
    calculateTotalOrder();
  }

  removeTicket(CartTicket ticket) {
    // logger.safeLog('voucherList LENGTH : ${voucherList.length}');
    // logger.safeLog(
    //     'voucherList.first.selectedMemberAnggota LENGTH : ${voucherList.first.selectedMemberAnggota?.length}');
    // if (memberVoucher.isTrue) {
    //   if (voucherList.isNotEmpty) {
    //     if (voucherList.first.selectedMemberAnggota != null &&
    //         voucherList.first.selectedMemberAnggota!.isNotEmpty) {
    //       int qtyCurr = (ticket.qtyOrder ?? 0) - 1;
    //       int totalQtyVoucher = 0;
    //       for (var element in voucherList) {
    //         totalQtyVoucher += (element.qtyOrder ?? 0);
    //       }
    //       if (qtyCurr < totalQtyVoucher) {
    //         alert.warning(
    //             'Warning', 'Qty Ticket tidak bisa kurang dari qty voucher!');
    //         return;
    //       }
    //     }
    //   }
    // }
    if (voucherList.isNotEmpty) {
      int qtyCurr = (ticket.qtyOrder ?? 0) - 1;
      int totalQtyVoucher = 0;
      for (var element in voucherList) {
        totalQtyVoucher += (element.qtyOrder ?? 0);
      }
      if (qtyCurr < totalQtyVoucher) {
        alert.warning(
            'Warning', 'Qty Ticket tidak bisa kurang dari qty voucher!');
        return;
      }
    }

    ticket.qtyOrder = (ticket.qtyOrder ?? 0) - 1;
    ticket.totalPrice =
        (ticket.totalPrice ?? 0) - (ticket.ticket!.ticketPrice ?? 0);
    if (ticket.qtyOrder == 0) {
      removeListTicket(ticket);
    }
    ticketControllers[ticket.ticket?.ticketId]?.text =
        ticket.qtyOrder.toString();
    checkQtyMemberVocuher();
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
    if (memberVoucher.isTrue) {
      alert.warning('Warning', 'Potongan tidak bisa di gunakan!');
      return;
    }
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

  bool validateVoucher(int qtyOrder, VoucherEntity voucher) {
    bool isValid = true;
    if (memberVoucher.isTrue) {
      alert.warning('Warning', 'Voucher tidak bisa di gunakan!');
      isValid = false;
    }

    if ((qtyOrder + 1) > (voucher.vpLimit ?? 0)) {
      alert.warning(
        'Warning',
        'Limit Voucher tersisa ${voucher.vpLimit ?? 0}',
      );
      isValid = false;
    }

    if (voucherList.isNotEmpty) {
      int qtyAllTiket = 0;
      int qtyAllVoucher = 0;
      for (var element in ticketList) {
        qtyAllTiket += (element.qtyOrder ?? 0);
      }
      for (var element in voucherList) {
        qtyAllVoucher += (element.qtyOrder ?? 0);
      }

      logger.safeLog('qtyAllVoucher : $qtyAllVoucher');
      logger.safeLog('qtyAllTiket : $qtyAllTiket');
      if ((qtyAllVoucher + 1) > qtyAllTiket) {
        alert.warning('Warning', 'Qty Voucher tidak bisa melebihi qty tiket');
        isValid = false;
      }
    }
    return isValid;
  }

  addvoucher(VoucherEntity voucher) {
    // if (memberVoucher.isTrue) {
    //   alert.warning('Warning', 'Voucher tidak bisa di gunakan!');
    //   return;
    // }
    // bool isValid = validateVoucher(1, voucher);
    bool isValid = validateVoucher(0, voucher);
    if (!isValid) return;

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
    // if (memberVoucher.isTrue) {
    //   alert.warning('Warning', 'Voucher tidak bisa di gunakan!');
    //   return;
    // }

    // if (((voucher.qtyOrder ?? 0) + 1) > (voucher.entity?.vpLimit ?? 0)) {
    //   alert.warning(
    //     'Warning',
    //     'Limit Voucher tersisa ${voucher.entity?.vpLimit ?? 0}',
    //   );
    //   return;
    // }
    // if (voucherList.isNotEmpty) {
    //   int qtyAllTiket = 0;
    //   for (var element in ticketList) {
    //     qtyAllTiket += (element.qtyOrder ?? 0);
    //   }
    //   // logger.safeLog('voucher.qtyOrder : ${voucher.qtyOrder}');
    //   // logger.safeLog('qtyAllTiket : $qtyAllTiket');
    //   if (((voucher.qtyOrder ?? 0) + 1) > qtyAllTiket) {
    //     alert.warning('Warning', 'Qty Voucher tidak bisa melebihi qty tiket');
    //     return;
    //   }
    // }

    bool isValid = validateVoucher((voucher.qtyOrder ?? 0), voucher.entity!);
    if (!isValid) return;

    voucher.qtyOrder = (voucher.qtyOrder ?? 0) + 1;
    voucher.totalPrice =
        ((voucher.totalPrice ?? 0) + (voucher.entity!.vpUnitValue ?? 0));
    calculateTotalOrder();
  }

  removeListvoucher(CartVoucher voucher) {
    voucherList.remove(voucher);
    if (memberVoucher.isTrue) {
      memberVoucher.value = false;
      salePageController.memberNo.clear();
    }
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
    if (memberVoucher.isTrue) {
      alert.warning('Warning', 'Deposit tidak bisa di gunakan!');
      return;
    }
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

    // if (ticketList.isNotEmpty) {
    //   totalAmnt += ticketList.fold(0, (sum, val) => sum + val.totalPrice!);
    //   ticketTotalQtyVal +=
    //       ticketList.fold(0, (sum, val) => sum + val.qtyOrder!);

    //   if (voucherList.isNotEmpty) {
    //     double discountAmount = 0;

    //     // List<CartTicket> sortedTicketList = List.from(ticketList);
    //     // sortedTicketList.sort((a, b) => b.totalPrice!.compareTo(a.totalPrice!));

    //     for (var element in voucherList) {
    //       int remainingVoucherQty = element.qtyOrder ?? 0;

    //       if (remainingVoucherQty > 0) {
    //         for (var ticket in ticketList) {
    //           if (remainingVoucherQty == 0) break;

    //           int applicableQty = ticket.qtyOrder! < remainingVoucherQty
    //               ? ticket.qtyOrder!
    //               : remainingVoucherQty;
    //           remainingVoucherQty -= applicableQty;

    //           if (element.entity!.vpUnitType == UnitType.PERCENT) {
    //             logger.safeLog(
    //                 'PERCENT HITUNG TIKET : ${ticket.ticket?.ticketName} -> VOUCHER : ${element.entity?.vpName}');
    //             discountAmount += applicableQty *
    //                 (ticket.totalPrice! / ticket.qtyOrder!) *
    //                 (element.entity!.vpUnitValue ?? 0) /
    //                 100;
    //           } else {
    //             logger.safeLog(
    //                 'NOT PERCENT HITUNG TIKET : ${ticket.ticket?.ticketName} -> VOUCHER : ${element.entity?.vpName}');
    //             discountAmount +=
    //                 applicableQty * (element.entity!.vpUnitValue ?? 0);
    //           }
    //         }
    //       }
    //     }
    //     logger.safeLog('VOUCHER AMOUNT : $discountAmount ');

    //     ticketTotalQtyVal +=
    //         voucherList.fold(0, (sum, val) => sum + val.qtyOrder!);

    //     totalAmnt = totalAmnt - discountAmount;
    //   }
    // }

    if (ticketList.isNotEmpty) {
      totalAmnt += ticketList.fold(0, (sum, val) => sum + val.totalPrice!);
      ticketTotalQtyVal +=
          ticketList.fold(0, (sum, val) => sum + val.qtyOrder!);

      if (voucherList.isNotEmpty) {
        double discountAmount = 0;
        final Map<CartTicket, int> remainingTicketQtyMap = {
          for (var ticket in ticketList) ticket: ticket.qtyOrder!
        };

        for (var element in voucherList) {
          int remainingVoucherQty = element.qtyOrder ?? 0;

          if (remainingVoucherQty > 0) {
            for (var ticket in ticketList) {
              int remainingTicketQty = remainingTicketQtyMap[ticket] ?? 0;
              if (remainingVoucherQty == 0 || remainingTicketQty == 0) continue;

              int applicableQty = remainingTicketQty < remainingVoucherQty
                  ? remainingTicketQty
                  : remainingVoucherQty;

              remainingTicketQtyMap[ticket] =
                  remainingTicketQty - applicableQty;
              remainingVoucherQty -= applicableQty;

              if (element.entity!.vpUnitType == UnitType.PERCENT) {
                logger.safeLog(
                    'PERCENT HITUNG TIKET : ${ticket.ticket?.ticketName} -> VOUCHER : ${element.entity?.vpName}');
                discountAmount += applicableQty *
                    (ticket.totalPrice! / ticket.qtyOrder!) *
                    (element.entity!.vpUnitValue ?? 0) /
                    100;
              } else {
                logger.safeLog(
                    'NOT PERCENT HITUNG TIKET : ${ticket.ticket?.ticketName} -> VOUCHER : ${element.entity?.vpName}');
                discountAmount +=
                    applicableQty * (element.entity!.vpUnitValue ?? 0);
              }
            }
          }
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

    // logger.safeLog('POTONGAN JML : ${potonganList.length}');
    // logger.safeLog('TOTAL AMOUNT : $totalAmnt');
    // logger.safeLog('TOTAL AMOUNT FINAL : $totalAmntFinal');

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

      totalAmntFinal = totalAmntFinal - discountAmount;
    }

    // logger.safeLog('DEPOSIT JML : ${depositList.length}');
    // logger.safeLog('TOTAL AMOUNT : $totalAmnt');
    // logger.safeLog('TOTAL AMOUNT FINAL : $totalAmntFinal');

    if (depositList.isNotEmpty) {
      double discountAmount = 0;
      for (var element in depositList) {
        discountAmount += element.deposit!.dpAmount ?? 0;
        logger.safeLog('DEPOSIT AMOUNT : $discountAmount ');
      }

      ticketTotalQtyVal +=
          depositList.fold(0, (sum, val) => sum + val.qtyOrder!);

      totalAmntFinal = totalAmntFinal - discountAmount;
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
      memberVoucher.value = false;
      salePageController.memberNo.clear();
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

  checkQtyMemberVocuher() {
    int qty = 1;
    int totalQtyTiket = 0;
    for (var tiket in ticketList) {
      totalQtyTiket += tiket.qtyOrder ?? 0;
    }

    if (memberValid.value.memberListResponses == null ||
        memberValid.value.memberListResponses!.isEmpty) {
      if (memberValid.value.mstMembership != null) {
        int maxKuota = (memberValid.value.mstMembership?.membKuota ?? 0) <
                (memberValid.value.mstMembership?.membMaxKuota ?? 0)
            ? (memberValid.value.mstMembership?.membKuota ?? 0)
            : (memberValid.value.mstMembership?.membMaxKuota ?? 0);

        if (totalQtyTiket <= maxKuota) {
          qty = totalQtyTiket;
        } else {
          qty = maxKuota;
        }

        if (voucherList.isNotEmpty) {
          CartVoucher cartSelected = voucherList.firstWhere(
            (element) =>
                element.entity?.vpId ==
                memberValid.value.mstMembership?.membVpId,
          );
          cartSelected.qtyOrder = qty;
        }
      }
    }
  }
}
