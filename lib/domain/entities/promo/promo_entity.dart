class PromoEntity {
  int? prmId;
  int? prmLocId;
  String? prmPathImg;
  String? prmDescription;
  String? prmFlActive;
  String? prmCreatedBy;
  DateTime? prmCreatedDate;
  String? prmUpdatedBy;
  DateTime? prmUpdatedDate;
  String? locCode;
  String? locName;

  PromoEntity({
    this.prmId,
    this.prmLocId,
    this.prmPathImg,
    this.prmDescription,
    this.prmFlActive,
    this.prmCreatedBy,
    this.prmCreatedDate,
    this.prmUpdatedBy,
    this.prmUpdatedDate,
    this.locCode,
    this.locName,
  });


  factory PromoEntity.fromJson(Map<String, dynamic> json) {
    return PromoEntity(
      prmId: json['prmId'],
      prmLocId: json['prmLocId'],
      prmPathImg: json['prmPathImg'],
      prmDescription: json['prmDescription'],
      prmFlActive: json['prmFlActive'],
      prmCreatedBy: json['prmCreatedBy'],
      prmCreatedDate: json['prmCreatedDate'] != null ? DateTime.parse(json['prmCreatedDate']).toLocal() : null,
      prmUpdatedBy: json['prmUpdatedBy'],
      prmUpdatedDate: json['prmUpdatedDate'] != null ? DateTime.parse(json['prmUpdatedDate']).toLocal() : null,
      locCode: json['locCode'],
      locName: json['locName'],
    );
  }

}
