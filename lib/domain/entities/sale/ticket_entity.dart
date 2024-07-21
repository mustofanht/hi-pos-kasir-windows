import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/domain/entities/common/ticket_days_entity.dart';

class TicketEntity {
  int? ticketId;
  String? ticketName;
  String? ticketType;
  int? idLocation;
  String? nameLocation;
  double? nominal;
  String? state;
  int? minimum;
  List<TicketDaysEntity>? ticketDays;

  TicketEntity({
    this.ticketId,
    this.ticketName,
    this.ticketType,
    this.idLocation,
    this.nameLocation,
    this.nominal,
    this.state,
    this.minimum,
    this.ticketDays,
  });

  TicketEntity.fromJson(Map<String, dynamic> json) {
    try {
      ticketId = json['ticketId'];
      ticketName = json['ticketName'];
      ticketType = json['ticketType'];
      idLocation = json['idLocation'];
      nameLocation = json['nameLocation'];
      nominal =
          json['nominal'] != null ? (json['nominal'] as num).toDouble() : null;
      state = json['state'];
      minimum = json['minimum'];
      ticketDays = json['ticketDays'] != null
          ? (json['ticketDays'] as List)
              .map((item) => TicketDaysEntity.fromJson(item))
              .toList()
          : null;
    } catch (e) {
      logger.safeLog('error $e');
    }
  }
  Map<String, dynamic> toJson() {
    return {
      "ticketId": ticketId,
      "ticketName": ticketName,
      "ticketType": ticketType,
      "idLocation": idLocation,
      "nameLocation": nameLocation,
      "nominal": nominal,
      "state": state,
      "minimum": minimum,
      "ticketDays": ticketDays != null
          ? ticketDays!.map((item) => item.toJson()).toList()
          : null,
    };
  }
}
