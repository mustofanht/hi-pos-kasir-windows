class OrderDepositModel {
  String odpOrderNumber;
  int odpDpId;
  double odpTotalAmount;

  OrderDepositModel({
    required this.odpOrderNumber,
    required this.odpDpId,
    required this.odpTotalAmount,
  });

  factory OrderDepositModel.fromJson(Map<String, dynamic> json) {
    return OrderDepositModel(
      odpOrderNumber: json['odpOrderNumber'],
      odpDpId: json['odpDpId'],
      odpTotalAmount: json['odpTotalAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "odpOrderNumber": odpOrderNumber,
      "odpDpId": odpDpId,
      "odpTotalAmount": odpTotalAmount,
    };
  }
}
