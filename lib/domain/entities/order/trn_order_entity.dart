import 'package:jaya_propertiy/domain/entities/order/trn_order_payment_detail.dart';

class TrnOrderEntity {
  String? orderNumber;
  String? orderName;
  DateTime? orderDate;
  int? orderTotalItem;
  double? orderTotalAmt;
  String? orderPaidBy;
  String? orderSource;
  String? orderStatus;
  dynamic voucher;
  dynamic ppn;
  dynamic detailOrderModels;
  TrnOrderPaymentDetail? paymentDetail;

  TrnOrderEntity({
    this.orderNumber,
    this.orderName,
    this.orderDate,
    this.orderTotalItem,
    this.orderTotalAmt,
    this.orderPaidBy,
    this.orderSource,
    this.orderStatus,
    this.voucher,
    this.ppn,
    this.detailOrderModels,
    this.paymentDetail,
  });

  factory TrnOrderEntity.fromJson(Map<String, dynamic> json) {
    return TrnOrderEntity(
      orderNumber: json['orderNumber'],
      orderName: json['orderName'],
      orderDate:
          json['orderDate'] != null ? DateTime.parse(json['orderDate']) : null,
      orderTotalItem: json['orderTotalItem'],
      orderTotalAmt: json['orderTotalAmt'] != null ?  (json['orderTotalAmt'] as num).toDouble() : null,
      orderPaidBy: json['orderPaidBy'],
      orderSource: json['orderSource'],
      orderStatus: json['orderStatus'],
      voucher: json['voucher'],
      ppn: json['ppn'],
      detailOrderModels: json['detailOrderModels'],
      paymentDetail: TrnOrderPaymentDetail.fromJson(json['paymentDetail']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderNumber': orderNumber,
      'orderName': orderName,
      'orderDate': orderDate?.toIso8601String(),
      'orderTotalItem': orderTotalItem,
      'orderTotalAmt': orderTotalAmt,
      'orderPaidBy': orderPaidBy,
      'orderSource': orderSource,
      'orderStatus': orderStatus,
      'voucher': voucher,
      'ppn': ppn,
      'detailOrderModels': detailOrderModels,
      'paymentDetail': paymentDetail?.toJson(),
    };
  }
}
