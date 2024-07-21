import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';

class VoucherEntity {
  int? voucherId;
  String? voucherName;
  String? voucherCode;
  String? unitType;
  double? unitValue;
  int? voucherLimit;
  int? idLocation;
  String? nameLocation;
  String? voucherState;
  DateTime? startDate;
  DateTime? endDate;

  VoucherEntity({
    this.voucherId,
    this.voucherName,
    this.voucherCode,
    this.unitType,
    this.unitValue,
    this.voucherLimit,
    this.idLocation,
    this.nameLocation,
    this.voucherState,
    this.startDate,
    this.endDate,
  });

  VoucherEntity.fromJson(Map<String?, dynamic> json) {
    voucherId = json['voucherId'];
    voucherName = json['voucherName'];
    voucherCode = json['voucherCode'];
    unitType = json['unitType'];
    unitValue = json['unitValue'] != null
        ? (json['unitValue'] as num).toDouble()
        : null;
    voucherLimit = json['voucherLimit'];
    idLocation = json['idLocation'];
    nameLocation = json['nameLocation'];
    voucherState = json['voucherState'];
    startDate = json['startDate'] != null
        ? DateTime.parse(json['startDate'])
        : null;
    endDate = json['endDate'] != null
        ? DateTime.parse(json['endDate'])
        : null;
  }
  
  Map<String?, dynamic> toJson() {
    return {
      'voucherId': voucherId,
      'voucherName': voucherName,
      'voucherCode': voucherCode,
      'unitType': unitType,
      'unitValue': unitValue,
      'voucherLimit': voucherLimit,
      'idLocation': idLocation,
      'nameLocation': nameLocation,
      'voucherState': voucherState,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  Map<String?, dynamic> toJson2() {
    return {
      'voucherId': voucherId,
      'voucherName': voucherName,
      'voucherCode': voucherCode,
      'unitType': unitType,
      'unitValue': unitValue,
      'voucherLimit': voucherLimit,
      'idLocation': idLocation,
      'nameLocation': nameLocation,
      'voucherState': voucherState,
      "startDate": startDate != null
          ? dateTimeUtil.dateFormat(startDate!, 'yyyy-MM-dd')
          : null,
      "endDate": endDate != null
          ? dateTimeUtil.dateFormat(endDate!, 'yyyy-MM-dd')
          : null,
    };
  }
}
