class ResponsePaymentEntity {
  final String pymntOrderno;
  final String pymntCode;
  final String pymntReffno;
  final String pymntStatus;
  final DateTime pymntDate;
  final String pymntAmount;
  final String pymntReverseno;

  ResponsePaymentEntity({
    required this.pymntOrderno,
    required this.pymntCode,
    required this.pymntReffno,
    required this.pymntStatus,
    required this.pymntDate,
    required this.pymntAmount,
    required this.pymntReverseno,
  });

  factory ResponsePaymentEntity.fromJson(Map<String, dynamic> json) {
    return ResponsePaymentEntity(
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
