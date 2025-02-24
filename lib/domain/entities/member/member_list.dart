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
