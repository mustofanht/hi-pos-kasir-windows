import 'package:jaya_propertiy/data/models/order/order_addon_model.dart';
import 'package:jaya_propertiy/data/models/order/order_ticket_model.dart';
import 'package:jaya_propertiy/data/models/order/order_voucher_model.dart';

class OrderModel {
  String orderName;
  String orderPhoneNumber;
  String orderEmail;
  String? orderReffno;
  int orderTotalItem;
  double orderTotalAmt;
  int orderUnitId;
  int orderLoacationId;
  String orderPaidBy;
  String orderStatus;
  List<OrderTicketModel> listTicket;
  List<OrderAddonModel> listProduct;
  List<OrderVoucherModel> listVoucher;

  OrderModel({
    required this.orderName,
    required this.orderPhoneNumber,
    required this.orderEmail,
    this.orderReffno,
    required this.orderTotalItem,
    required this.orderTotalAmt,
    required this.orderUnitId,
    required this.orderLoacationId,
    required this.orderPaidBy,
    required this.orderStatus,
    required this.listTicket,
    required this.listProduct,
    required this.listVoucher,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderName: json['orderName'],
      orderPhoneNumber: json['orderPhoneNumber'],
      orderEmail: json['orderEmail'],
      orderReffno: json['orderReffno'],
      orderTotalItem: json['orderTotalItem'],
      orderTotalAmt: json['orderTotalAmt'],
      orderUnitId: json['orderUnitId'],
      orderLoacationId: json['orderLoacationId'],
      orderPaidBy: json['orderPaidBy'],
      orderStatus: json['orderStatus'],
      listTicket:
          json['listTicket'].map((e) => OrderTicketModel.fromJson(e)).toList(),
      listProduct:
          json['listProduct'].map((e) => OrderAddonModel.fromJson(e)).toList(),
      listVoucher: json['listVoucher']
          .map((e) => OrderVoucherModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "orderName": orderName,
      "orderPhoneNumber": orderPhoneNumber,
      "orderEmail": orderEmail,
      "orderReffno": orderReffno,
      "orderTotalItem": orderTotalItem,
      "orderTotalAmt": orderTotalAmt,
      "orderUnitId": orderUnitId,
      "orderLoacationId": orderLoacationId,
      "orderPaidBy": orderPaidBy,
      "orderStatus": orderStatus,
      "listTicket": listTicket.map((e) => e.toJson()).toList(),
      "listProduct": listProduct.map((e) => e.toJson()).toList(),
      "listVoucher": listVoucher.map((e) => e.toJson()).toList(),
    };
  }
}
