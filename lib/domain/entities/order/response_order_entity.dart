class ResponseOrderEntity {
  final String orderNumber;
  final String orderName;
  final int orderCustid;
  final int orderTotalItem;
  final double orderTotalAmt;
  final String orderPaidBy;
  final String orderStatus;

  ResponseOrderEntity({
    required this.orderNumber,
    required this.orderName,
    required this.orderCustid,
    required this.orderTotalItem,
    required this.orderTotalAmt,
    required this.orderPaidBy,
    required this.orderStatus,
  });

  factory ResponseOrderEntity.fromJson(Map<String, dynamic> json) {
    return ResponseOrderEntity(
      orderNumber: json['orderNumber'],
      orderName: json['orderName'],
      orderCustid: json['orderCustid'],
      orderTotalItem: json['orderTotalItem'],
      orderTotalAmt: json['orderTotalAmt'],
      orderPaidBy: json['orderPaidBy'],
      orderStatus: json['orderStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderNumber': orderNumber,
      'orderName': orderName,
      'orderCustid': orderCustid,
      'orderTotalItem': orderTotalItem,
      'orderTotalAmt': orderTotalAmt,
      'orderPaidBy': orderPaidBy,
      'orderStatus': orderStatus,
    };
  }
}
