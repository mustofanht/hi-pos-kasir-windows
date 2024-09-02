class CustomerPayment {
  String? orderNo;
  String? qrCode;
  String? type;
  bool isSuccess = false;

  CustomerPayment({
    this.orderNo,
    this.qrCode,
    this.type,
    required this.isSuccess,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderNo': orderNo,
      'qrCode': qrCode,
      'type': type,
      'isSuccess': isSuccess,
    };
  }

  CustomerPayment.fromJson(Map<String, dynamic> json) {
    orderNo = json['orderNo'];
    qrCode = json['qrCode'];
    type = json['type'];
    isSuccess = json['isSuccess'];
  }
}
