class TrnDetailOrder {
  String? productName;
  int? quantity;
  double? price;
  double? total;
  int? hour;
  DateTime? startDate;
  DateTime? endDate;

  TrnDetailOrder({
    this.productName,
    this.quantity,
    this.price,
    this.total,
    this.hour,
    this.startDate,
    this.endDate,
  });

  factory TrnDetailOrder.fromJson(Map<String, dynamic> json) {
    return TrnDetailOrder(
      productName: json['productName'],
      quantity: json['quantity'] != null ? int.parse(json['quantity']) : null,
      price: json['price'] != null ? double.parse(json['price']) : null,
      total: json['total'] != null ? double.parse(json['total']) : null,
      hour: json['hour'] != null ? (json['hour'] as num).toInt() : null,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']).toLocal() : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']).toLocal() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'quantity': quantity?.toString(),
      'price': price?.toString(),
      'total': total?.toString(),
      'hour': hour,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}