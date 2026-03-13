import 'package:jaya_propertiy/domain/entities/order/trn_order_customer_detail.dart';
import 'package:jaya_propertiy/domain/entities/order/trn_order_payment_detail.dart';

class TrnOrderEntity {
  String? orderNumber;
  String? orderName;
  DateTime? orderDate;
  int? orderTotalItem;
  double? orderDiskon;
  double? orderTotalAmt;
  double? orderTotalTgh;
  String? orderPaidBy;
  String? orderPaidByName;
  String? orderSource;
  String? orderStatus;
  dynamic voucher;
  dynamic ppn;
  TrnOrderCustomerDetail? customerDetail;
  dynamic detailOrderModels;
  TrnOrderPaymentDetail? paymentDetail;

  TrnOrderEntity({
    this.orderNumber,
    this.orderName,
    this.orderDate,
    this.orderTotalItem,
    this.orderDiskon,
    this.orderTotalAmt,
    this.orderTotalTgh,
    this.orderPaidBy,
    this.orderPaidByName,
    this.orderSource,
    this.orderStatus,
    this.voucher,
    this.ppn,
    this.customerDetail,
    this.detailOrderModels,
    this.paymentDetail,
  });

  factory TrnOrderEntity.fromJson(Map<String, dynamic> json) {
    return TrnOrderEntity(
      orderNumber: json['orderNumber'],
      orderName: json['orderName'],
      orderDate:
          json['orderDate'] != null ? DateTime.parse(json['orderDate']).toLocal() : null,
      orderTotalItem: json['orderTotalItem'],
      orderDiskon: json['orderDiskon'] != null ?  (json['orderDiskon'] as num).toDouble() : null,
      orderTotalAmt: json['orderTotalAmt'] != null ?  (json['orderTotalAmt'] as num).toDouble() : null,
      orderTotalTgh: json['orderTotalTgh'] != null ?  (json['orderTotalTgh'] as num).toDouble() : null,
      orderPaidBy: json['orderPaidBy'],
      orderPaidByName: json['orderPaidByName'],
      orderSource: json['orderSource'],
      orderStatus: json['orderStatus'],
      voucher: json['voucher'],
      ppn: json['ppn'],
      customerDetail: TrnOrderCustomerDetail.fromJson(json['customerDetail']),
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
      'orderDiskon': orderDiskon,
      'orderTotalAmt': orderTotalAmt,
      'orderTotalTgh': orderTotalTgh,
      'orderPaidBy': orderPaidBy,
      'orderPaidByName': orderPaidByName,
      'orderSource': orderSource,
      'orderStatus': orderStatus,
      'voucher': voucher,
      'ppn': ppn,
      'customerDetail': customerDetail?.toJson(),
      'detailOrderModels': detailOrderModels,
      'paymentDetail': paymentDetail?.toJson(),
    };
  }
}
