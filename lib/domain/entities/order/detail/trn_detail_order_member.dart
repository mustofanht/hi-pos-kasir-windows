import 'package:jaya_propertiy/domain/entities/member/member_list.dart';

class TrnDetailOrderMember {
  String? memberNo;
  String? memberPhone;
  int? membershipQty;
  List<MemberListResponse>? memberList;
  double? membershipTtlAmount;
  DateTime? memberExpiredDate;
  String? memberName;
  double? membershipPrice;
  String? membershipName;
  String? memberEmail;

  TrnDetailOrderMember({
    this.memberNo,
    this.memberPhone,
    this.membershipQty,
    this.memberList,
    this.membershipTtlAmount,
    this.memberExpiredDate,
    this.memberName,
    this.membershipPrice,
    this.membershipName,
    this.memberEmail,
  });

  factory TrnDetailOrderMember.fromJson(Map<String, dynamic> json) {
    return TrnDetailOrderMember(
      memberNo: json['memberNo'],
      memberPhone: json['memberPhone'],
      membershipQty: json['membershipQty'],
      memberList: (json['memberList'] as List<dynamic>?)
          ?.map((e) => MemberListResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      membershipTtlAmount: json['membershipTtlAmount'] != null
          ? (json['membershipTtlAmount'] as num).toDouble()
          : null,
      memberExpiredDate: json['memberExpiredDate'] != null
          ? DateTime.parse(json['memberExpiredDate']).toLocal()
          : null,
      memberName: json['memberName'],
      membershipPrice: json['membershipPrice'] != null
          ? (json['membershipPrice'] as num).toDouble()
          : null,
      membershipName: json['membershipName'],
      memberEmail: json['memberEmail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memberNo': memberNo,
      'memberPhone': memberPhone,
      'membershipQty': membershipQty,
      'memberList': memberList?.map((e) => e.toJson()).toList(),
      'membershipTtlAmount': membershipTtlAmount,
      'memberExpiredDate': memberExpiredDate,
      'memberName': memberName,
      'membershipPrice': membershipPrice,
      'membershipName': membershipName,
      'memberEmail': memberEmail,
    };
  }
}
