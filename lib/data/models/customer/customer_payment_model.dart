class CustomerPayment {
  String? qrCode;
  String? type;
  bool isSuccess = false;

  CustomerPayment({
    this.qrCode,
    this.type,
    required this.isSuccess,
  });

  Map<String, dynamic> toJson() {
    return {
      'qrCode': qrCode,
      'type': type,
      'isSuccess': isSuccess,
    };
  }

  CustomerPayment.fromJson(Map<String, dynamic> json) {
    qrCode = json['qrCode'];
    type = json['type'];
    isSuccess = json['isSuccess'];
  }
}
