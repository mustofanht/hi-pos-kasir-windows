class ShiftDetailSumPotonganEntity {
  final String? name;
  final double? amount;

  ShiftDetailSumPotonganEntity({
    this.name,
    this.amount,
  });

  factory ShiftDetailSumPotonganEntity.fromJson(Map<String, dynamic> json) {
    return ShiftDetailSumPotonganEntity(
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
