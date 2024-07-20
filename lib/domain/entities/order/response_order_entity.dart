class ResponseOrderEntity {
  String? orderNumber;
  String? orderName;
  int? orderCustid;
  int? orderTotalItem;
  double? orderTotalAmt;
  String? orderPaidBy;
  String? orderStatus;
  String? orderPaymentNo;
  String? qrisUrl;

  ResponseOrderEntity({
    this.orderNumber,
    this.orderName,
    this.orderCustid,
    this.orderTotalItem,
    this.orderTotalAmt,
    this.orderPaidBy,
    this.orderStatus,
    this.orderPaymentNo,
    this.qrisUrl,
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
      orderPaymentNo: json['orderPaymentNo'],
      qrisUrl: json['qrisUrl'],
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
      'orderPaymentNo': orderPaymentNo,
      'qrisUrl': qrisUrl,
    };
  }
}
