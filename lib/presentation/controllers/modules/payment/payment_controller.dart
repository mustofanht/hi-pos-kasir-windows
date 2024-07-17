import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/display_util.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/payment/payment_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';

class PaymentController extends GetxController {
  PaymentController();

  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];
  DisplayUtil displayUtil = DisplayUtil();

  doPayment({required PaymentModel body}) async {
    try {
      var result = await _service.payment.paymentOrderSercvice
          .payment(authToken: _authToken, body: body);

      result.fold(
        (l) {
          logger.safeLog(l);
          logger.safeLog('Payment Error 1');
          alert.error('Error', 'Terjadi Kesalahan!');
        },
        (r) {
          logger.safeLog('Payment Success');
          logger.safeLog(r.data);
        },
      );
    } catch (e) {
      logger.safeLog(e);
      logger.safeLog('Payment Error 2');
      alert.error('Error', 'Terjadi Kesalahan!');
    }
  }
}
