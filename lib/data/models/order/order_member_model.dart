import 'package:jaya_propertiy/domain/entities/member/member_list.dart';
import 'package:jaya_propertiy/domain/entities/member/membership.dart';

class OrderMemberModel {
  String? qrCode;
  String? orderName;
  String? orderMemberNo;
  DateTime? orderMemberExpiredDate;
  String? orderPhoneNumber;
  String? orderEmail;
  String? orderReffno;
  String? orderPaidBy;
  String? custAddres;
  String? custIdentityNo;
  int? memberId;
  double? totalPrice;
  double? adminFeeAmt;
  Membership? membership;
  List<MemberListResponse>? listMember;

  OrderMemberModel({
    this.qrCode,
    this.orderName,
    this.orderMemberNo,
    this.orderMemberExpiredDate,
    this.orderPhoneNumber,
    this.orderEmail,
    this.orderReffno,
    this.orderPaidBy,
    this.custAddres,
    this.custIdentityNo,
    this.memberId,
    this.totalPrice,
    this.adminFeeAmt,
    this.membership,
    this.listMember,
  });

  factory OrderMemberModel.fromJson(Map<String, dynamic> json) {
    return OrderMemberModel(
      qrCode: json['qrCode'],
      orderName: json['orderName'],
      orderMemberNo: json['orderMemberNo'],
      orderMemberExpiredDate: json['orderMemberExpiredDate'] != null
          ? DateTime.parse(json['orderMemberExpiredDate']).toLocal()
          : null,
      orderPhoneNumber: json['orderPhoneNumber'],
      orderEmail: json['orderEmail'],
      orderReffno: json['orderReffno'],
      orderPaidBy: json['orderPaidBy'],
      custAddres: json['custAddres'],
      custIdentityNo: json['custIdentityNo'],
      memberId: json['memberId'],
      totalPrice: json['totalPrice'],
      adminFeeAmt: json['adminFeeAmt'],
      membership: json['membership'] != null
          ? Membership.fromJson(json['membership'])
          : null,
      listMember: (json['listMember'] as List<dynamic>?)
          ?.map((e) => MemberListResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qrCode': qrCode,
      'orderName': orderName,
      'orderMemberNo': orderMemberNo,
      'orderMemberExpiredDate': orderMemberExpiredDate?.toIso8601String(),
      'orderPhoneNumber': orderPhoneNumber,
      'orderEmail': orderEmail,
      'orderReffno': orderReffno,
      'orderPaidBy': orderPaidBy,
      'custAddres': custAddres,
      'custIdentityNo': custIdentityNo,
      'memberId': memberId,
      'totalPrice': totalPrice,
      'adminFeeAmt': adminFeeAmt,
      'membership': membership?.toJson(),
      'listMember': listMember?.map((e) => e.toJson()).toList(),
    };
  }
}
