class ResponseCekPaymentEntity {
  String? status;
  String? desc;

  ResponseCekPaymentEntity({this.status, this.desc});

  factory ResponseCekPaymentEntity.fromJson(Map<String, dynamic> json) {
    return ResponseCekPaymentEntity(
      status: json['Status'],
      desc: json['Desc'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Status': status,
      'Desc': desc,
    };
  }
}