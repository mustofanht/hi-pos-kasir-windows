class MemberDetail {
  String? regCardNo;
  int? regLocId;
  int? regVpId;
  int? regMaxUsed;
  String? regType;
  String? regResetPeriod;
  String? regMaxPeriod;
  double? regPrice;
  String? regNextReset;
  DateTime? regEffFrom;
  DateTime? regEffTo;
  String? regCreatedDate;
  String? regCreatedBy;
  String? regUpdatedDate;
  String? regUpdatedBy;
  OrderRegMemberId? orderRegMemberId;

  MemberDetail({
    this.regCardNo,
    this.regLocId,
    this.regVpId,
    this.regMaxUsed,
    this.regType,
    this.regResetPeriod,
    this.regMaxPeriod,
    this.regPrice,
    this.regNextReset,
    this.regEffFrom,
    this.regEffTo,
    this.regCreatedDate,
    this.regCreatedBy,
    this.regUpdatedDate,
    this.regUpdatedBy,
    this.orderRegMemberId,
  });

  factory MemberDetail.fromJson(Map<String, dynamic> json) {
    return MemberDetail(
      regCardNo: json['regCardNo'],
      regLocId: json['regLocId'],
      regVpId: json['regVpId'],
      regMaxUsed: json['regMaxUsed'],
      regType: json['regType'],
      regResetPeriod: json['regResetPeriod'],
      regMaxPeriod: json['regMaxPeriod'],
      regPrice: json['regPrice'] != null
          ? (json['regPrice'] as num).toDouble()
          : null,
      regNextReset: json['regNextReset'],
      regEffFrom: json['regEffFrom'] != null
          ? DateTime.parse(json['regEffFrom']).toLocal()
          : null,
      regEffTo: json['regEffTo'] != null
          ? DateTime.parse(json['regEffTo']).toLocal()
          : null,
      regCreatedDate: json['regCreatedDate'],
      regCreatedBy: json['regCreatedBy'],
      regUpdatedDate: json['regUpdatedDate'],
      regUpdatedBy: json['regUpdatedBy'],
      orderRegMemberId: OrderRegMemberId.fromJson(json['orderRegMemberId']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'regCardNo': regCardNo,
      'regLocId': regLocId,
      'regVpId': regVpId,
      'regMaxUsed': regMaxUsed,
      'regType': regType,
      'regResetPeriod': regResetPeriod,
      'regMaxPeriod': regMaxPeriod,
      'regPrice': regPrice,
      'regNextReset': regNextReset,
      'regEffFrom': regEffFrom?.toIso8601String(),
      'regEffTo': regEffTo?.toIso8601String(),
      'regCreatedDate': regCreatedDate,
      'regCreatedBy': regCreatedBy,
      'regUpdatedDate': regUpdatedDate,
      'regUpdatedBy': regUpdatedBy,
      'orderRegMemberId': orderRegMemberId?.toJson(),
    };
  }
}

class OrderRegMemberId {
  String? regOrderNo;
  int? regMembId;

  OrderRegMemberId({
    this.regOrderNo,
    this.regMembId,
  });

  factory OrderRegMemberId.fromJson(Map<String, dynamic> json) {
    return OrderRegMemberId(
      regOrderNo: json['regOrderNo'],
      regMembId: json['regMembId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'regOrderNo': regOrderNo,
      'regMembId': regMembId,
    };
  }
}
