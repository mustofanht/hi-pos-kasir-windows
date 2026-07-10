import 'package:jaya_propertiy/domain/entities/member/member_detail.dart';
import 'package:jaya_propertiy/domain/entities/member/member_list.dart';
import 'package:jaya_propertiy/domain/entities/member/membership.dart';

class MemberValid {
  String? cardNo;
  String? cardName;
  String? cardIdentityNo;
  String? cardNoHp;
  int? cardLocId;
  int? cardMembId;
  String? cardEmail;
  String? cardAddress;
  Membership? mstMembership;
  List<MemberListResponse>? memberListResponses;
  MemberDetail? memberDetail;

  MemberValid({
    this.cardNo,
    this.cardName,
    this.cardIdentityNo,
    this.cardNoHp,
    this.cardLocId,
    this.cardMembId,
    this.cardEmail,
    this.cardAddress,
    this.mstMembership,
    this.memberListResponses,
    this.memberDetail,
  });

  factory MemberValid.fromJson(Map<String, dynamic> json) {
    return MemberValid(
      cardNo: json['cardNo'],
      cardName: json['cardName'],
      cardIdentityNo: json['cardIdentityNo'],
      cardNoHp: json['cardNoHp'],
      cardLocId: json['cardLocId'],
      cardMembId: json['cardMembId'],
      cardEmail: json['cardEmail'],
      cardAddress: json['cardAddress'],
      mstMembership: json['mstMembership'] != null
          ? Membership.fromJson(json['mstMembership'])
          : null,
      memberDetail: json['memberDetail'] != null
          ? MemberDetail.fromJson(json['memberDetail'])
          : null,
      memberListResponses: json['memberListResponses'] != null
          ? List<MemberListResponse>.from(
              json['memberListResponses']
                  .map((x) => MemberListResponse.fromJson(x)),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardNo': cardNo,
      'cardName': cardName,
      'cardIdentityNo': cardIdentityNo,
      'cardNoHp': cardNoHp,
      'cardLocId': cardLocId,
      'cardMembId': cardMembId,
      'cardEmail': cardEmail,
      'cardAddress': cardAddress,
      'mstMembership': mstMembership?.toJson(),
      'memberDetail': memberDetail?.toJson(),
      'memberListResponses': memberListResponses,
    };
  }
}
