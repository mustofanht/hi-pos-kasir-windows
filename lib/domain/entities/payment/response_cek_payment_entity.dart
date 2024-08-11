import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
// import 'package:jaya_propertiy/domain/entities/order/response_create_ticket_no_entity.dart';

class ResponseCekPaymentEntity {
  String? status;
  String? desc;
  // List<ResponseCreateTicketNoEntity>? listTicket;

  ResponseCekPaymentEntity({
    this.status,
    this.desc,
    // this.listTicket,
  });

  factory ResponseCekPaymentEntity.fromJson(Map<String, dynamic> json) {
    logger.safeLog('JSON : $json');
    return ResponseCekPaymentEntity(
      status: json['Status'],
      desc: json['Desc'],
      // listTicket: json['listTicket'] != null
      //     ? (json['listTicket'] as List)
      //         .map((i) => ResponseCreateTicketNoEntity.fromJson(i))
      //         .toList()
      //     : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Status': status,
      'Desc': desc,
      // 'listTicket': listTicket,
    };
  }
}
