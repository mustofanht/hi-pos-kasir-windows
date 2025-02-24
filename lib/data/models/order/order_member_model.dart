import 'package:jaya_propertiy/domain/entities/member/member_list.dart';

class OrderMemberModel {
  String? qrCode;
  String? orderName;
  String? orderMemberNo;
  String? orderPhoneNumber;
  String? orderEmail;
  String? orderReffno;
  String? orderPaidBy;
  String? custAddres;
  String? custIdentityNo;
  int? memberId;
  List<MemberListResponse>? listMember;

  OrderMemberModel({
    this.qrCode,
    this.orderName,
    this.orderMemberNo,
    this.orderPhoneNumber,
    this.orderEmail,
    this.orderReffno,
    this.orderPaidBy,
    this.custAddres,
    this.custIdentityNo,
    this.memberId,
    this.listMember,
  });

  factory OrderMemberModel.fromJson(Map<String, dynamic> json) {
    return OrderMemberModel(
      qrCode: json['qrCode'],
      orderName: json['orderName'],
      orderMemberNo: json['orderMemberNo'],
      orderPhoneNumber: json['orderPhoneNumber'],
      orderEmail: json['orderEmail'],
      orderReffno: json['orderReffno'],
      orderPaidBy: json['orderPaidBy'],
      custAddres: json['custAddres'],
      custIdentityNo: json['custIdentityNo'],
      memberId: json['memberId'],
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
      'orderPhoneNumber': orderPhoneNumber,
      'orderEmail': orderEmail,
      'orderReffno': orderReffno,
      'orderPaidBy': orderPaidBy,
      'custAddres': custAddres,
      'custIdentityNo': custIdentityNo,
      'memberId': memberId,
      'listMember': listMember?.map((e) => e.toJson()).toList(),
    };
  }
}
