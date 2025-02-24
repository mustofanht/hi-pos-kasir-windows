import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/cart/cart_member_model.dart';
import 'package:jaya_propertiy/data/models/order/order_member_model.dart';
import 'package:jaya_propertiy/domain/entities/masterdata/mst_payment.dart';
import 'package:jaya_propertiy/domain/entities/member/membership.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/create_member_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/member_page_controller.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/member/payment_member_controller.dart';

class CartMemberController extends GetxController {
  CartMemberController();

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

  clearOrder() {
    membershipList.clear();
    finalTotalOrderAmt.value = 0;
    selectedMstPayment.value = MstPayment();
  }

  bool doVerifyRequest() {
    bool isValid = true;
    if (isValid && Get.isRegistered<CreateMemberPageController>()) {
      final createMemberController = Get.find<CreateMemberPageController>();
      isValid = createMemberController.validateForm();
    }
    if (isValid && selectedMstPayment.value.pymntCode == null) {
      isValid = false;
      alert.error('Warning', 'Pilih Pembayaran terlebih dahulu!');
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
          paymentMethod, paymentMethodName);
    }
    return orderMemberModel;
  }

  onPayment() async {
    if (doVerifyRequest()) {
      final PaymentMemberController paymentController =
          Get.put(PaymentMemberController());

      if (selectedMstPayment.value.pymntCategory == PaymentMethod.QRIS) {
        OrderMemberModel body = getBodyOrder(
            selectedMstPayment.value.pymntCode!,
            selectedMstPayment.value.pymntName!);
        // logger.safeLog('ORDER BODY : ${body.toJson()}');
        await paymentController.doPaymentQris(
          body: body,
          orderNo: orderNo,
        );
      } else if (selectedMstPayment.value.pymntCategory != PaymentMethod.QRIS) {
        OrderMemberModel body = getBodyOrder(
            selectedMstPayment.value.pymntCode!,
            selectedMstPayment.value.pymntName!);
        // logger.safeLog('ORDER BODY : ${body.toJson()}');
        await paymentController.doOrderPaymentReffNo(
          body: body,
          orderNo: orderNo,
        );
      }
    }
  }
}
