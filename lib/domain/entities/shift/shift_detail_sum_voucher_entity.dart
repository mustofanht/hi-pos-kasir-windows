class ShiftDetailSumVoucherEntity {
  final String? name;
  final double? amount;

  ShiftDetailSumVoucherEntity({
    this.name,
    this.amount,
  });

  factory ShiftDetailSumVoucherEntity.fromJson(Map<String, dynamic> json) {
    return ShiftDetailSumVoucherEntity(
      name: json['name'],
      amount: json['amount'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
    };
  }
}
