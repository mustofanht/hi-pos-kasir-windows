import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';

class VoucherEntity {
  int? voucherId;
  String? voucherName;
  String? voucherCode;
  String? voucherUnitType;
  double? voucherUnitValue;
  int? voucherLimit;
  int? voucherUnit;
  DateTime? voucherStartDate;
  DateTime? voucherEndDate;
  String? voucherDesc;
  String? voucherState;

  VoucherEntity({
    this.voucherId,
    this.voucherName,
    this.voucherCode,
    this.voucherUnitType,
    this.voucherUnitValue,
    this.voucherLimit,
    this.voucherUnit,
    this.voucherStartDate,
    this.voucherEndDate,
    this.voucherDesc,
    this.voucherState,
  });

  VoucherEntity.fromJson(Map<String?, dynamic> json) {
    voucherId = json['voucherId'];
    voucherName = json['voucherName'];
    voucherCode = json['voucherCode'];
    voucherUnitType = json['voucherUnitType'];
    // voucherUnitValue = json['voucherUnitValue'];
    voucherUnitValue = json['voucherUnitValue'] != null
        ? (json['voucherUnitValue'] as num).toDouble()
        : null;
    voucherLimit = json['voucherLimit'];
    voucherUnit = json['voucherUnit'];
    voucherStartDate = json['voucherStartDate'] != null
        ? DateTime.parse(json['voucherStartDate'])
        : null;
    voucherEndDate = json['voucherEndDate'] != null
        ? DateTime.parse(json['voucherEndDate'])
        : null;
    // voucherStartDate = json['voucherStartDate'];
    // voucherEndDate = json['voucherEndDate'];
    voucherDesc = json['voucherDesc'];
    voucherState = json['voucherState'];
  }
  Map<String?, dynamic> toJson() {
    return {
      "voucherId": voucherId,
      "voucherName": voucherName,
      "voucherCode": voucherCode,
      "voucherUnitType": voucherUnitType,
      "voucherUnitValue": voucherUnitValue,
      "voucherLimit": voucherLimit,
      "voucherUnit": voucherUnit,
      "voucherStartDate": voucherStartDate,
      "voucherEndDate": voucherEndDate,
      "voucherDesc": voucherDesc,
      "voucherState": voucherState,
    };
  }

  Map<String?, dynamic> toJson2() {
    return {
      "voucherId": voucherId,
      "voucherName": voucherName,
      "voucherCode": voucherCode,
      "voucherUnitType": voucherUnitType,
      "voucherUnitValue": voucherUnitValue,
      "voucherLimit": voucherLimit,
      "voucherUnit": voucherUnit,
      "voucherStartDate": voucherStartDate != null
          ? dateTimeUtil.dateFormat(voucherStartDate!, 'yyyy-MM-dd')
          : null,
      "voucherEndDate": voucherEndDate != null
          ? dateTimeUtil.dateFormat(voucherEndDate!, 'yyyy-MM-dd')
          : null,
      "voucherDesc": voucherDesc,
      "voucherState": voucherState,
    };
  }
}
