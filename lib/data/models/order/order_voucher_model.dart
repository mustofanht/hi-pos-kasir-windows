class OrderVoucherModel {
  int? ovpVoucherId;
  int ovpTotalVoucher;
  double ovpTotalAmount;

  OrderVoucherModel({
    this.ovpVoucherId,
    required this.ovpTotalVoucher,
    required this.ovpTotalAmount,
  });

  factory OrderVoucherModel.fromJson(Map<String, dynamic> json) {
    return OrderVoucherModel(
      ovpVoucherId: json['ovpVoucherId'],
      ovpTotalVoucher: json['ovpTotalVoucher'],
      ovpTotalAmount: json['ovpTotalAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "ovpVoucherId": ovpVoucherId,
      "ovpTotalVoucher": ovpTotalVoucher,
      "ovpTotalAmount": ovpTotalAmount,
    };
  }
}