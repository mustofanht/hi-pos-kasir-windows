import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/cart/cart_member_model.dart';
import 'package:jaya_propertiy/domain/entities/masterdata/mst_payment.dart';
import 'package:jaya_propertiy/domain/entities/member/membership.dart';

class CartMemberController extends GetxController {
  CartMemberController();

  var finalTotalOrderAmt = RxDouble(0);

  final membershipList = RxList<Membership>([]);

  final selectedMstPayment = MstPayment().obs;

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

  cancelOrder() {
    membershipList.clear();
    finalTotalOrderAmt.value = 0;
    selectedMstPayment.value = MstPayment();
  }
}
