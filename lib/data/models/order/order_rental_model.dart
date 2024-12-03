class OrderRentalModel {
  int? hour;
  double? amount;
  DateTime? startDate;
  DateTime? endDate;

  OrderRentalModel({ this.hour,  this.amount,  this.startDate,  this.endDate});

  factory OrderRentalModel.fromJson(Map<String, dynamic> json) {
    return OrderRentalModel(
      hour: json['hour'],
      amount: json['amount'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }

Map<String, dynamic> toJson() {
  return {
    'hour': hour,
    'amount': amount,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
  };
}
}