import 'package:jaya_propertiy/domain/entities/member/membership.dart';

class MemberValid {
  String? cardNo;
  String? cardName;
  String? cardIdentityNo;
  String? cardNoHp;
  int? cardLocId;
  int? cardMembId;
  Membership? mstMembership;
  List<MemberListResponse>? memberListResponses;

  MemberValid({
    this.cardNo,
    this.cardName,
    this.cardIdentityNo,
    this.cardNoHp,
    this.cardLocId,
    this.cardMembId,
    this.mstMembership,
    this.memberListResponses,
  });

  factory MemberValid.fromJson(Map<String, dynamic> json) {
    return MemberValid(
      cardNo: json['cardNo'],
      cardName: json['cardName'],
      cardIdentityNo: json['cardIdentityNo'],
      cardNoHp: json['cardNoHp'],
      cardLocId: json['cardLocId'],
      cardMembId: json['cardMembId'],
      mstMembership: json['mstMembership'] != null
          ? Membership.fromJson(json['mstMembership'])
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
      'mstMembership': mstMembership?.toJson(),
      'memberListResponses': memberListResponses,
    };
  }
}

class MemberListResponse {
  String? lsName;
  String? lsRelCode;

  MemberListResponse({
    this.lsName,
    this.lsRelCode,
  });

  factory MemberListResponse.fromJson(Map<String, dynamic> json) {
    return MemberListResponse(
      lsName: json['lsName'],
      lsRelCode: json['lsRelCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lsName': lsName,
      'lsRelCode': lsRelCode,
    };
  }
}
