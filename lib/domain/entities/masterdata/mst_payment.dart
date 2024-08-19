class MstPayment {
  int? pymntLocId;
  String? pymntCode;
  String? pymntName;
  String? pymntType;
  String? pymntCategory;
  String? pymntCodePayGateway;
  String? pymntTypeFee;
  double? pymntAdminFee;
  String? pymntStatus;
  DateTime? pymntCreatedDate;
  String? pymntCreatedBy;
  DateTime? pymntUpdatedDate;
  String? pymntUpdatedBy;

  MstPayment({
    this.pymntLocId,
    this.pymntCode,
    this.pymntName,
    this.pymntType,
    this.pymntCategory,
    this.pymntCodePayGateway,
    this.pymntTypeFee,
    this.pymntAdminFee,
    this.pymntStatus,
    this.pymntCreatedDate,
    this.pymntCreatedBy,
    this.pymntUpdatedDate,
    this.pymntUpdatedBy,
  });

  factory MstPayment.fromJson(Map<String, dynamic> json) {
    return MstPayment(
      pymntLocId: json['pymntLocId'],
      pymntCode: json['pymntCode'],
      pymntName: json['pymntName'],
      pymntType: json['pymntType'],
      pymntCategory: json['pymntCategory'],
      pymntCodePayGateway: json['pymntCodePayGateway'],
      pymntTypeFee: json['pymntTypeFee'],
      pymntAdminFee: (json['pymntAdminFee'] as num).toDouble(),
      pymntStatus: json['pymntStatus'],
      pymntCreatedDate: DateTime.parse(json['pymntCreatedDate']).toLocal(),
      pymntCreatedBy: json['pymntCreatedBy'],
      pymntUpdatedDate: json['pymntUpdatedDate'] != null
          ? DateTime.parse(json['pymntUpdatedDate']).toLocal()
          : null,
      pymntUpdatedBy: json['pymntUpdatedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pymntLocId': pymntLocId,
      'pymntCode': pymntCode,
      'pymntName': pymntName,
      'pymntType': pymntType,
      'pymntCategory': pymntCategory,
      'pymntCodePayGateway': pymntCodePayGateway,
      'pymntTypeFee': pymntTypeFee,
      'pymntAdminFee': pymntAdminFee,
      'pymntStatus': pymntStatus,
      'pymntCreatedDate': pymntCreatedDate?.toIso8601String(),
      'pymntCreatedBy': pymntCreatedBy,
      'pymntUpdatedDate':
          pymntUpdatedDate != null ? pymntUpdatedDate!.toIso8601String() : null,
      'pymntUpdatedBy': pymntUpdatedBy,
    };
  }
}
