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
  String? locationName;
  dynamic voucher;
  dynamic ppn;
  TrnOrderCustomerDetail? customerDetail;
  dynamic detailOrderModels;
  TrnOrderPaymentDetail? paymentDetail;

  /// Semua baris trn_payment order ini -- lebih dari satu untuk order split
  /// payment (lihat TrnOrderInquiryResponse.paymentDetails di backend).
  /// [paymentDetail] di atas tetap cuma baris pertama, demi kompatibilitas.
  List<TrnOrderPaymentDetail>? paymentDetails;

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
    this.locationName,
    this.voucher,
    this.ppn,
    this.customerDetail,
    this.detailOrderModels,
    this.paymentDetail,
    this.paymentDetails,
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
      locationName: json['locationName'],
      voucher: json['voucher'],
      ppn: json['ppn'],
      customerDetail: json['customerDetail'] != null
          ? TrnOrderCustomerDetail.fromJson(json['customerDetail'])
          : null,
      detailOrderModels: json['detailOrderModels'],
      paymentDetail: json['paymentDetail'] != null
          ? TrnOrderPaymentDetail.fromJson(json['paymentDetail'])
          : null,
      paymentDetails: json['paymentDetails'] != null
          ? (json['paymentDetails'] as List)
              .map((i) => TrnOrderPaymentDetail.fromJson(i))
              .toList()
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
      'locationName': locationName,
      'voucher': voucher,
      'ppn': ppn,
      'customerDetail': customerDetail?.toJson(),
      'detailOrderModels': detailOrderModels,
      'paymentDetail': paymentDetail?.toJson(),
      'paymentDetails': paymentDetails?.map((e) => e.toJson()).toList(),
    };
  }
}
