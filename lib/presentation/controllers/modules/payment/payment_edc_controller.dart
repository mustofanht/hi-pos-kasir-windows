import 'package:get/get.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/constant/message_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/data/models/order/order_model.dart';
import 'package:jaya_propertiy/data/services/main_service.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/controllers/modules/sale/sale_cart_page_controller.dart';

class PaymentEdcController extends GetxController {
  PaymentEdcController();

  final _service = MainService();
  final _authToken = Get.arguments[argConstant.authToken];

  doPaymentEdc({required OrderModel body}) {
    try {
      // Display the waiting payment alert
      alert.waitingPaymentEdc(
        title: 'Menunggu Proses Transaksi',
        msg: 'Silahkan mengisi reference',
        onNext: (val) async {
          // create Order and waiting the prosess of payment
          logger.safeLog('val : $val');
          if (val != '') {
            body.orderReffno = val;
            doCreateOrderEdc(body: body);

            final saleController = Get.find<SaleCartPageController>();
            saleController.clearCartOrder();
            Get.back();

            alert.success('Success', 'Payment Success');
          } else {
            alert.error(
              'Error',
              messagesConstant.requiredField('Nomor Refference'),
            );
          }
        },
      );
    } catch (e) {
      logger.safeLog(e);
      alert.error('Error', 'Unexpected Error');
    }
  }

  doCreateOrderEdc({required OrderModel body}) async {
    try {
      var result;
      result = await _service.order.orderService.createOrder(
        authToken: _authToken,
        body: body,
        // reffNo: orderEntity.value?.orderNumber,
      );

      result.fold(
        (l) {
          logger.safeLog(l);
          logger.safeLog('Create Order Error 1');
          alert.error('Error', 'Terjadi Kesalahan!');
        },
        (r) {
          logger.safeLog('Create Order Success');
          logger.safeLog(r.data);
          // orderEntity.value = r.data;
          // orderNo.value = r
        },
      );
    } catch (e) {
      logger.safeLog(e);
      logger.safeLog('Create Order Error 2');
      alert.error('Error', 'Terjadi Kesalahan!');
    }
  }
}
