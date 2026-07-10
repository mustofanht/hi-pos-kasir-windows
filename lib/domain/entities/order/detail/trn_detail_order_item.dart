class TrnDetailOrderItem{
  int? prodQty;
  String? prodName;
  double? prodTtlAmount;
  double? prodPrice;
  int? hour;
  DateTime? startDate;
  DateTime? endDate;

  TrnDetailOrderItem({
    this.prodQty,
    this.prodName,
    this.prodTtlAmount,
    this.prodPrice,
    this.hour,
    this.startDate,
    this.endDate,
  });

  factory TrnDetailOrderItem.fromJson(Map<String, dynamic> json) {
    return TrnDetailOrderItem(
      prodQty: json['prodQty'],
      prodName: json['prodName'],
      prodTtlAmount: json['prodTtlAmount'] != null ? (json['prodTtlAmount'] as num).toDouble() : null,
      prodPrice: json['prodPrice'] != null ? (json['prodPrice'] as num).toDouble() : null,
      hour: json['hour'] != null ? (json['hour'] as num).toInt() : null,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prodQty': prodQty,
      'prodName': prodName,
      'prodTtlAmount': prodTtlAmount,
      'prodPrice': prodPrice,
      'hour': hour,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}