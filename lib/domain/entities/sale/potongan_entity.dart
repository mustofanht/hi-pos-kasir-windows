import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';

class PotonganEntity {
  int? voucherId;
  String? voucherName;
  String? voucherCode;
  String? voucherUnitType;
  double? voucherUnitValue;
  int? voucherLimit;
  int? voucherLocId;
  String? voucherLocName;
  String? voucherState;
  DateTime? voucherStartDate;
  DateTime? voucherEndDate;

  PotonganEntity({
    this.voucherId,
    this.voucherName,
    this.voucherCode,
    this.voucherUnitType,
    this.voucherUnitValue,
    this.voucherLimit,
    this.voucherLocId,
    this.voucherLocName,
    this.voucherState,
    this.voucherStartDate,
    this.voucherEndDate,
  });

  PotonganEntity.fromJson(Map<String?, dynamic> json) {
    voucherId = json['voucherId'];
    voucherName = json['voucherName'];
    voucherCode = json['voucherCode'];
    voucherUnitType = json['voucherUnitType'];
    voucherUnitValue = json['voucherUnitValue'] != null
        ? (json['voucherUnitValue'] as num).toDouble()
        : null;
    voucherLimit = json['voucherLimit'];
    voucherLocId = json['voucherLocId'];
    voucherLocName = json['voucherLocName'];
    voucherState = json['voucherState'];
    voucherStartDate = json['voucherStartDate'] != null
        ? DateTime.parse(json['voucherStartDate']).toLocal()
        : null;
    voucherEndDate = json['voucherEndDate'] != null
        ? DateTime.parse(json['voucherEndDate']).toLocal()
        : null;
  }

  Map<String?, dynamic> toJson() {
    return {
      'voucherId': voucherId,
      'voucherName': voucherName,
      'voucherCode': voucherCode,
      'voucherUnitType': voucherUnitType,
      'voucherUnitValue': voucherUnitValue,
      'voucherLimit': voucherLimit,
      'voucherLocId': voucherLocId,
      'voucherLocName': voucherLocName,
      'voucherState': voucherState,
      'voucherStartDate': voucherStartDate?.toIso8601String(),
      'voucherEndDate': voucherEndDate?.toIso8601String(),
    };
  }

  Map<String?, dynamic> toJson2() {
    return {
      'voucherId': voucherId,
      'voucherName': voucherName,
      'voucherCode': voucherCode,
      'voucherUnitType': voucherUnitType,
      'voucherUnitValue': voucherUnitValue,
      'voucherLimit': voucherLimit,
      'voucherLocId': voucherLocId,
      'voucherLocName': voucherLocName,
      'voucherState': voucherState,
      "voucherStartDate": voucherStartDate != null
          ? dateTimeUtil.dateFormat(voucherStartDate!, 'yyyy-MM-dd')
          : null,
      "voucherEndDate": voucherEndDate != null
          ? dateTimeUtil.dateFormat(voucherEndDate!, 'yyyy-MM-dd')
          : null,
    };
  }
}
