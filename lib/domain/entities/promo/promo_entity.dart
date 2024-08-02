class PromoEntity {
  int prmId;
  int prmLocId;
  String prmPathImg;
  String prmDescription;
  String prmFlActive;
  String prmCreatedBy;
  DateTime prmCreatedDate;
  String prmUpdatedBy;
  DateTime prmUpdatedDate;
  String locCode;
  String locName;

  PromoEntity({
    required this.prmId,
    required this.prmLocId,
    required this.prmPathImg,
    required this.prmDescription,
    required this.prmFlActive,
    required this.prmCreatedBy,
    required this.prmCreatedDate,
    required this.prmUpdatedBy,
    required this.prmUpdatedDate,
    required this.locCode,
    required this.locName,
  });

  factory PromoEntity.fromJson(Map<String, dynamic> json) {
    return PromoEntity(
      prmId: json['prmId'],
      prmLocId: json['prmLocId'],
      prmPathImg: json['prmPathImg'],
      prmDescription: json['prmDescription'],
      prmFlActive: json['prmFlActive'],
      prmCreatedBy: json['prmCreatedBy'],
      prmCreatedDate: DateTime.parse(json['prmCreatedDate']),
      prmUpdatedBy: json['prmUpdatedBy'],
      prmUpdatedDate: DateTime.parse(json['prmUpdatedDate']),
      locCode: json['locCode'],
      locName: json['locName'],
    );
  }
}
