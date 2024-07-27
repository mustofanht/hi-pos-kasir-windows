class TrnDetailOrder {
  String? productName;
  int? quantity;
  double? price;
  double? total;

  TrnDetailOrder({
    this.productName,
    this.quantity,
    this.price,
    this.total,
  });

  factory TrnDetailOrder.fromJson(Map<String, dynamic> json) {
    return TrnDetailOrder(
      productName: json['productName'],
      quantity: json['quantity'] != null ? int.parse(json['quantity']) : null,
      price: json['price'] != null ? double.parse(json['price']) : null,
      total: json['total'] != null ? double.parse(json['total']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'quantity': quantity?.toString(),
      'price': price?.toString(),
      'total': total?.toString(),
    };
  }
}