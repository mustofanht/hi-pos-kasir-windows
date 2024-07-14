import 'package:jaya_propertiy/app/utils/common/logger_util.dart';

class TicketEntity {
  int? ticketId;
  String? ticketName;
  int? ticketUnit;
  int? ticketLocation;
  int? ticketMinimum;
  String? ticketType;
  double? ticketPrice;
  String? ticketDesc;
  String? ticketState;
  String? ticketImgPath;
  String? ticketFlMember;
  String? ticketFlWebsite;

  TicketEntity({
    this.ticketId,
    this.ticketName,
    this.ticketUnit,
    this.ticketLocation,
    this.ticketMinimum,
    this.ticketType,
    this.ticketPrice,
    this.ticketDesc,
    this.ticketState,
    this.ticketImgPath,
    this.ticketFlMember,
    this.ticketFlWebsite,
  });

  TicketEntity.fromJson(Map<String, dynamic> json) {
    try {
      ticketId = json['ticketId'];
      ticketName = json['ticketName'];
      ticketUnit = json['ticketUnit'];
      ticketLocation = json['ticketLocation'];
      ticketMinimum = json['ticketMinimum'];
      ticketType = json['ticketType'];
      ticketPrice = json['ticketPrice'] != null
          ? (json['ticketPrice'] as num).toDouble()
          : null;
      ticketDesc = json['ticketDesc'];
      ticketState = json['ticketState'];
      ticketImgPath = json['ticketImgPath'];
      ticketFlMember = json['ticketFlMember'];
      ticketFlWebsite = json['ticketFlWebsite'];
    } catch (e) {
      logger.safeLog('error $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "ticketName": ticketName,
      "ticketUnit": ticketUnit,
      "ticketLocation": ticketLocation,
      "ticketMinimum": ticketMinimum,
      "ticketType": ticketType,
      "ticketPrice": ticketPrice,
      "ticketDesc": ticketDesc,
      "ticketState": ticketState,
      "ticketImgPath": ticketImgPath,
      "ticketFlMember": ticketFlMember,
      "ticketFlWebsite": ticketFlWebsite
    };
  }
}
