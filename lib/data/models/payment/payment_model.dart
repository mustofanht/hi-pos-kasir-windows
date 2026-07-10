class PaymentModel {
  final String pymntOrderno;
  final String pymntCode;
  final String pymntReffno;
  final String pymntStatus;
  final DateTime pymntDate;
  final double pymntAmount;
  final String pymntReverseno;

  PaymentModel({
    required this.pymntOrderno,
    required this.pymntCode,
    required this.pymntReffno,
    required this.pymntStatus,
    required this.pymntDate,
    required this.pymntAmount,
    required this.pymntReverseno,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      pymntOrderno: json['pymntOrderno'],
      pymntCode: json['pymntCode'],
      pymntReffno: json['pymntReffno'],
      pymntStatus: json['pymntStatus'],
      pymntDate: json['pymntDate'],
      pymntAmount: json['pymntAmount'],
      pymntReverseno: json['pymntReverseno'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pymntOrderno': pymntOrderno,
      'pymntCode': pymntCode,
      'pymntReffno': pymntReffno,
      'pymntStatus': pymntStatus,
      'pymntDate': pymntDate,
      'pymntAmount': pymntAmount,
      'pymntReverseno': pymntReverseno,
    };
  }
}
