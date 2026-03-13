import 'package:jaya_propertiy/data/models/order/order_addon_model.dart';
import 'package:jaya_propertiy/data/models/order/order_deposit_model.dart';
import 'package:jaya_propertiy/data/models/order/order_ticket_model.dart';
import 'package:jaya_propertiy/data/models/order/order_potongan_model.dart';
import 'package:jaya_propertiy/data/models/order/order_voucher_model.dart';
import 'package:jaya_propertiy/domain/entities/order/response_create_ticket_no_entity.dart';

class OrderModel {
  String? orderName;
  String? orderPhoneNumber;
  String? orderEmail;
  String? orderNumber;
  String? orderReffno;
  String? orderMemberNo;
  String? qrCode;
  int orderTotalItem;
  double orderTotalAmt;
  double adminFeeAmt;
  int orderUnitId;
  int orderLoacationId;
  String orderPaidBy;
  String orderPaidByName;
  String orderStatus;
  DateTime? paymentDate;
  String? orderVoucherDesc;
  String? custAddres;
  List<OrderTicketModel> listTicket;
  List<OrderAddonModel> listProduct;
  List<OrderPotonganModel> listVoucher;
  List<OrderVoucherModel> listVoucherPrice;
  List<OrderDepositModel> listDepositUse;
  List<ResponseCreateTicketNoEntity>? listCreateTicket;

  OrderModel({
    this.orderName,
    this.orderPhoneNumber,
    this.orderEmail,
    this.orderNumber,
    this.orderReffno,
    this.orderMemberNo,
    this.qrCode,
    this.paymentDate,
    this.orderVoucherDesc,
    this.custAddres,
    required this.orderTotalItem,
    required this.orderTotalAmt,
    required this.adminFeeAmt,
    required this.orderUnitId,
    required this.orderLoacationId,
    required this.orderPaidBy,
    required this.orderPaidByName,
    required this.orderStatus,
    required this.listTicket,
    required this.listProduct,
    required this.listVoucher,
    required this.listVoucherPrice,
    required this.listDepositUse,
    this.listCreateTicket,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderName: json['orderName'],
      orderPhoneNumber: json['orderPhoneNumber'],
      orderEmail: json['orderEmail'],
      orderNumber: json['orderNumber'],
      orderReffno: json['orderReffno'],
      orderMemberNo: json['orderMemberNo'],
      qrCode: json['qrCode'],
      orderTotalItem: json['orderTotalItem'],
      orderTotalAmt: json['orderTotalAmt'],
      adminFeeAmt: json['adminFeeAmt'],
      orderUnitId: json['orderUnitId'],
      orderLoacationId: json['orderLoacationId'],
      orderPaidBy: json['orderPaidBy'],
      orderPaidByName: json['orderPaidByName'],
      orderStatus: json['orderStatus'],
      listTicket:
          json['listTicket'].map((e) => OrderTicketModel.fromJson(e)).toList(),
      listProduct:
          json['listProduct'].map((e) => OrderAddonModel.fromJson(e)).toList(),
      listVoucher: json['listVoucher']
          .map((e) => OrderPotonganModel.fromJson(e))
          .toList(),
      listVoucherPrice: json['listVoucherPrice']
          .map((e) => OrderVoucherModel.fromJson(e))
          .toList(),
      listDepositUse: json['listDepositUse']
          .map((e) => OrderDepositModel.fromJson(e))
          .toList(),
      listCreateTicket: json['listCreateTicket']
          .map((e) => ResponseCreateTicketNoEntity.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "orderName": orderName,
      "orderPhoneNumber": orderPhoneNumber,
      "orderEmail": orderEmail,
      "orderNumber": orderNumber,
      "orderReffno": orderReffno,
      "orderMemberNo": orderMemberNo,
      "qrCode": qrCode,
      "orderTotalItem": orderTotalItem,
      "orderTotalAmt": orderTotalAmt,
      "adminFeeAmt": adminFeeAmt,
      "orderUnitId": orderUnitId,
      "orderLoacationId": orderLoacationId,
      "orderPaidBy": orderPaidBy,
      "orderPaidByName": orderPaidByName,
      "orderStatus": orderStatus,
      "orderVoucherDesc": orderVoucherDesc,
      "custAddres": custAddres,
      "listTicket": listTicket.map((e) => e.toJson()).toList(),
      "listProduct": listProduct.map((e) => e.toJson()).toList(),
      "listVoucher": listVoucher.map((e) => e.toJson()).toList(),
      "listVoucherPrice": listVoucherPrice.map((e) => e.toJson()).toList(),
      "listDepositUse": listDepositUse.map((e) => e.toJson()).toList(),
      "listCreateTicket": listCreateTicket == null
          ? []
          : listCreateTicket?.map((e) => e.toJson()).toList(),
    };
  }
}
