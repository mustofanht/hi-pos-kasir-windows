class TrnOrderPaymentDetail {
  String? pymntNo;
  String? pymntOrderno;
  String? pymntCode;
  String? pymntReffno;
  String? pymntStatus;
  DateTime? pymntDate;
  double? pymntAmount;
  double? pymntAdminFee;
  String? pymntReverseno;
  DateTime? pymntUpdatedDate;
  DateTime? pymntCreatedDate;
  String? pymntCreatedBy;
  String? pymntUpdatedBy;

  TrnOrderPaymentDetail({
    this.pymntNo,
    this.pymntOrderno,
    this.pymntCode,
    this.pymntReffno,
    this.pymntStatus,
    this.pymntDate,
    this.pymntAmount,
    this.pymntAdminFee,
    this.pymntReverseno,
    this.pymntUpdatedDate,
    this.pymntCreatedDate,
    this.pymntCreatedBy,
    this.pymntUpdatedBy,
  });

  factory TrnOrderPaymentDetail.fromJson(Map<String, dynamic> json) {
    return TrnOrderPaymentDetail(
      pymntNo: json['pymntNo'],
      pymntOrderno: json['pymntOrderno'],
      pymntCode: json['pymntCode'],
      pymntReffno: json['pymntReffno'],
      pymntStatus: json['pymntStatus'],
      pymntDate: json['pymntDate'] != null
          ? DateTime.parse(json['pymntDate']).toLocal()
          : null,
      pymntAmount: json['pymntAmount'] != null
          ? (json['pymntAmount'] as num).toDouble()
          : null,
      pymntAdminFee: json['pymntAdminFee'] != null
          ? (json['pymntAdminFee'] as num).toDouble()
          : null,
      pymntReverseno: json['pymntReverseno'],
      pymntUpdatedDate: json['pymntUpdatedDate'] != null
          ? DateTime.parse(json['pymntUpdatedDate']).toLocal()
          : null,
      pymntCreatedDate: json['pymntCreatedDate'] != null
          ? DateTime.parse(json['pymntCreatedDate']).toLocal()
          : null,
      pymntCreatedBy: json['pymntCreatedBy'],
      pymntUpdatedBy: json['pymntUpdatedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pymntNo': pymntNo,
      'pymntOrderno': pymntOrderno,
      'pymntCode': pymntCode,
      'pymntReffno': pymntReffno,
      'pymntStatus': pymntStatus,
      'pymntDate': pymntDate?.toIso8601String(),
      'pymntAmount': pymntAmount,
      'pymntAdminFee': pymntAdminFee,
      'pymntReverseno': pymntReverseno,
      'pymntUpdatedDate': pymntUpdatedDate?.toIso8601String(),
      'pymntCreatedDate': pymntCreatedDate?.toIso8601String(),
      'pymntCreatedBy': pymntCreatedBy,
      'pymntUpdatedBy': pymntUpdatedBy,
    };
  }
}
