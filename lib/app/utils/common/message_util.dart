import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order.dart';

class MessageUtil {
  
  String buildBodyMessageDetailOrder(List<TrnDetailOrder> listData) {
    String bodyMsg = '';
    bodyMsg += 'Your Ticket';
    for (var element in listData) {
      bodyMsg += 'Product Name : ${element.productName}';
    }
    return bodyMsg;
  }
}

MessageUtil messageUtil = MessageUtil();