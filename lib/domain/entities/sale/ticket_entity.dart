// import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/app/utils/common/app_common.dart';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:jaya_propertiy/domain/entities/common/ticket_days_entity.dart';

class TicketEntity {
  int? ticketId;
  String? ticketName;
  String? ticketType;
  int? ticketLocation;
  String? ticketLocationName;
  double? ticketPrice;
  String? ticketState;
  int? ticketMinimum;
  String? pathImg;
  TicketDaysEntity? ticketDays;

  TicketEntity({
    this.ticketId,
    this.ticketName,
    this.ticketType,
    this.ticketLocation,
    this.ticketLocationName,
    this.ticketPrice,
    this.ticketState,
    this.ticketMinimum,
    this.pathImg,
    this.ticketDays,
  });

  TicketEntity.fromJson(Map<String, dynamic> json) {
    try {
      ticketId = json['ticketId'];
      ticketName = json['ticketName'];
      ticketType = json['ticketType'];
      ticketLocation = json['ticketLocation'];
      ticketLocationName = json['ticketLocationName'];
      ticketPrice = json['ticketPrice'] != null
          ? (json['ticketPrice'] as num).toDouble()
          : null;
      ticketState = json['ticketState'];
      ticketMinimum = json['ticketMinimum'];
      pathImg = json['pathImg'];

      if (json['ticketDays'] != null) {
        if (json['ticketDays'] is Map<Object?, Object?>) {
          Map<String, dynamic> result =
              common.convertToMapStringDynamic(json['ticketDays']);
          ticketDays = TicketDaysEntity.fromJson(result);
        } else {
          ticketDays = TicketDaysEntity.fromJson(json['ticketDays']);
        }
      }
    } catch (e) {
      logger.safeLog('error $e');
    }
  }
  Map<String, dynamic> toJson() {
    return {
      "ticketId": ticketId,
      "ticketName": ticketName,
      "ticketType": ticketType,
      "ticketLocation": ticketLocation,
      "ticketLocationName": ticketLocationName,
      "ticketPrice": ticketPrice,
      "ticketState": ticketState,
      "ticketMinimum": ticketMinimum,
      "pathImg": pathImg,
      "ticketDays": ticketDays?.toJson(),
    };
  }
}
