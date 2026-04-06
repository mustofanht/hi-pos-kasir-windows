class TransactionEntity {
  String? orderNumber;
  String? location;
  String? product;
  DateTime? startDate;
  DateTime? endDate;
  int? totalHours;

  TransactionEntity({
    this.orderNumber,
    this.location,
    this.product,
    this.startDate,
    this.endDate,
    this.totalHours,
  });

  factory TransactionEntity.fromJson(Map<String, dynamic> json) {
    return TransactionEntity(
      orderNumber: json['orderNumber'],
      location: json['location'],
      product: json['product'],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate']).toLocal()
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate']).toLocal()
          : null,
      totalHours: json['totalHours'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderNumber': orderNumber,
      'location': location,
      'product': product,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'totalHours': totalHours,
    };
  }
}
