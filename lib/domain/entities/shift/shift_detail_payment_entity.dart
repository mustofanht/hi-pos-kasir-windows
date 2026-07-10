class ShiftDetailPaymentEntity {
  final String? name;
  final double? amount;

  ShiftDetailPaymentEntity({
    this.name,
    this.amount,
  });

  factory ShiftDetailPaymentEntity.fromJson(Map<String, dynamic> json) {
    return ShiftDetailPaymentEntity(
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
