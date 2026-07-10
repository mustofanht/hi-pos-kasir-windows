class OrderRentalModel {
  int? hour;
  double? amount;
  DateTime? startDate;
  DateTime? endDate;
  String? orderNumberExtra;

  OrderRentalModel({ this.hour,  this.amount,  this.startDate,  this.endDate, this.orderNumberExtra});

  factory OrderRentalModel.fromJson(Map<String, dynamic> json) {
    return OrderRentalModel(
      hour: json['hour'],
      amount: json['amount'],
      startDate: DateTime.parse(json['startDate']).toLocal(),
      endDate: DateTime.parse(json['endDate']).toLocal(),
      orderNumberExtra: json['orderNumberExtra'],
    );
  }

Map<String, dynamic> toJson() {
  return {
    'hour': hour,
    'amount': amount,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'orderNumberExtra': orderNumberExtra,
  };
}
}