class Membership {
  int? membId;
  String? membName;
  String? membDesc;
  String? membState;
  String? membPeriod;
  String? membResetPeriod;
  String? membResetFirstdate;
  String? membStartFirstdate;
  String? membFlSunday;
  String? membFlMonday;
  String? membFlTuesday;
  String? membFlWednesday;
  String? membFlThursday;
  String? membFlFriday;
  String? membFlSaturday;
  String? membMaxType;
  String? membCheckName;
  int? membLocId;
  String? memLocName;
  int? membVpId;
  int? membKuota;
  int? membMaxKuota;
  double? membRegPrice;

  Membership({
    this.membId,
    this.membName,
    this.membDesc,
    this.membState,
    this.membPeriod,
    this.membResetPeriod,
    this.membResetFirstdate,
    this.membStartFirstdate,
    this.membFlSunday,
    this.membFlMonday,
    this.membFlTuesday,
    this.membFlWednesday,
    this.membFlThursday,
    this.membFlFriday,
    this.membFlSaturday,
    this.membMaxType,
    this.membCheckName,
    this.membLocId,
    this.memLocName,
    this.membVpId,
    this.membKuota,
    this.membMaxKuota,
    this.membRegPrice,
  });

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      membId: json['membId'],
      membName: json['membName'],
      membDesc: json['membDesc'],
      membState: json['membState'],
      membPeriod: json['membPeriod'],
      membResetPeriod: json['membResetPeriod'],
      membResetFirstdate: json['membResetFirstdate'],
      membStartFirstdate: json['membStartFirstdate'],
      membFlSunday: json['membFlSunday'],
      membFlMonday: json['membFlMonday'],
      membFlTuesday: json['membFlTuesday'],
      membFlWednesday: json['membFlWednesday'],
      membFlThursday: json['membFlThursday'],
      membFlFriday: json['membFlFriday'],
      membFlSaturday: json['membFlSaturday'],
      membMaxType: json['membMaxType'],
      membCheckName: json['membCheckName'],
      membLocId: json['membLocId'],
      memLocName: json['memLocName'],
      membVpId: json['membVpId'],
      membKuota: json['membKuota'],
      membMaxKuota: json['membMaxKuota'],
      membRegPrice: json['membRegPrice'] != null
          ? (json['membRegPrice'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'membId': membId,
      'membName': membName,
      'membDesc': membDesc,
      'membState': membState,
      'membPeriod': membPeriod,
      'membResetPeriod': membResetPeriod,
      'membResetFirstdate': membResetFirstdate,
      'membStartFirstdate': membStartFirstdate,
      'membFlSunday': membFlSunday,
      'membFlMonday': membFlMonday,
      'membFlTuesday': membFlTuesday,
      'membFlWednesday': membFlWednesday,
      'membFlThursday': membFlThursday,
      'membFlFriday': membFlFriday,
      'membFlSaturday': membFlSaturday,
      'membMaxType': membMaxType,
      'membCheckName': membCheckName,
      'membLocId': membLocId,
      'memLocName': memLocName,
      'membVpId': membVpId,
      'membKuota': membKuota,
      'membMaxKuota': membMaxKuota,
      'membRegPrice': membRegPrice,
    };
  }
}
