class TrnDetailOrderVoucher {
  String? voucherName;
  double? voucherUnitValue;
  double? voucherUnitCalcValue;
  String? voucherUnitType;
  String? voucherCode;

  TrnDetailOrderVoucher({
    this.voucherName,
    this.voucherUnitValue,
    this.voucherUnitCalcValue,
    this.voucherUnitType,
    this.voucherCode,
  });

  factory TrnDetailOrderVoucher.fromJson(Map<String, dynamic> json) {
    return TrnDetailOrderVoucher(
      voucherName: json['voucherName'],
      voucherUnitValue: json['voucherUnitValue'] != null
          ? (json['voucherUnitValue'] as num).toDouble()
          : null,
      voucherUnitCalcValue: json['voucherUnitCalcValue'] != null
          ? (json['voucherUnitCalcValue'] as num).toDouble()
          : null,
      voucherUnitType: json['voucherUnitType'],
      voucherCode: json['voucherCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voucherName': voucherName,
      'voucherUnitValue': voucherUnitValue,
      'voucherUnitCalcValue': voucherUnitCalcValue,
      'voucherUnitType': voucherUnitType,
      'voucherCode': voucherCode,
    };
  }
}
