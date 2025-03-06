import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order.dart';
import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order_customer.dart';
import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order_item.dart';
import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order_member.dart';
import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order_payment.dart';
import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order_ticket.dart';
import 'package:jaya_propertiy/domain/entities/order/detail/trn_detail_order_voucher.dart';

class TrnDetailOrderEntity {
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
  TrnDetailOrderCustomer? customerDetail;
  List<TrnDetailOrder>? detailOrderModels;
  List<TrnDetailOrderTicket>? trnOrderTicket;
  List<TrnDetailOrderVoucher>? trnOrderVouchers;
  List<TrnDetailOrderItem>? trnOrderItem;
  TrnDetailOrderPayment? paymentDetail;
  TrnDetailOrderMember? trnOrderMember;

  TrnDetailOrderEntity({
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
    this.trnOrderTicket,
    this.trnOrderVouchers,
    this.trnOrderItem,
    this.paymentDetail,
    this.trnOrderMember,
  });

  factory TrnDetailOrderEntity.fromJson(Map<String, dynamic> json) {
    return TrnDetailOrderEntity(
      orderNumber: json['orderNumber'],
      orderName: json['orderName'],
      orderDate: json['orderDate'] != null
          ? DateTime.parse(json['orderDate']).toLocal()
          : null,
      orderTotalItem: json['orderTotalItem'],
      orderDiskon: json['orderDiskon'] != null
          ? (json['orderDiskon'] as num).toDouble()
          : null,
      orderTotalAmt: json['orderTotalAmt'] != null
          ? (json['orderTotalAmt'] as num).toDouble()
          : null,
      orderTotalTgh: json['orderTotalTgh'] != null
          ? (json['orderTotalTgh'] as num).toDouble()
          : null,
      orderPaidBy: json['orderPaidBy'],
      orderPaidByName: json['orderPaidByName'],
      orderSource: json['orderSource'],
      orderStatus: json['orderStatus'],
      voucher: json['voucher'],
      ppn: json['ppn'],
      customerDetail: json['customerDetail'] != null
          ? TrnDetailOrderCustomer.fromJson(json['customerDetail'])
          : null,
      detailOrderModels: json['detailOrderModels'] != null
          ? (json['detailOrderModels'] as List)
              .map((i) => TrnDetailOrder.fromJson(i))
              .toList()
          : null,
      trnOrderTicket: json['trnOrderTicket'] != null
          ? (json['trnOrderTicket'] as List)
              .map((i) => TrnDetailOrderTicket.fromJson(i))
              .toList()
          : null,
      trnOrderVouchers: json['trnOrderVouchers'] != null
          ? (json['trnOrderVouchers'] as List)
              .map((i) => TrnDetailOrderVoucher.fromJson(i))
              .toList()
          : null,
      trnOrderItem: json['trnOrderItem'] != null
          ? (json['trnOrderItem'] as List)
              .map((i) => TrnDetailOrderItem.fromJson(i))
              .toList()
          : null,
      paymentDetail: json['paymentDetail'] != null
          ? TrnDetailOrderPayment.fromJson(json['paymentDetail'])
          : null,
      trnOrderMember: json['trnOrderMember'] != null
          ? TrnDetailOrderMember.fromJson(json['trnOrderMember'])
          : null,
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
      'detailOrderModels': detailOrderModels?.map((e) => e.toJson()).toList(),
      'trnOrderTicket': trnOrderTicket?.map((e) => e.toJson()).toList(),
      'trnOrderVouchers': trnOrderVouchers?.map((e) => e.toJson()).toList(),
      'trnOrderItem': trnOrderItem?.map((e) => e.toJson()).toList(),
      'paymentDetail': paymentDetail?.toJson(),
      'trnOrderMember': trnOrderMember?.toJson(),
    };
  }
}
