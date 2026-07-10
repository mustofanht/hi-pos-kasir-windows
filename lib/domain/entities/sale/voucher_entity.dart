import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';

class VoucherEntity {
  int? vpId;
  String? vpName;
  String? vpCode;
  String? vpFlMember;
  String? vpUnitType;
  double? vpUnitValue;
  int? vpLimit;
  int? vpLocId;
  DateTime? vpStartDate;
  DateTime? vpEndDate;
  String? vpDesc;
  String? vpState;
  String? locationName;
  String? vpFlWebsite;

  VoucherEntity({
    this.vpId,
    this.vpName,
    this.vpCode,
    this.vpFlMember,
    this.vpUnitType,
    this.vpUnitValue,
    this.vpLimit,
    this.vpLocId,
    this.vpStartDate,
    this.vpEndDate,
    this.vpDesc,
    this.vpState,
    this.locationName,
    this.vpFlWebsite,
  });

  VoucherEntity.fromJson(Map<String?, dynamic> json) {
    vpId = json['vpId'];
    vpName = json['vpName'];
    vpCode = json['vpCode'];
    vpFlMember = json['vpFlMember'];
    vpUnitType = json['vpUnitType'];
    vpUnitValue = json['vpUnitValue'] != null
        ? (json['vpUnitValue'] as num).toDouble()
        : null;
    vpLimit = json['vpLimit'];
    vpLocId = json['vpLocId'];
    vpStartDate = json['vpStartDate'] != null
        ? DateTime.parse(json['vpStartDate']).toLocal()
        : null;
    vpEndDate = json['vpEndDate'] != null
        ? DateTime.parse(json['vpEndDate']).toLocal()
        : null;
    vpDesc = json['vpDesc'];
    vpState = json['vpState'];
    locationName = json['locationName'];
    vpFlWebsite = json['vpFlWebsite'];
  }

  Map<String?, dynamic> toJson() {
    return {
      'vpId': vpId,
      'vpName': vpName,
      'vpCode': vpCode,
      'vpFlMember': vpFlMember,
      'vpUnitType': vpUnitType,
      'vpUnitValue': vpUnitValue,
      'vpLimit': vpLimit,
      'vpLocId': vpLocId,
      'vpStartDate': vpStartDate?.toIso8601String(),
      'vpEndDate': vpEndDate?.toIso8601String(),
      'vpDesc': vpDesc,
      'vpState': vpState,
      'locationName': locationName,
      'vpFlWebsite': vpFlWebsite,
    };
  }
  Map<String?, dynamic> toJson2() {
    return {
      'vpId': vpId,
      'vpName': vpName,
      'vpCode': vpCode,
      'vpFlMember': vpFlMember,
      'vpUnitType': vpUnitType,
      'vpUnitValue': vpUnitValue,
      'vpLimit': vpLimit,
      'vpLocId': vpLocId,
      "vpStartDate": vpStartDate != null
          ? dateTimeUtil.dateFormat(vpStartDate!, 'yyyy-MM-dd')
          : null,
      "vpEndDate": vpEndDate != null
          ? dateTimeUtil.dateFormat(vpEndDate!, 'yyyy-MM-dd')
          : null,
      'vpDesc': vpDesc,
      'vpState': vpState,
      'locationName': locationName,
      'vpFlWebsite': vpFlWebsite,
    };
  }
}
