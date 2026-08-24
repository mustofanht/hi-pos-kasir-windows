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
  // Kategori membership (mis. KLMRG=kolam renang, LPNGN=lapangan), di-mirror dari
  // loc_category. Dipakai untuk mengunci voucher member ke kategori transaksi:
  // member renang tak bisa dipakai di transaksi lapangan, begitu sebaliknya.
  String? membCategory;
  int? membVpId;
  int? membKuota;
  int? membMaxKuota;
  double? membRegPrice;
  // Nama peserta/pendaftar membership (diisi saat registrasi, untuk ditampilkan di TV Customer)
  String? registrantName;

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
    this.membCategory,
    this.membVpId,
    this.membKuota,
    this.membMaxKuota,
    this.membRegPrice,
    this.registrantName,
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
      membCategory: json['membCategory'],
      membVpId: json['membVpId'],
      membKuota: json['membKuota'],
      membMaxKuota: json['membMaxKuota'],
      membRegPrice: json['membRegPrice'] != null
          ? (json['membRegPrice'] as num).toDouble()
          : null,
      registrantName: json['registrantName'],
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
      'membCategory': membCategory,
      'membVpId': membVpId,
      'membKuota': membKuota,
      'membMaxKuota': membMaxKuota,
      'membRegPrice': membRegPrice,
      'registrantName': registrantName,
    };
  }
}
