class TrnDetailOrderItem{
  int? prodQty;
  String? prodName;
  double? prodTtlAmount;
  double? prodPrice;

  TrnDetailOrderItem({
    this.prodQty,
    this.prodName,
    this.prodTtlAmount,
    this.prodPrice,
  });

  factory TrnDetailOrderItem.fromJson(Map<String, dynamic> json) {
    return TrnDetailOrderItem(
      prodQty: json['prodQty'],
      prodName: json['prodName'],
      prodTtlAmount: json['prodTtlAmount'] != null ? (json['prodTtlAmount'] as num).toDouble() : null,
      prodPrice: json['prodPrice'] != null ? (json['prodPrice'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prodQty': prodQty,
      'prodName': prodName,
      'prodTtlAmount': prodTtlAmount,
      'prodPrice': prodPrice,
    };
  }
}