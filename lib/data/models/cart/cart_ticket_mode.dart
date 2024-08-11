import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/domain/entities/sale/ticket_entity.dart';

class CartTicket {
  int? qtyOrder;
  double? totalPrice;
  TicketEntity? ticket;

  CartTicket({
    this.qtyOrder,
    this.totalPrice,
    this.ticket,
  });

  Map<String, dynamic> toJson() {
    return {
      "qtyOrder": qtyOrder,
      "totalPrice": totalPrice,
      "ticket": ticket?.toJson(),
    };
  }

  CartTicket.fromJson(Map<String, dynamic> json) {
    try {
      qtyOrder = json['qtyOrder'];
      totalPrice = json['totalPrice'];

      if (json['ticket'] is Map<Object?, Object?>) {
        Map<String, dynamic> result =
            common.convertToMapStringDynamic(json['ticket']);
        ticket = TicketEntity.fromJson(result);
      } else {
        ticket = TicketEntity.fromJson(json['ticket']);
      }
    } catch (e) {
      logger.safeLog('Error $e');
    }
  }
}
