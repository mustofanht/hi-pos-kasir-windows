import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/display_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/customer/customer_display_model.dart';
import 'package:jaya_propertiy/data/models/customer/customer_sale_cart_model.dart';
import 'package:jaya_propertiy/data/models/order/order_member_model.dart';
import 'package:jaya_propertiy/data/models/order/split_payment_leg_model.dart';
import 'package:jaya_propertiy/domain/entities/masterdata/mst_payment.dart';
import 'package:jaya_propertiy/domain/entities/member/membership.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/create_member_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/member_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/payment_member_controller.dart';

class CartMemberController extends GetxController {
  CartMemberController();

  final headerController = Get.find<MemberPageController>();

  var finalTotalOrderAmt = RxDouble(0);

  final membershipList = RxList<Membership>([]);

  final selectedMstPayment = MstPayment().obs;

  final orderNo = Rxn<String>(null);

  addCartMembership(Membership membership) {
    membershipList.add(membership);
    calculateMemberAmount();
  }

  calculateMemberAmount() {
    finalTotalOrderAmt.value = 0;
    try {
      for (var element in membershipList) {
        finalTotalOrderAmt.value =
            finalTotalOrderAmt.value + (element.membRegPrice ?? 0);
      }
      double paymentFee = getPricePayemntFee();
      finalTotalOrderAmt.value = (finalTotalOrderAmt.value + paymentFee);
    } catch (e) {
      logger.safeLog('Err: $e');
    }
    update();
    updateCustomer();
  }

  double getPricePayemntFee() {
    if (selectedMstPayment.value.pymntFlBbnCust == 'Y') {
      if (selectedMstPayment.value.pymntTypeFee == UnitType.PERCENT) {
        return (finalTotalOrderAmt.value *
            (selectedMstPayment.value.pymntAdminFee ?? 0) /
            100);
      } else {
        return selectedMstPayment.value.pymntAdminFee ?? 0;
      }
    } else {
      return 0;
    }
  }

  cancelOrder() {
    Get.back();
    clearOrder();
    headerController.goBack();
    updateCustomer();
  }

  clearOrder() {
    membershipList.clear();
    finalTotalOrderAmt.value = 0;
    selectedMstPayment.value = MstPayment();
    updateCustomer();
  }

  updateCustomer() {
    // Ambil nama peserta/pendaftar dari form registrasi jika tersedia
    String? registrantName;
    if (Get.isRegistered<CreateMemberPageController>()) {
      final createMemberController = Get.find<CreateMemberPageController>();
      registrantName = createMemberController.nameController.text;
    }

    // Sertakan nama peserta pada setiap item membership yang dikirim ke TV
    final memberListWithName = membershipList.map((m) {
      return Membership(
        membId: m.membId,
        membName: m.membName,
        membDesc: m.membDesc,
        membState: m.membState,
        membPeriod: m.membPeriod,
        membResetPeriod: m.membResetPeriod,
        membResetFirstdate: m.membResetFirstdate,
        membStartFirstdate: m.membStartFirstdate,
        membFlSunday: m.membFlSunday,
        membFlMonday: m.membFlMonday,
        membFlTuesday: m.membFlTuesday,
        membFlWednesday: m.membFlWednesday,
        membFlThursday: m.membFlThursday,
        membFlFriday: m.membFlFriday,
        membFlSaturday: m.membFlSaturday,
        membMaxType: m.membMaxType,
        membCheckName: m.membCheckName,
        membLocId: m.membLocId,
        memLocName: m.memLocName,
        membVpId: m.membVpId,
        membKuota: m.membKuota,
        membMaxKuota: m.membMaxKuota,
        membRegPrice: m.membRegPrice,
        registrantName: registrantName,
      );
    }).toList();

    displayUtil.updateSecondDisplay(
      CustomerDisplay(
        key: CustomerDisplayAction.MEMBER_ADD_CART,
        value: CustomerSaleCart(
          memberList: memberListWithName,
          totalOrder: finalTotalOrderAmt.value,
          paymentFee: getPricePayemntFee(),
        ).toJson(),
      ).toJson(),
    );
  }

  bool doVerifyRequest() {
    bool isValid = true;
    final createMemberController = Get.isRegistered<CreateMemberPageController>()
        ? Get.find<CreateMemberPageController>()
        : null;
    if (isValid && createMemberController != null) {
      isValid = createMemberController.validateForm();
    }
    final isSplit = createMemberController?.isSplitPayment.value ?? false;
    if (isValid && !isSplit && selectedMstPayment.value.pymntCode == null) {
      isValid = false;
      alert.error('Warning', 'Pilih Pembayaran terlebih dahulu!');
    }
    if (isValid && isSplit && createMemberController != null) {
      final c = createMemberController;
      if (c.splitPayment1.value?.pymntCode == null) {
        isValid = false;
        alert.error('Warning', 'Pilih metode pembayaran pertama (split)!');
      } else if (c.splitAmount1 <= 0 || c.splitAmount1 >= finalTotalOrderAmt.value) {
        isValid = false;
        alert.error('Warning',
            'Nominal metode pertama harus lebih dari 0 dan kurang dari total pembayaran.');
      } else if (c.splitPayment2.value?.pymntCode == null) {
        isValid = false;
        alert.error('Warning', 'Pilih metode pembayaran kedua (split)!');
      } else if (c.splitPayment1.value!.pymntCode == c.splitPayment2.value!.pymntCode) {
        isValid = false;
        alert.error('Warning', 'Dua metode split payment harus berbeda.');
      } else if (c.splitLegNeedsReffno(c.splitPayment1.value) &&
          c.splitReffno1Controller.text.trim().isEmpty) {
        isValid = false;
        alert.error('Warning', 'Isi nomor reference untuk metode pertama.');
      } else if (c.splitLegNeedsReffno(c.splitPayment2.value) &&
          c.splitReffno2Controller.text.trim().isEmpty) {
        isValid = false;
        alert.error('Warning', 'Isi nomor reference untuk metode kedua.');
      }
    }
    return isValid;
  }

  OrderMemberModel getBodyOrder(
    String paymentMethod,
    String paymentMethodName,
  ) {
    OrderMemberModel orderMemberModel = OrderMemberModel();
    if (Get.isRegistered<CreateMemberPageController>()) {
      final createMemberController = Get.find<CreateMemberPageController>();
      orderMemberModel = createMemberController.getFormBodyOrder(
        paymentMethod,
        paymentMethodName,
      );
      orderMemberModel.totalPrice = finalTotalOrderAmt.value;
      orderMemberModel.adminFeeAmt = getPricePayemntFee();
    }
    return orderMemberModel;
  }

  /// Body order untuk split payment -- orderPaidBy diisi "MX" (Campuran) dan
  /// [OrderMemberModel.splitPayments] diisi 2 leg. Tunai otomatis '-', sama
  /// seperti pembayaran tunggal. Tanpa biaya admin (split belum menghitung
  /// admin fee per leg, sama seperti penjualan tiket/produk biasa).
  OrderMemberModel getBodyOrderSplit() {
    final createMemberController = Get.find<CreateMemberPageController>();
    OrderMemberModel body = getBodyOrder('MX', 'Campuran (Split Payment)');
    body.adminFeeAmt = 0;
    body.splitPayments = [
      SplitPaymentLegModel(
        paymentCode: createMemberController.splitPayment1.value!.pymntCode,
        amount: createMemberController.splitAmount1,
        reffno: createMemberController.splitPayment1.value!.pymntCategory ==
                PaymentMethod.CASH
            ? '-'
            : createMemberController.splitReffno1Controller.text.trim(),
      ),
      SplitPaymentLegModel(
        paymentCode: createMemberController.splitPayment2.value!.pymntCode,
        amount: createMemberController.splitAmount2,
        reffno: createMemberController.splitPayment2.value!.pymntCategory ==
                PaymentMethod.CASH
            ? '-'
            : createMemberController.splitReffno2Controller.text.trim(),
      ),
    ];
    return body;
  }

  onPayment() async {
    if (doVerifyRequest()) {
      final PaymentMemberController paymentController =
          Get.put(PaymentMemberController());

      final createMemberController =
          Get.isRegistered<CreateMemberPageController>()
              ? Get.find<CreateMemberPageController>()
              : null;
      if (createMemberController?.isSplitPayment.value == true) {
        OrderMemberModel body = getBodyOrderSplit();
        await paymentController.doSplitPayment(body: body, orderNo: orderNo);
        return;
      }

      if (selectedMstPayment.value.pymntCategory == PaymentMethod.QRIS) {
        OrderMemberModel body = getBodyOrder(
          selectedMstPayment.value.pymntCode!,
          selectedMstPayment.value.pymntName!,
        );
        // logger.safeLog('ORDER BODY : ${body.toJson()}');
        await paymentController.doPaymentQris(
          body: body,
          orderNo: orderNo,
        );
      } else if (selectedMstPayment.value.pymntCategory != PaymentMethod.QRIS) {
        OrderMemberModel body = getBodyOrder(
          selectedMstPayment.value.pymntCode!,
          selectedMstPayment.value.pymntName!,
        );
        // logger.safeLog('ORDER BODY : ${body.toJson()}');
        await paymentController.doOrderPaymentReffNo(
          body: body,
          orderNo: orderNo,
          paymentCategory: selectedMstPayment.value.pymntCategory,
        );
      }
    }
  }
}
