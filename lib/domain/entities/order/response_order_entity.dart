import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order_member.dart';

class ResponseOrderEntity {
  String? orderNumber;
  String? orderName;
  DateTime? orderDate;
  int? orderCustid;
  int? orderTotalItem;
  double? orderTotalAmt;
  String? orderPaidBy;
  String? orderStatus;
  String? orderPaymentNo;
  String? qrisUrl;
  String? orderResource;
  String? orderVoidReason;
  String? orderActivationReason;
  String? orderActivationPath;
  String? orderVoucherDesc;
  TrnDetailOrderMember? trnDetailOrderMember;

  ResponseOrderEntity({
    this.orderNumber,
    this.orderName,
    this.orderDate,
    this.orderCustid,
    this.orderTotalItem,
    this.orderTotalAmt,
    this.orderPaidBy,
    this.orderStatus,
    this.orderPaymentNo,
    this.qrisUrl,
    this.orderResource,
    this.orderVoidReason,
    this.orderActivationReason,
    this.orderActivationPath,
    this.orderVoucherDesc,
    this.trnDetailOrderMember,
  });

  factory ResponseOrderEntity.fromJson(Map<String, dynamic> json) {
    return ResponseOrderEntity(
      orderNumber: json['orderNumber'],
      orderName: json['orderName'],
      orderDate: json['orderDate'] != null
          ? DateTime.parse(json['orderDate']).toLocal()
          : null,
      orderCustid: json['orderCustid'],
      orderTotalItem: json['orderTotalItem'],
      // orderTotalAmt: json['orderTotalAmt'],
      orderTotalAmt: json['orderTotalAmt'] != null ?  (json['orderTotalAmt'] as num).toDouble() : null,
      orderPaidBy: json['orderPaidBy'],
      orderStatus: json['orderStatus'],
      orderPaymentNo: json['orderPaymentNo'],
      qrisUrl: json['qrisUrl'],
      orderResource: json['orderResource'],
      orderVoidReason: json['orderVoidReason'],
      orderActivationReason: json['orderActivationReason'],
      orderActivationPath: json['orderActivationPath'],
      orderVoucherDesc: json['orderVoucherDesc'],
      trnDetailOrderMember: json['trnOrderMember'] != null
          ? TrnDetailOrderMember.fromJson(json['trnOrderMember'])
          : null,
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
      'orderResource': orderResource,
      'orderVoidReason': orderVoidReason,
      'orderActivationReason': orderActivationReason,
      'orderActivationPath': orderActivationPath,
      'orderVoucherDesc': orderVoucherDesc,
      'trnDetailOrderMember': trnDetailOrderMember?.toJson(),
    };
  }
}
